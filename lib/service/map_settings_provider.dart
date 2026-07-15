import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapSettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Map Appearance
  String _mapTheme = 'Default';
  bool _showBuildings = true;
  bool _showLabels = true;
  bool _showCompass = true;
  bool _showScaleBar = true;

  // Navigation Settings
  bool _enableNavigation = true;
  bool _autoRecalculateRoute = true;
  bool _snapToRoad = true;
  bool _voiceGuidance = false;
  bool _keepScreenAwakeNav = true;
  String _routingProfile = 'Motorcycle';

  // Map Behavior
  bool _autoCenterMap = true;
  bool _followRiderPosition = true;
  bool _rotateMapWithHeading = true;
  bool _showCurrentSpeed = true;
  bool _showGpsAccuracyRing = true;

  // Route Display
  bool _showRouteLine = true;
  double _routeLineWidth = 5.0;
  double _routeTransparency = 0.8;

  // Units
  String _speedUnit = 'KM/H';
  String _distanceUnit = 'Kilometers';

  MapSettingsProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    _mapTheme = prefs.getString('mapTheme') ?? 'Default';
    _showBuildings = prefs.getBool('showBuildings') ?? true;
    _showLabels = prefs.getBool('showLabels') ?? true;
    _showCompass = prefs.getBool('showCompass') ?? true;
    _showScaleBar = prefs.getBool('showScaleBar') ?? true;

    _enableNavigation = prefs.getBool('enableNavigation') ?? true;
    _autoRecalculateRoute = prefs.getBool('autoRecalculateRoute') ?? true;
    _snapToRoad = prefs.getBool('snapToRoad') ?? true;
    _voiceGuidance = prefs.getBool('voiceGuidance') ?? false;
    _keepScreenAwakeNav = prefs.getBool('keepScreenAwakeNav') ?? true;
    _routingProfile = prefs.getString('routingProfile') ?? 'Motorcycle';

    _autoCenterMap = prefs.getBool('autoCenterMap') ?? true;
    _followRiderPosition = prefs.getBool('followRiderPosition') ?? true;
    _rotateMapWithHeading = prefs.getBool('rotateMapWithHeading') ?? true;
    _showCurrentSpeed = prefs.getBool('showCurrentSpeed') ?? true;
    _showGpsAccuracyRing = prefs.getBool('showGpsAccuracyRing') ?? true;

    _showRouteLine = prefs.getBool('showRouteLine') ?? true;
    _routeLineWidth = prefs.getDouble('routeLineWidth') ?? 5.0;
    _routeTransparency = prefs.getDouble('routeTransparency') ?? 0.8;

    _speedUnit = prefs.getString('speedUnit') ?? 'KM/H';
    _distanceUnit = prefs.getString('distanceUnit') ?? 'Kilometers';

    notifyListeners();
  }

  // Getters
  String get mapTheme => _mapTheme;
  bool get showBuildings => _showBuildings;
  bool get showLabels => _showLabels;
  bool get showCompass => _showCompass;
  bool get showScaleBar => _showScaleBar;
  bool get enableNavigation => _enableNavigation;
  bool get autoRecalculateRoute => _autoRecalculateRoute;
  bool get snapToRoad => _snapToRoad;
  bool get voiceGuidance => _voiceGuidance;
  bool get keepScreenAwakeNav => _keepScreenAwakeNav;
  String get routingProfile => _routingProfile;
  bool get autoCenterMap => _autoCenterMap;
  bool get followRiderPosition => _followRiderPosition;
  bool get rotateMapWithHeading => _rotateMapWithHeading;
  bool get showCurrentSpeed => _showCurrentSpeed;
  bool get showGpsAccuracyRing => _showGpsAccuracyRing;
  bool get showRouteLine => _showRouteLine;
  double get routeLineWidth => _routeLineWidth;
  double get routeTransparency => _routeTransparency;
  String get speedUnit => _speedUnit;
  String get distanceUnit => _distanceUnit;

  // Setters
  void setMapTheme(String value) {
    _mapTheme = value;
    _prefs?.setString('mapTheme', value);
    notifyListeners();
  }

  void setShowBuildings(bool value) {
    _showBuildings = value;
    _prefs?.setBool('showBuildings', value);
    notifyListeners();
  }

  void setShowLabels(bool value) {
    _showLabels = value;
    _prefs?.setBool('showLabels', value);
    notifyListeners();
  }

  void setShowCompass(bool value) {
    _showCompass = value;
    _prefs?.setBool('showCompass', value);
    notifyListeners();
  }

  void setShowScaleBar(bool value) {
    _showScaleBar = value;
    _prefs?.setBool('showScaleBar', value);
    notifyListeners();
  }

  void setEnableNavigation(bool value) {
    _enableNavigation = value;
    _prefs?.setBool('enableNavigation', value);
    notifyListeners();
  }

  void setAutoRecalculateRoute(bool value) {
    _autoRecalculateRoute = value;
    _prefs?.setBool('autoRecalculateRoute', value);
    notifyListeners();
  }

  void setSnapToRoad(bool value) {
    _snapToRoad = value;
    _prefs?.setBool('snapToRoad', value);
    notifyListeners();
  }

  void setVoiceGuidance(bool value) {
    _voiceGuidance = value;
    _prefs?.setBool('voiceGuidance', value);
    notifyListeners();
  }

  void setKeepScreenAwakeNav(bool value) {
    _keepScreenAwakeNav = value;
    _prefs?.setBool('keepScreenAwakeNav', value);
    notifyListeners();
  }

  void setRoutingProfile(String value) {
    _routingProfile = value;
    _prefs?.setString('routingProfile', value);
    notifyListeners();
  }

  void setAutoCenterMap(bool value) {
    _autoCenterMap = value;
    _prefs?.setBool('autoCenterMap', value);
    notifyListeners();
  }

  void setFollowRiderPosition(bool value) {
    _followRiderPosition = value;
    _prefs?.setBool('followRiderPosition', value);
    notifyListeners();
  }

  void setRotateMapWithHeading(bool value) {
    _rotateMapWithHeading = value;
    _prefs?.setBool('rotateMapWithHeading', value);
    notifyListeners();
  }

  void setShowCurrentSpeed(bool value) {
    _showCurrentSpeed = value;
    _prefs?.setBool('showCurrentSpeed', value);
    notifyListeners();
  }

  void setShowGpsAccuracyRing(bool value) {
    _showGpsAccuracyRing = value;
    _prefs?.setBool('showGpsAccuracyRing', value);
    notifyListeners();
  }

  void setShowRouteLine(bool value) {
    _showRouteLine = value;
    _prefs?.setBool('showRouteLine', value);
    notifyListeners();
  }

  void setRouteLineWidth(double value) {
    _routeLineWidth = value;
    _prefs?.setDouble('routeLineWidth', value);
    notifyListeners();
  }

  void setRouteTransparency(double value) {
    _routeTransparency = value;
    _prefs?.setDouble('routeTransparency', value);
    notifyListeners();
  }

  void setSpeedUnit(String value) {
    _speedUnit = value;
    _prefs?.setString('speedUnit', value);
    notifyListeners();
  }

  void setDistanceUnit(String value) {
    _distanceUnit = value;
    _prefs?.setString('distanceUnit', value);
    notifyListeners();
  }
}
