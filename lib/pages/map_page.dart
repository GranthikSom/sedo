import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/themes/theme_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  bool _mapInitialized = false;
  bool _followUser = true;

  // Visual Notifiers for rendering marker position & heading at 60 FPS
  final ValueNotifier<LatLng> _smoothLocationNotifier = ValueNotifier(
    const LatLng(0, 0),
  );
  final ValueNotifier<double> _smoothHeadingNotifier = ValueNotifier(0.0);

  // Kalman Filters for latitude and longitude to filter GPS noise
  final SimpleKalmanFilter _latFilter = SimpleKalmanFilter();
  final SimpleKalmanFilter _lngFilter = SimpleKalmanFilter();

  // Interpolation / Dead Reckoning Variables
  LatLng _interpolationStartLatLng = const LatLng(0, 0);
  LatLng _interpolationTargetLatLng = const LatLng(0, 0);
  DateTime _interpolationStartTime = DateTime.now();

  LatLng? _lastRawLatLng;
  bool _isFirstLocation = true;

  double _lastSpeedMs = 0.0;
  double _lastFilteredHeadingTarget = 0.0;
  double _targetZoom = 18.0;

  LatLng? _targetCenter;
  Ticker? _ticker;

  // ponytail: rider at ~30% from left edge and ~70% from top (lower on screen)
  LatLng _offsetCenter(LatLng rider) {
    try {
      final camera = _mapController.camera;
      final w = camera.nonRotatedSize.width;
      final h = camera.nonRotatedSize.height;
      if (w.isInfinite || w.isNegative || h.isInfinite || h.isNegative)
        return rider;
      final p = camera.projectAtZoom(rider, camera.zoom);
      return camera.unprojectAtZoom(
        p + Offset(w * 0.14, -h * 0.36),
        camera.zoom,
      );
    } catch (_) {
      // MapController is not attached yet
      return rider;
    }
  }

  double _getZoom(double speed) {
    if (speed < 20) return 18;
    if (speed < 50) return 17;
    if (speed < 90) return 16;
    return 15;
  }

  /// Handles incoming raw GPS location updates, filtering them and starting interpolation.
  void _onNewGpsLocation(
    LatLng rawLocation,
    double rawHeading,
    double speedKmh,
  ) {
    double speedMs = speedKmh / 3.6;

    // 1. Adaptive Kalman Filter noise parameters
    // As speed increases, process variance q increases to track rapid changes.
    // When stationary, q is very small to lock position and ignore jitter.
    double q = 1e-10 + (speedMs * 0.000009) * (speedMs * 0.000009);
    // Measurement noise covariance r represents estimated GPS accuracy (~5-10 meters in degrees)
    double r = 1.6e-9; // equivalent to (0.00004 degrees)^2

    double filteredLat = _latFilter.filter(rawLocation.latitude, q, r);
    double filteredLng = _lngFilter.filter(rawLocation.longitude, q, r);
    LatLng filteredLatLng = LatLng(filteredLat, filteredLng);

    // 2. Initialize or Handle Jumps
    if (_isFirstLocation) {
      _smoothLocationNotifier.value = filteredLatLng;
      _interpolationStartLatLng = filteredLatLng;
      _interpolationTargetLatLng = filteredLatLng;
      _smoothHeadingNotifier.value = rawHeading.isNaN ? 0.0 : rawHeading;
      _lastFilteredHeadingTarget = rawHeading.isNaN ? 0.0 : rawHeading;
      _isFirstLocation = false;
      _interpolationStartTime = DateTime.now();

      _targetCenter = _offsetCenter(filteredLatLng);
      _targetZoom = _getZoom(speedKmh);

      setState(() {
        _mapInitialized = true;
      });
      return;
    }

    // Snap marker instantly if coordinate jump is too large (e.g., GPS signal loss recovery)
    double jumpDistance = Geolocator.distanceBetween(
      _smoothLocationNotifier.value.latitude,
      _smoothLocationNotifier.value.longitude,
      filteredLatLng.latitude,
      filteredLatLng.longitude,
    );
    if (jumpDistance > 50.0) {
      _smoothLocationNotifier.value = filteredLatLng;
      _interpolationStartLatLng = filteredLatLng;
      _interpolationTargetLatLng = filteredLatLng;
      _latFilter.reset();
      _lngFilter.reset();
      _latFilter.filter(filteredLatLng.latitude, q, r);
      _lngFilter.filter(filteredLatLng.longitude, q, r);
      _interpolationStartTime = DateTime.now();
      return;
    }

    // 3. Compute Travel Direction
    // Prevent random spins/bearing drift when stationary or moving very slowly.
    double targetHeading;
    if (speedKmh > 5.0) {
      targetHeading = _calculateBearing(
        _interpolationTargetLatLng,
        filteredLatLng,
      );
    } else {
      targetHeading = rawHeading.isNaN
          ? _lastFilteredHeadingTarget
          : rawHeading;
    }

    // 4. Update Interpolation Coordinates
    _interpolationStartLatLng = _smoothLocationNotifier.value;
    _interpolationTargetLatLng = filteredLatLng;
    _lastSpeedMs = speedMs;
    _lastFilteredHeadingTarget = targetHeading;
    _targetZoom = _getZoom(speedKmh);
    _interpolationStartTime = DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    _ticker = Ticker((_) {
      if (!_mapInitialized) return;

      final now = DateTime.now();
      final elapsedMs = now.difference(_interpolationStartTime).inMilliseconds;
      const double expectedIntervalMs = 1000.0;
      double t = elapsedMs / expectedIntervalMs;

      LatLng currentLatLng;
      if (t <= 1.0) {
        // Interpolate smoothly between updates
        double lat =
            _interpolationStartLatLng.latitude +
            (_interpolationTargetLatLng.latitude -
                    _interpolationStartLatLng.latitude) *
                t;
        double lng =
            _interpolationStartLatLng.longitude +
            (_interpolationTargetLatLng.longitude -
                    _interpolationStartLatLng.longitude) *
                t;
        currentLatLng = LatLng(lat, lng);
      } else {
        // Dead Reckoning: Predict current position until next GPS update arrives (capped at 3s)
        if (elapsedMs < 3000) {
          double overshootSeconds = (elapsedMs - expectedIntervalMs) / 1000.0;
          double distance = _lastSpeedMs * overshootSeconds;
          double headingRad = _lastFilteredHeadingTarget * math.pi / 180.0;

          double deltaLat = (distance * math.cos(headingRad)) / 111111.0;
          double deltaLng =
              (distance * math.sin(headingRad)) /
              (111111.0 *
                  math.cos(
                    _interpolationTargetLatLng.latitude * math.pi / 180.0,
                  ));

          currentLatLng = LatLng(
            _interpolationTargetLatLng.latitude + deltaLat,
            _interpolationTargetLatLng.longitude + deltaLng,
          );
        } else {
          currentLatLng = _interpolationTargetLatLng;
        }
      }

      // Update the 60 FPS marker location
      _smoothLocationNotifier.value = currentLatLng;

      // Smooth heading rotation, avoiding 360 wrap jumps
      double headingDiff = _shortestAngleDiff(
        _smoothHeadingNotifier.value,
        _lastFilteredHeadingTarget,
      );
      double nextHeading =
          (_smoothHeadingNotifier.value + headingDiff * 0.12) % 360.0;
      if (nextHeading < 0.0) {
        nextHeading += 360.0;
      }
      _smoothHeadingNotifier.value = nextHeading;

      // Smooth camera follow
      if (_followUser) {
        try {
          _targetCenter = _offsetCenter(currentLatLng);
          final currentCameraCenter = _mapController.camera.center;

          double latDiff =
              (_targetCenter!.latitude - currentCameraCenter.latitude).abs();
          double lngDiff =
              (_targetCenter!.longitude - currentCameraCenter.longitude).abs();

          // Apply a threshold (~0.2m) to prevent tiny jittering when stationary
          if (latDiff > 1.8e-6 || lngDiff > 1.8e-6) {
            double nextLat =
                currentCameraCenter.latitude +
                (_targetCenter!.latitude - currentCameraCenter.latitude) * 0.08;
            double nextLng =
                currentCameraCenter.longitude +
                (_targetCenter!.longitude - currentCameraCenter.longitude) *
                    0.08;

            double currentZoom = _mapController.camera.zoom;
            double nextZoom = currentZoom + (_targetZoom - currentZoom) * 0.05;
            if ((nextZoom - _targetZoom).abs() < 0.01) {
              nextZoom = _targetZoom;
            }

            _mapController.move(LatLng(nextLat, nextLng), nextZoom);
          }

          // ponytail: +30° rightward tilt while moving; remove offset for north-up
          _mapController.rotate(_smoothHeadingNotifier.value + 30.0);
        } catch (_) {
          // MapController might not be attached to the Map widget yet
        }
      }
    });

    _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _smoothLocationNotifier.dispose();
    _smoothHeadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Consumer<SpeedProvider>(
      builder: (context, gpsProvider, child) {
        final position = gpsProvider.currentPosition;

        if (position == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final rawLocation = LatLng(position.latitude, position.longitude);

        if (_lastRawLatLng == null ||
            _lastRawLatLng!.latitude != rawLocation.latitude ||
            _lastRawLatLng!.longitude != rawLocation.longitude) {
          _lastRawLatLng = rawLocation;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _onNewGpsLocation(
                rawLocation,
                position.heading,
                gpsProvider.speed,
              );
            }
          });
        }

        if (!_mapInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // ponytail: invert-colors overlay for dark mode instead of a separate tile source
              ColorFiltered(
                colorFilter: isDark
                    ? const ColorFilter.matrix(<double>[
                        -1,
                        0,
                        0,
                        0,
                        255,
                        0,
                        -1,
                        0,
                        0,
                        255,
                        0,
                        0,
                        -1,
                        0,
                        255,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _smoothLocationNotifier.value,
                    initialZoom: _targetZoom,

                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && _followUser) {
                        setState(() {
                          _followUser = false;
                        });
                      }
                    },

                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),

                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.granthiksom.sedo',
                    ),

                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _smoothLocationNotifier,
                        _smoothHeadingNotifier,
                      ]),
                      builder: (context, _) {
                        return MarkerLayer(
                          markers: [
                            Marker(
                              point: _smoothLocationNotifier.value,
                              width: 70,
                              height: 70,
                              child: Transform.rotate(
                                angle:
                                    _smoothHeadingNotifier.value *
                                    math.pi /
                                    180.0,
                                child: const Icon(
                                  Icons.navigation,
                                  size: 45,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiary.withOpacity(0.8),

                  onPressed: () {
                    setState(() {
                      _followUser = true;
                    });
                    _targetZoom = _getZoom(gpsProvider.speed);
                  },

                  child: const Icon(Icons.my_location, size: 33),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A simple 1D Kalman Filter to smooth location coordinates and reduce GPS jitter.
class SimpleKalmanFilter {
  double _x = 0.0; // Estimated state value
  double _p = 1.0; // Estimated error covariance
  bool _initialized = false;

  void reset() {
    _initialized = false;
  }

  /// Filters a raw measurement using process noise covariance [q] and measurement noise covariance [r].
  double filter(double measurement, double q, double r) {
    if (!_initialized) {
      _x = measurement;
      _p = 1.0;
      _initialized = true;
      return _x;
    }

    // Prediction Phase
    final xPred = _x;
    final pPred = _p + q;

    // Update Phase (Measurement)
    final k = pPred / (pPred + r); // Kalman Gain
    _x = xPred + k * (measurement - xPred);
    _p = (1.0 - k) * pPred;

    return _x;
  }
}

/// Computes the shortest angular distance between two headings in degrees.
double _shortestAngleDiff(double from, double to) {
  double diff = (to - from) % 360.0;
  if (diff > 180.0) {
    diff -= 360.0;
  } else if (diff < -180.0) {
    diff += 360.0;
  }
  return diff;
}

/// Calculates the geographic bearing between two LatLng points in degrees.
double _calculateBearing(LatLng start, LatLng end) {
  final lat1 = start.latitude * math.pi / 180.0;
  final lon1 = start.longitude * math.pi / 180.0;
  final lat2 = end.latitude * math.pi / 180.0;
  final lon2 = end.longitude * math.pi / 180.0;

  final dLon = lon2 - lon1;

  final y = math.sin(dLon) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

  final brng = math.atan2(y, x) * 180.0 / math.pi;
  return (brng + 360.0) % 360.0;
}
