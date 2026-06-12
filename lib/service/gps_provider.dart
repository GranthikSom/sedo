import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SpeedProvider extends ChangeNotifier {
  double _speed = 0;
  Position? _currentPosition;

  StreamSubscription<Position>? _positionStream;
  Timer? _uiTimer;

  // Ride Stats
  double _maxSpeed = 0;
  double _totalSpeed = 0;
  int _speedSamples = 0;

  double _distanceTravelled = 0;
  Position? _lastPosition;

  DateTime _rideStartTime = DateTime.now();

  Duration _pausedDuration = Duration.zero;
  DateTime? _pauseStartedAt;

  bool _isPaused = false;

  double get speed => _speed;

  double get maxSpeed => _maxSpeed;

  double get averageSpeed =>
      _speedSamples == 0 ? 0 : _totalSpeed / _speedSamples;

  double get distanceTravelled => _distanceTravelled;

  Position? get currentPosition => _currentPosition;

  bool get isPaused => _isPaused;

  Duration get rideDuration {
    if (_isPaused && _pauseStartedAt != null) {
      return _pauseStartedAt!.difference(_rideStartTime) - _pausedDuration;
    }

    return DateTime.now().difference(_rideStartTime) - _pausedDuration;
  }

  String get formattedRideTime {
    final d = rideDuration;

    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes % 60}m";
    }

    return "${d.inMinutes}m ${d.inSeconds % 60}s";
  }

  // ==========================
  // GPS TRACKING
  // ==========================

  Future<void> startTracking() async {
    // Prevent duplicate streams
    if (_positionStream != null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // UI timer for stopwatch updates
    _uiTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          ),
        ).listen((Position position) {
          _currentPosition = position;

          if (_isPaused) {
            _speed = 0;
            notifyListeners();
            return;
          }

          double speedKmh = position.speed * 3.6;

          if (speedKmh < 2) {
            speedKmh = 0;
          }

          _speed = speedKmh;

          // MAX SPEED
          if (_speed > _maxSpeed) {
            _maxSpeed = _speed;
          }

          // AVERAGE SPEED
          _totalSpeed += _speed;
          _speedSamples++;

          // DISTANCE
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

  // ==========================
  // PAUSE / RESUME
  // ==========================

  void togglePause() {
    if (_isPaused) {
      // Resume

      if (_pauseStartedAt != null) {
        _pausedDuration += DateTime.now().difference(_pauseStartedAt!);
      }

      _pauseStartedAt = null;
      _isPaused = false;
    } else {
      // Pause

      _pauseStartedAt = DateTime.now();
      _isPaused = true;

      _speed = 0;
    }

    notifyListeners();
  }

  // ==========================
  // RESET
  // ==========================

  void resetStats() {
    _maxSpeed = 0;

    _totalSpeed = 0;
    _speedSamples = 0;

    _distanceTravelled = 0;

    _rideStartTime = DateTime.now();

    _pausedDuration = Duration.zero;
    _pauseStartedAt = null;

    _lastPosition = _currentPosition;

    _speed = 0;

    notifyListeners();
  }

  // ==========================
  // CLEANUP
  // ==========================

  @override
  void dispose() {
    _positionStream?.cancel();
    _uiTimer?.cancel();

    super.dispose();
  }
}
