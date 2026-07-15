import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'route_model.dart';
import 'navigation_instruction.dart';
import 'route_progress_service.dart';
import 'reroute_service.dart';
import 'voice_navigation_service.dart';

class NavigationSessionProvider extends ChangeNotifier {
  final VoiceNavigationService _voiceService = VoiceNavigationService();
  
  bool _isActive = false;
  RouteModel? _currentRoute;
  NavigationInstruction? _currentInstruction;
  double _distanceRemaining = 0.0;
  double _etaSeconds = 0.0;
  LatLng? _snappedLocation;
  bool _isOffRoute = false;
  bool _isRerouting = false;

  bool get isActive => _isActive;
  RouteModel? get currentRoute => _currentRoute;
  NavigationInstruction? get currentInstruction => _currentInstruction;
  double get distanceRemaining => _distanceRemaining;
  double get etaSeconds => _etaSeconds;
  LatLng? get snappedLocation => _snappedLocation;
  bool get isOffRoute => _isOffRoute;
  bool get isRerouting => _isRerouting;

  void startNavigation(RouteModel route) {
    _isActive = true;
    _currentRoute = route;
    _distanceRemaining = route.totalDistance;
    _etaSeconds = route.totalDuration;
    if (route.instructions.isNotEmpty) {
      _currentInstruction = route.instructions.first;
    }
    _voiceService.init();
    notifyListeners();
  }

  void stopNavigation() {
    _isActive = false;
    _currentRoute = null;
    _currentInstruction = null;
    _distanceRemaining = 0.0;
    _etaSeconds = 0.0;
    _snappedLocation = null;
    _isOffRoute = false;
    _voiceService.stop();
    notifyListeners();
  }

  void updateLocation(LatLng currentLoc, String routingProfile) async {
    if (!_isActive || _currentRoute == null || _isRerouting) return;

    final progress = RouteProgressService.calculateProgress(currentLoc, _currentRoute!.polyline);
    
    _distanceRemaining = progress.distanceRemaining;
    _etaSeconds = progress.etaSeconds;
    _snappedLocation = progress.snappedLocation;
    
    if (progress.isOffRoute && !_isOffRoute) {
      _isOffRoute = true;
      notifyListeners();
      
      // Trigger reroute
      _isRerouting = true;
      final newRoute = await RerouteService.triggerReroute(currentLoc, _currentRoute!.destination, routingProfile);
      _isRerouting = false;
      
      if (newRoute != null) {
        startNavigation(newRoute);
      } else {
        notifyListeners();
      }
      return;
    } else if (!progress.isOffRoute) {
      _isOffRoute = false;
    }

    // Update current instruction based on closest distance
    if (_currentRoute!.instructions.isNotEmpty) {
      NavigationInstruction closestInst = _currentRoute!.instructions.first;
      double minDist = double.infinity;
      
      for (var inst in _currentRoute!.instructions) {
        // Simple heuristic: if we have passed the instruction, its distance will be increasing
        // Better way: find the instruction closest to our snapped location ahead of us
        double dist = RouteProgressService.calculateProgress(currentLoc, [inst.location, currentLoc]).distanceRemaining;
        if (dist < minDist) {
          minDist = dist;
          closestInst = inst;
        }
      }
      
      if (_currentInstruction != closestInst && minDist < 2000) { // arbitrary lookahead
         _currentInstruction = closestInst;
         _voiceService.speak(_currentInstruction!.instruction);
      }
    }

    notifyListeners();
  }
}
