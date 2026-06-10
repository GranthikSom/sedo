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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SpeedProvider>().startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedProvider>(
      builder: (context, gpsProvider, child) {
        final position = gpsProvider.currentPosition;

        if (position == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final riderLocation = LatLng(position.latitude, position.longitude);

        return Scaffold(
          body: ClipRRect(
            //borderRadius: BorderRadius.circular(20),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: riderLocation,
                initialZoom: 16,
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
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.navigation,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
