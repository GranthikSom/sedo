import 'package:latlong2/latlong.dart';
import 'navigation_instruction.dart';

class RouteModel {
  final List<LatLng> polyline;
  final double totalDistance; // meters
  final double totalDuration; // seconds
  final List<NavigationInstruction> instructions;
  final LatLng destination;

  RouteModel({
    required this.polyline,
    required this.totalDistance,
    required this.totalDuration,
    required this.instructions,
    required this.destination,
  });

  factory RouteModel.fromOsrmJson(Map<String, dynamic> json, LatLng dest) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No routes found');
    }

    final route = routes.first;
    final geometry = route['geometry'];
    
    List<LatLng> coords = [];
    if (geometry != null && geometry['coordinates'] != null) {
      for (var coord in geometry['coordinates']) {
        coords.add(LatLng(coord[1].toDouble(), coord[0].toDouble())); // OSRM gives lon, lat
      }
    }

    List<NavigationInstruction> steps = [];
    final legs = route['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      final leg = legs.first;
      final legSteps = leg['steps'] as List<dynamic>?;
      if (legSteps != null) {
        for (var step in legSteps) {
          steps.add(NavigationInstruction.fromJson(step));
        }
      }
    }

    return RouteModel(
      polyline: coords,
      totalDistance: (route['distance'] ?? 0).toDouble(),
      totalDuration: (route['duration'] ?? 0).toDouble(),
      instructions: steps,
      destination: dest,
    );
  }
}
