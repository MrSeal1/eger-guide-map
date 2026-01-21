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

  List<Poi> get filteredPois {
    if(_selectedCategory == 'all') {
      return _allPois;
    }

    return _allPois.where((poi) {
      return poi.types != null && poi.types!.contains(_selectedCategory);
    }).toList();
  }

  List<Poi> get favoritePois {
    return _allPois.where((poi) => poi.isFavorite).toList();
  }


  PoiProvider(this._repository) {
    loadPois();
  }
  

  Future<void> loadPois({double? lat, double? lng, int radius = 2000}) async {
    _isLoading = true;
    notifyListeners();

    // alapból kb Eger közepéről olvas
    final targetLat = lat ?? 47.9025;
    final targetLng = lng ?? 20.3772;

    try {
      _allPois = await _repository.getPois(lat: targetLat, lng: targetLng, radius: radius);
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

  void toggleFavorite(String placeId) {
    final index = _allPois.indexWhere((p) => p.placeId == placeId);

    if(index != -1) {
      final oldPoi = _allPois[index];

      // mivel final az _allPois, kicseréljük a 'régit' egy újjal, csak a favorite megcserélve
      final newPoi = Poi(
        placeId: oldPoi.placeId,
        name: oldPoi.name,
        lat: oldPoi.lat,
        lng: oldPoi.lng,
        description: oldPoi.description,
        address: oldPoi.address,
        types: oldPoi.types,
        rating: oldPoi.rating,
        userRatingsTotal: oldPoi.userRatingsTotal,
        openNow: oldPoi.openNow,
        photoReferences: oldPoi.photoReferences,
        website: oldPoi.website,
        phoneNumber: oldPoi.phoneNumber,
        isFavorite: !oldPoi.isFavorite,
      );

      _allPois[index] = newPoi;

      notifyListeners();
    }
  }

  
}