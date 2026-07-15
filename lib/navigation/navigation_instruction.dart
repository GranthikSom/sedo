import 'package:latlong2/latlong.dart';

class NavigationInstruction {
  final String instruction;
  final double distanceToManeuver; // meters
  final String maneuverType; // e.g., 'turn', 'roundabout', 'arrive'
  final String modifier; // e.g., 'left', 'right', 'straight'
  final LatLng location;

  NavigationInstruction({
    required this.instruction,
    required this.distanceToManeuver,
    required this.maneuverType,
    required this.modifier,
    required this.location,
  });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] ?? {};
    final loc = maneuver['location'] as List<dynamic>? ?? [0.0, 0.0];
    
    // OSRM provides [longitude, latitude]
    final latLng = LatLng(loc[1].toDouble(), loc[0].toDouble());
    
    // Construct simple instruction since OSRM step instructions might not be provided directly in all profiles
    String type = maneuver['type'] ?? 'continue';
    String mod = maneuver['modifier'] ?? 'straight';
    
    String instructionText = 'Continue straight';
    if (type == 'turn') {
      instructionText = 'Turn $mod';
    } else if (type == 'arrive') {
      instructionText = 'Destination ahead';
    } else if (type == 'roundabout') {
      instructionText = 'Roundabout exit';
    } else {
      instructionText = '${type[0].toUpperCase()}${type.substring(1)} $mod';
    }

    return NavigationInstruction(
      instruction: instructionText,
      distanceToManeuver: (json['distance'] ?? 0).toDouble(),
      maneuverType: type,
      modifier: mod,
      location: latLng,
    );
  }
}
