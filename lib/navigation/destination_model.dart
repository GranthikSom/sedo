import 'package:latlong2/latlong.dart';
import 'route_model.dart';

// ponytail: model to hold destination data and its route before navigation starts
class DestinationModel {
  final String name;
  final LatLng location;
  final RouteModel? route;

  DestinationModel({
    required this.name,
    required this.location,
    this.route,
  });

  DestinationModel copyWith({
    String? name,
    LatLng? location,
    RouteModel? route,
  }) {
    return DestinationModel(
      name: name ?? this.name,
      location: location ?? this.location,
      route: route ?? this.route,
    );
  }
}
