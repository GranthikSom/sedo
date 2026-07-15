import 'package:latlong2/latlong.dart';
import 'navigation_provider.dart';
import 'route_model.dart';

class RerouteService {
  static Future<RouteModel?> triggerReroute(LatLng currentLoc, LatLng destination, String profile) async {
    print('RerouteService: Triggering recalculation...');
    return await NavigationProvider.fetchRoute(
      start: currentLoc,
      destination: destination,
      profile: profile,
    );
  }
}
