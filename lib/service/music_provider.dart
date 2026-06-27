import 'package:flutter/services.dart';

class MediaController {
  static const MethodChannel _channel = MethodChannel('sedo/media');

  void setOnNowPlayingChanged(void Function() onChanged) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'nowPlayingChanged') {
        onChanged();
      }
    });
  }

  Future<void> playPause() async {
    try {
      await _channel.invokeMethod('playPause');
    } on PlatformException catch (e) {
      _log('playPause failed: ${e.message}');
    } on MissingPluginException catch (e) {
      _log('MissingPluginException on playPause: ${e.message}');
    }
  }

  Future<void> next() async {
    try {
      await _channel.invokeMethod('next');
    } on PlatformException catch (e) {
      _log('next failed: ${e.message}');
    } on MissingPluginException catch (e) {
      _log('MissingPluginException on next: ${e.message}');
    }
  }

  Future<void> previous() async {
    try {
      await _channel.invokeMethod('previous');
    } on PlatformException catch (e) {
      _log('previous failed: ${e.message}');
    } on MissingPluginException catch (e) {
      _log('MissingPluginException on previous: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> nowPlaying() async {
    try {
      final result = await _channel.invokeMethod<Map>('nowPlaying');

      if (result == null) {
        return _unknown();
      }

      return {
        'title': result['title'] ?? 'Unknown',
        'artist': result['artist'] ?? 'Unknown',
      };
    } on PlatformException catch (e) {
      _log('nowPlaying failed: ${e.message}');
      return _unknown();
    } on MissingPluginException catch (e) {
      _log('MissingPluginException on nowPlaying: ${e.message}');
      return _unknown();
    }
  }

  Map<String, dynamic> _unknown() {
    return {'title': 'Unknown', 'artist': 'Unknown'};
  }

  void _log(String msg) {
    print('[MediaController] $msg');
  }
}
