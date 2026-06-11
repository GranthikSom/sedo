import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SpeedProvider extends ChangeNotifier {
  double _speed = 0;
  Position? _currentPosition;

  StreamSubscription<Position>? _positionStream;

  // Ride Stats
  double _maxSpeed = 0;
  double _totalSpeed = 0;
  int _speedSamples = 0;

  double _distanceTravelled = 0;
  Position? _lastPosition;

  final DateTime _rideStartTime = DateTime.now();

  double get speed => _speed;

  double get maxSpeed => _maxSpeed;

  double get averageSpeed =>
      _speedSamples == 0 ? 0 : _totalSpeed / _speedSamples;

  double get distanceTravelled => _distanceTravelled;

  Position? get currentPosition => _currentPosition;

  Duration get rideDuration => DateTime.now().difference(_rideStartTime);

  String get formattedRideTime {
    final duration = rideDuration;

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

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
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          ),
        ).listen((Position position) {
          _currentPosition = position;

          double speedKmh = position.speed * 3.6;

          if (speedKmh < 2) {
            speedKmh = 0;
          }

          _speed = speedKmh;

          // Max Speed
          if (_speed > _maxSpeed) {
            _maxSpeed = _speed;
          }

          // Average Speed
          _totalSpeed += _speed;
          _speedSamples++;

          // Distance Travelled
          if (_lastPosition != null) {
            _distanceTravelled += Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
          }

          _lastPosition = position;

          notifyListeners();
        });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
