import 'package:latlong2/latlong.dart';

// ponytail: basic search location model for geocoding
class SearchLocation {
  final String name;
  final String displayName;
  final LatLng location;

  SearchLocation({
    required this.name,
    required this.displayName,
    required this.location,
  });

  factory SearchLocation.fromJson(Map<String, dynamic> json) {
    return SearchLocation(
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      location: LatLng(
        double.tryParse(json['lat'].toString()) ?? 0.0,
        double.tryParse(json['lon'].toString()) ?? 0.0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'display_name': displayName,
    'lat': location.latitude.toString(),
    'lon': location.longitude.toString(),
  };
}
