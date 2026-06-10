import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SpeedProvider extends ChangeNotifier {
  double _speed = 0;
  Position? _currentPosition;

  StreamSubscription<Position>? _positionStream;

  double get speed => _speed;

  Position? get currentPosition => _currentPosition;

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        ).listen((Position position) {
          _currentPosition = position;

          double speedKmh = position.speed * 3.6;

          if (speedKmh < 2) {
            speedKmh = 0;
          }

          _speed = speedKmh;

          notifyListeners();
        });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
