import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

// ponytail: single-file tile cache — no repo/service split, just what's needed

class DownloadProgress {
  final int completed;
  final int total;
  const DownloadProgress(this.completed, this.total);

  double get percent => total == 0 ? 0 : completed / total;
}

class CachedTileImageProvider extends ImageProvider<CachedTileImageProvider> {
  final String url;
  final File cacheFile;

  const CachedTileImageProvider(this.url, this.cacheFile);

  @override
  Future<CachedTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(ImageDecoderCallback decode) async {
    Uint8List bytes;

    if (cacheFile.existsSync()) {
      bytes = await cacheFile.readAsBytes();
    } else {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set('User-Agent', 'sedo/1.0');
        final response = await request.close();
        bytes = await consolidateHttpClientResponseBytes(response);
      } finally {
        client.close();
      }
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsBytes(bytes);
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedTileImageProvider && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

class CachingTileProvider extends TileProvider {
  final String cacheDir;

  CachingTileProvider({required this.cacheDir});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedTileImageProvider(
      getTileUrl(coordinates, options),
      File('$cacheDir/${coordinates.z}/${coordinates.x}/${coordinates.y}.png'),
    );
  }
}

// ponytail: static utility — no singleton, no DI, just functions on a class
class OfflineMapManager {
  OfflineMapManager._();

  static Future<String> get cacheDirPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/tile_cache';
  }

  static Future<CachingTileProvider> createProvider() async {
    return CachingTileProvider(cacheDir: await cacheDirPath);
  }

  static Future<int> getCacheSizeMB() async {
    final dir = Directory(await cacheDirPath);
    if (!dir.existsSync()) return 0;
    int totalBytes = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes ~/ (1024 * 1024);
  }

  static Future<int> getTileCount() async {
    final dir = Directory(await cacheDirPath);
    if (!dir.existsSync()) return 0;
    int count = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.png')) {
        count++;
      }
    }
    return count;
  }

  static Future<void> clearCache() async {
    final dir = Directory(await cacheDirPath);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  static Stream<DownloadProgress> downloadRegion({
    required double lat,
    required double lng,
    required double radiusKm,
    int minZoom = 10,
    int maxZoom = 16,
  }) async* {
    final cacheDir = await cacheDirPath;

    // Bounding box from center + radius
    final latDelta = radiusKm / 111.32;
    final lngDelta = radiusKm / (111.32 * cos(lat * pi / 180));
    final minLat = lat - latDelta;
    final maxLat = lat + latDelta;
    final minLng = lng - lngDelta;
    final maxLng = lng + lngDelta;

    // Collect all tile coordinates
    final tiles = <(int, int, int)>[];
    for (int z = minZoom; z <= maxZoom; z++) {
      final n = pow(2, z).toDouble();
      final xMin = _lngToTileX(minLng, n);
      final xMax = _lngToTileX(maxLng, n);
      final yMin = _latToTileY(maxLat, n); // note: y is inverted
      final yMax = _latToTileY(minLat, n);
      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          tiles.add((z, x, y));
        }
      }
    }

    final total = tiles.length;
    yield DownloadProgress(0, total);

    final client = HttpClient();
    try {
      int completed = 0;
      for (final (z, x, y) in tiles) {
        final file = File('$cacheDir/$z/$x/$y.png');
        if (!file.existsSync()) {
          final url = 'https://tile.openstreetmap.org/$z/$x/$y.png';
          final request = await client.getUrl(Uri.parse(url));
          request.headers.set('User-Agent', 'sedo/1.0');
          final response = await request.close();
          final bytes = await consolidateHttpClientResponseBytes(response);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes);
        }
        completed++;
        yield DownloadProgress(completed, total);
      }
    } finally {
      client.close();
    }
  }

  // OSM slippy map math
  static int _lngToTileX(double lng, double n) {
    return ((lng + 180) / 360 * n).floor();
  }

  static int _latToTileY(double lat, double n) {
    final latRad = lat * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n).floor();
  }
}
