import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'search_location.dart';
import 'destination_model.dart';
import 'geocoding_service.dart';

// ponytail: combined search state and selected destination state
class NavigationSearchProvider extends ChangeNotifier {
  String _query = '';
  bool _isLoading = false;
  List<SearchLocation> _results = [];
  List<SearchLocation> _recentSearches = [];
  DestinationModel? _selectedDestination;
  
  Timer? _debounce;
  SharedPreferences? _prefs;

  NavigationSearchProvider() {
    _loadRecents();
  }

  String get query => _query;
  bool get isLoading => _isLoading;
  List<SearchLocation> get results => _results;
  List<SearchLocation> get recentSearches => _recentSearches;
  DestinationModel? get selectedDestination => _selectedDestination;

  Future<void> _loadRecents() async {
    _prefs = await SharedPreferences.getInstance();
    final recentsJson = _prefs?.getStringList('recent_searches') ?? [];
    try {
      _recentSearches = recentsJson
          .map((e) => SearchLocation.fromJson(jsonDecode(e)))
          .toList();
    } catch (_) {}
    notifyListeners();
  }

  void _saveRecent(SearchLocation loc) {
    _recentSearches.removeWhere((e) => e.displayName == loc.displayName);
    _recentSearches.insert(0, loc);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    final jsonList = _recentSearches.map((e) => jsonEncode(e.toJson())).toList();
    _prefs?.setStringList('recent_searches', jsonList);
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    _isLoading = true;
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      _results = await GeocodingService.search(query);
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectSearchResult(SearchLocation loc) {
    _saveRecent(loc);
    _selectedDestination = DestinationModel(
      name: loc.name.isNotEmpty ? loc.name : loc.displayName.split(',').first,
      location: loc.location,
    );
    notifyListeners();
  }

  void setDestination(DestinationModel dest) {
    _selectedDestination = dest;
    notifyListeners();
  }

  void clearDestination() {
    _selectedDestination = null;
    notifyListeners();
  }
}
