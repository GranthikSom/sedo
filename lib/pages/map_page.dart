import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/service/tile_cache.dart';
import 'package:sedo/themes/theme_provider.dart';
import 'package:sedo/service/map_settings_provider.dart';
import 'package:sedo/navigation/navigation_session_provider.dart';
import 'package:sedo/navigation/navigation_search_provider.dart';
import 'package:sedo/navigation/navigation_provider.dart';
import 'package:sedo/navigation/destination_model.dart';
import 'package:sedo/navigation/search_location.dart';
import 'package:sedo/service/music_provider.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  CachingTileProvider? _tileProvider;

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

  // Music Player State
  final MediaController _mediaController = MediaController();
  String _musicTitle = '—';
  bool _isMusicPlaying = false;
  bool _showMusicPlayer = false;
  Timer? _musicPollTimer;

  // ponytail: rider at ~30% from left edge and ~70% from top (lower on screen)
  LatLng _offsetCenter(LatLng rider) {
    try {
      final camera = _mapController.camera;
      final w = camera.nonRotatedSize.width;
      final h = camera.nonRotatedSize.height;
      if (w.isInfinite || w.isNegative || h.isInfinite || h.isNegative) {
        return rider;
      }
      // ponytail: rider centered in left map-half (~25% from left edge of full screen)
      final p = camera.projectAtZoom(rider, camera.zoom);
      return camera.unprojectAtZoom(
        p + Offset(w * 0.25, -h * 0.36),
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

    // 5. Update Navigation Progress
    if (mounted) {
      final navSession = context.read<NavigationSessionProvider>();
      final mapPrefs = context.read<MapSettingsProvider>();
      if (navSession.isActive) {
        navSession.updateLocation(filteredLatLng, mapPrefs.routingProfile);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // ponytail: init tile cache provider; tiles cached as user browses
    OfflineMapManager.createProvider().then((p) {
      if (mounted) setState(() => _tileProvider = p);
    });

    _mediaController.setOnNowPlayingChanged(_fetchNowPlaying);
    _fetchNowPlaying();
    _musicPollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchNowPlaying(),
    );

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

      // Apply Snapping if Navigation is Active and SnapToRoad is enabled
      LatLng renderLatLng = currentLatLng;
      final navSession = Provider.of<NavigationSessionProvider>(
        context,
        listen: false,
      );
      final mapPrefs = Provider.of<MapSettingsProvider>(context, listen: false);

      if (navSession.isActive &&
          mapPrefs.snapToRoad &&
          navSession.snappedLocation != null) {
        renderLatLng = navSession.snappedLocation!;
      }

      // Update the 60 FPS marker location
      _smoothLocationNotifier.value = renderLatLng;

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
      if (_followUser || mapPrefs.autoCenterMap) {
        try {
          _targetCenter = _offsetCenter(renderLatLng);
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
          if (mapPrefs.rotateMapWithHeading) {
            _mapController.rotate(_smoothHeadingNotifier.value + 30.0);
          }
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
    _musicPollTimer?.cancel();
    _mediaController.dispose();
    super.dispose();
  }

  Future<void> _fetchNowPlaying() async {
    final info = await _mediaController.nowPlaying();
    if (!mounted) return;
    setState(() {
      _musicTitle = info['title'] as String? ?? '—';
      bool wasPlaying = _isMusicPlaying;
      _isMusicPlaying = info['isPlaying'] as bool? ?? false;
      if (!wasPlaying && _isMusicPlaying) {
         _showMusicPlayer = true;
      }
    });
  }

  Future<void> _handlePlayPause() async {
    await _mediaController.playPause();
    await _fetchNowPlaying();
  }

  Future<void> _handleNext() async {
    await _mediaController.next();
    await _fetchNowPlaying();
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: const _SearchSheet(),
        ),
      ),
    );
  }

  void _calculateRouteForDestination(
    BuildContext context,
    DestinationModel dest,
  ) async {
    final navSearch = context.read<NavigationSearchProvider>();
    final mapPrefs = context.read<MapSettingsProvider>();

    // Set destination first to show loading/card
    navSearch.setDestination(dest);

    final route = await NavigationProvider.fetchRoute(
      start: _smoothLocationNotifier.value,
      destination: dest.location,
      profile: mapPrefs.routingProfile == 'Driving' ? 'driving' : 'driving',
    );

    if (route != null && mounted) {
      navSearch.setDestination(dest.copyWith(route: route));
      // Zoom out to fit route (simple approach: just zoom out a bit or move to center)
      _targetZoom = 14.0;
      _followUser = false;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to calculate route.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final navSession = context.watch<NavigationSessionProvider>();
    final mapPrefs = context.watch<MapSettingsProvider>();
    final navSearch = context.watch<NavigationSearchProvider>();

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
                      if (hasGesture &&
                          (_followUser || mapPrefs.autoCenterMap)) {
                        setState(() {
                          _followUser = false;
                        });
                        if (mapPrefs.autoCenterMap) {
                          mapPrefs.setAutoCenterMap(false);
                        }
                      }
                    },

                    onLongPress: (tapPosition, point) {
                      if (navSession.isActive) return;
                      _calculateRouteForDestination(
                        context,
                        DestinationModel(name: 'Dropped Pin', location: point),
                      );
                    },
                    onTap: (tapPosition, point) {
                      if (navSession.isActive) return;
                      _calculateRouteForDestination(
                        context,
                        DestinationModel(name: 'Dropped Pin', location: point),
                      );
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
                      tileProvider: _tileProvider,
                    ),

                    if (navSession.isActive &&
                        navSession.currentRoute != null &&
                        mapPrefs.showRouteLine)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: navSession.currentRoute!.polyline,
                            strokeWidth: mapPrefs.routeLineWidth,
                            color: Colors.blue.withOpacity(
                              mapPrefs.routeTransparency,
                            ),
                          ),
                        ],
                      )
                    else if (!navSession.isActive &&
                        navSearch.selectedDestination?.route != null &&
                        mapPrefs.showRouteLine)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points:
                                navSearch.selectedDestination!.route!.polyline,
                            strokeWidth: mapPrefs.routeLineWidth,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                        ],
                      ),

                    if (navSession.isActive && navSession.currentRoute != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: navSession.currentRoute!.destination,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      )
                    else if (!navSession.isActive &&
                        navSearch.selectedDestination != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: navSearch.selectedDestination!.location,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
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

              if (!navSession.isActive)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'searchBtn',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    onPressed: () => _showSearchSheet(context),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),

              if (!navSession.isActive)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'musicBtn',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    onPressed: () {
                      setState(() {
                        _showMusicPlayer = !_showMusicPlayer;
                      });
                    },
                    child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
                  ),
                ),

              if (_showMusicPlayer)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note, size: 20, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              _musicTitle,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _handlePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isMusicPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Theme.of(context).colorScheme.surface,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _handleNext,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (navSession.isActive)
                      _buildActiveNavigationUI(
                        context,
                        navSession,
                        gpsProvider,
                        mapPrefs,
                      ),

                    if (!navSession.isActive &&
                        navSearch.selectedDestination != null)
                      _buildDestinationCardUI(
                        context,
                        navSearch,
                        navSession,
                        mapPrefs,
                      ),
                  ],
                ),
              ),

              if (!navSession.isActive)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'myLocBtn',
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiary.withOpacity(0.8),
                    onPressed: () {
                      setState(() {
                        _followUser = true;
                      });
                      mapPrefs.setAutoCenterMap(true);
                      _targetZoom = _getZoom(gpsProvider.speed);
                    },
                    child: const Icon(Icons.my_location, size: 28),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatArrivalTime(double etaSeconds) {
    final arrival = DateTime.now().add(Duration(seconds: etaSeconds.toInt()));
    final hour = arrival.hour > 12
        ? arrival.hour - 12
        : (arrival.hour == 0 ? 12 : arrival.hour);
    final amPm = arrival.hour >= 12 ? 'PM' : 'AM';
    final min = arrival.minute.toString().padLeft(2, '0');
    return '$hour:$min $amPm';
  }

  Widget _buildActiveNavigationUI(
    BuildContext context,
    NavigationSessionProvider navSession,
    SpeedProvider gpsProvider,
    MapSettingsProvider mapPrefs,
  ) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                navSession.currentInstruction?.maneuverType == 'turn'
                    ? Icons.turn_right
                    : Icons.straight,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      navSession.currentInstruction?.instruction ??
                          'Proceed to route',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'In ${navSession.currentInstruction?.distanceToManeuver.toStringAsFixed(0) ?? 0} m',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => navSession.stopNavigation(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavStat(
                context,
                'Dist',
                '${(navSession.distanceRemaining / 1000).toStringAsFixed(1)} ${mapPrefs.distanceUnit == 'Kilometers' ? 'km' : 'mi'}',
              ),
              _buildNavStat(
                context,
                'ETA',
                '${(navSession.etaSeconds / 60).toStringAsFixed(0)} min',
              ),
              _buildNavStat(
                context,
                'Arr',
                _formatArrivalTime(navSession.etaSeconds),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCardUI(
    BuildContext context,
    NavigationSearchProvider navSearch,
    NavigationSessionProvider navSession,
    MapSettingsProvider mapPrefs,
  ) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  navSearch.selectedDestination!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  navSearch.clearDestination();
                  setState(() => _followUser = true);
                },
              ),
            ],
          ),
          if (navSearch.selectedDestination!.route != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavStat(
                  context,
                  'Dist',
                  '${(navSearch.selectedDestination!.route!.totalDistance / 1000).toStringAsFixed(1)} ${mapPrefs.distanceUnit == 'Kilometers' ? 'km' : 'mi'}',
                ),
                _buildNavStat(
                  context,
                  'ETA',
                  '${(navSearch.selectedDestination!.route!.totalDuration / 60).toStringAsFixed(0)} min',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => navSession.startNavigation(
                  navSearch.selectedDestination!.route!,
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildNavStat(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.inversePrimary.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
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

class _SearchSheet extends StatefulWidget {
  const _SearchSheet();

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navSearch = context.watch<NavigationSearchProvider>();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search destination...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  navSearch.search('');
                },
              ),
              filled: true,
              fillColor: cs.secondary.withOpacity(0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: navSearch.search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: navSearch.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.text.isEmpty
                ? _buildRecentSearches(navSearch)
                : _buildSearchResults(navSearch),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(NavigationSearchProvider navSearch) {
    if (navSearch.recentSearches.isEmpty) {
      return const Center(child: Text('No recent searches'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT SEARCHES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Theme.of(
              context,
            ).colorScheme.inversePrimary.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: navSearch.recentSearches.length,
            itemBuilder: (ctx, i) {
              final loc = navSearch.recentSearches[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  loc.name.isNotEmpty
                      ? loc.name
                      : loc.displayName.split(',').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  loc.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  navSearch.selectSearchResult(loc);
                  Navigator.pop(context);
                  _triggerRouteCalc(context, loc);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(NavigationSearchProvider navSearch) {
    if (navSearch.results.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return ListView.builder(
      itemCount: navSearch.results.length,
      itemBuilder: (ctx, i) {
        final loc = navSearch.results[i];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(
            loc.name.isNotEmpty ? loc.name : loc.displayName.split(',').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            loc.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            navSearch.selectSearchResult(loc);
            Navigator.pop(context);
            _triggerRouteCalc(context, loc);
          },
        );
      },
    );
  }

  void _triggerRouteCalc(BuildContext context, SearchLocation loc) async {
    final mapState = context.findAncestorStateOfType<_MapPageState>();
    if (mapState != null) {
      final dest = DestinationModel(
        name: loc.name.isNotEmpty ? loc.name : loc.displayName.split(',').first,
        location: loc.location,
      );
      mapState._calculateRouteForDestination(context, dest);
    }
  }
}
