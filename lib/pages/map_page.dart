import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
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

  double _filteredHeading = 0;

  LatLng? _targetCenter;

  Ticker? _ticker;

  LatLng _getNavigationCenter(LatLng rider, double heading, double speed) {
    final offsetMeters = speed < 5 ? 0.0 : (speed * 2).clamp(0.0, 200.0);

    final bearing = (heading + 180) * math.pi / 180;

    final dLat = (offsetMeters / 111111) * math.cos(bearing);

    final dLng =
        (offsetMeters / (111111 * math.cos(rider.latitude * math.pi / 180))) *
        math.sin(bearing);

    return LatLng(rider.latitude + dLat, rider.longitude + dLng);
  }

  double _getZoom(double speed) {
    if (speed < 20) return 18;
    if (speed < 50) return 17;
    if (speed < 90) return 16;
    return 15;
  }

  void _updateCameraTarget(LatLng riderLocation, double heading, double speed) {
    _filteredHeading = (_filteredHeading * 0.92) + (heading * 0.08);

    _targetCenter = _getNavigationCenter(
      riderLocation,
      _filteredHeading,
      speed,
    );

    if (!_mapInitialized) {
      _mapController.move(_targetCenter!, _getZoom(speed));

      _mapController.rotate(_filteredHeading);

      _mapInitialized = true;
      return;
    }

    if (_followUser) {
      final targetZoom = _getZoom(speed);

      if ((_mapController.camera.zoom - targetZoom).abs() > 0.1) {
        _mapController.move(_mapController.camera.center, targetZoom);
      }

      _mapController.rotate(_filteredHeading);
    }
  }

  @override
  void initState() {
    super.initState();

    _ticker = Ticker((_) {
      if (!_mapInitialized) return;
      if (!_followUser) return;
      if (_targetCenter == null) return;

      final current = _mapController.camera.center;

      final lat =
          current.latitude +
          (_targetCenter!.latitude - current.latitude) * 0.10;

      final lng =
          current.longitude +
          (_targetCenter!.longitude - current.longitude) * 0.10;

      _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
    });

    _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
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

        final riderLocation = LatLng(position.latitude, position.longitude);

        final heading = gpsProvider.speed < 5
            ? _filteredHeading
            : (position.heading.isNaN ? _filteredHeading : position.heading);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateCameraTarget(riderLocation, heading, gpsProvider.speed);
        });

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: riderLocation,
                  initialZoom: 18,

                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      _followUser = false;
                    }
                  },

                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),

                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.granthiksom.sedo',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: riderLocation,
                        width: 70,
                        height: 70,
                        child: Transform.rotate(
                          angle: heading * math.pi / 180,
                          child: const Icon(
                            Icons.navigation,
                            size: 45,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiary.withOpacity(0.8),

                  onPressed: () {
                    _followUser = true;

                    if (_targetCenter != null) {
                      _mapController.move(
                        _targetCenter!,
                        _getZoom(gpsProvider.speed),
                      );

                      _mapController.rotate(_filteredHeading);
                    }
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
