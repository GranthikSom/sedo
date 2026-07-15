import 'dart:convert';
import 'dart:io';
import 'search_location.dart';

// ponytail: basic nominatim geocoding via standard HttpClient
class GeocodingService {
  static Future<List<SearchLocation>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=jsonv2';
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'sedo/1.0');
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final List<dynamic> json = jsonDecode(stringData);
        return json.map((e) => SearchLocation.fromJson(e)).toList();
      }
    } catch (e) {
      print('Geocoding error: $e');
    } finally {
      client.close();
    }
    return [];
  }
}
