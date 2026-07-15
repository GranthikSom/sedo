import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'route_model.dart';

class NavigationProvider {
  // OSRM Public Demo Server (for production, host your own OSRM instance)
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';

  /// Fetches a route from [start] to [destination] using the specified [profile].
  /// Profile can be 'driving', 'bike', 'foot' (OSRM public server uses driving by default)
  static Future<RouteModel?> fetchRoute({
    required LatLng start,
    required LatLng destination,
    String profile = 'driving',
  }) async {
    // OSRM coordinates are lon,lat
    final String coords = '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}';
    final String url = '$_baseUrl/$profile/$coords?overview=full&geometries=geojson&steps=true';

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'sedo/1.0');
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        if (json['code'] == 'Ok') {
          return RouteModel.fromOsrmJson(json, destination);
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    } finally {
      client.close();
    }
    return null;
  }
}
