import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sedo/service/gps_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  bool _mapInitialized = false;

  void _updateCamera(LatLng riderLocation, double heading) {
    final zoom = _mapController.camera.zoom == 0
        ? 16.0
        : _mapController.camera.zoom;

    if (!_mapInitialized) {
      _mapController.move(riderLocation, 16);

      _mapController.rotate(heading);

      _mapInitialized = true;
      return;
    }

    const Distance distance = Distance();

    final meters = distance(_mapController.camera.center, riderLocation);

    if (meters > 40) {
      final latOffset = 0.0015;

      final shiftedCenter = LatLng(
        riderLocation.latitude + latOffset,
        riderLocation.longitude,
      );

      _mapController.move(shiftedCenter, zoom);
    }

    _mapController.rotate(heading);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedProvider>(
      builder: (context, gpsProvider, child) {
        final position = gpsProvider.currentPosition;

        if (position == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final riderLocation = LatLng(position.latitude, position.longitude);

        final heading = position.heading.isNaN ? 0.0 : position.heading;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateCamera(riderLocation, heading);
        });

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: riderLocation,
            initialZoom: 16,
            initialRotation: heading,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
        );
      },
    );
  }
}
