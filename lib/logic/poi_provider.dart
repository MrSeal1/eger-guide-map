import 'package:flutter/material.dart';
import '../data/models/poi.dart';
import '../data/repositories/poi_repository.dart';

class PoiProvider extends ChangeNotifier {
  final PoiRepository _repository;

  List<Poi> _allPois = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // key: saját kategória név
  // value: Google API által használt nevek
  static const Map<String, List<String>> categoryMapping = {
    'attraction': ['tourist_attraction', 'historical_landmark', 'church'],
    'museum': ['museum'],
    'park': ['park', 'national_park'],
    'shopping': ['shopping_mall', 'supermarket', 'store'],
    'restaurant': ['restaurant', 'cafe', 'bar', 'bakery'],
  };

  List<Poi> get filteredPois {
    if (_selectedCategory == 'all') {
      return _allPois;
    }

    final allowedTypes = categoryMapping[_selectedCategory] ?? [];

    return _allPois.where((poi) {
      if(poi.types == null) return false;
      return poi.types!.any((type) => allowedTypes.contains(type));
    }).toList();
  }

  PoiProvider(this._repository);

  Poi? getPoiById(String id) {
    try {
      return _allPois.firstWhere((p) => p.placeId == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPois({double? lat, double? lng, int radius = 2000}) async {
    _isLoading = true;
    notifyListeners();

    final targetLat = lat ?? 47.9025;
    final targetLng = lng ?? 20.3772;

    final targetedTypes = categoryMapping.values.expand((types) => types).toList();

    try {
      _allPois = await _repository.getPois(
        lat: targetLat,
        lng: targetLng,
        radius: radius,
        includedTypes: targetedTypes,
      );
    } catch (e) {
      debugPrint("Hiba történt: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }
}
