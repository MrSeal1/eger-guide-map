import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';
import 'package:maps_testing/logic/services/location_service.dart';
import '../data/models/poi.dart';
import '../data/repositories/poi_repository.dart';

class PoiProvider extends ChangeNotifier {
  final PoiRepository _repository;
  final FirestoreService _firestoreService = FirestoreService();

  List<Poi> _allPois = [];
  List<Poi> _favorites = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<Poi> get filteredPois {
    if (_selectedCategory == 'all') {
      return _allPois;
    }

    return _allPois.where((poi) {
      return poi.types != null && poi.types!.contains(_selectedCategory);
    }).toList();
  }

  List<Poi> get favoritePois => _favorites;

  PoiProvider(this._repository) {
    _loadFavoritesFromDb();
  }

  Future<void> _loadFavoritesFromDb() async {
    _favorites = await _firestoreService.getFavorites();
    notifyListeners();
  }

  Poi? getPoiById(String id) {
    try {
      return _allPois.firstWhere((p) => p.placeId == id);
    } catch (_) {
      try {
        return _favorites.firstWhere((p) => p.placeId == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> loadPois({double? lat, double? lng, int radius = 2000}) async {
    _isLoading = true;
    notifyListeners();

    final targetLat = lat ?? 47.9025;
    final targetLng = lng ?? 20.3772;

    final targetedTypes = [
      'tourist_attraction',
      'museum',
      'park',
      'restaurant',
      'shopping_mall',
      'convenience_store',
    ];

    try {
      final fetchedPois = await _repository.getPois(
        lat: targetLat,
        lng: targetLng,
        radius: radius,
        includedTypes: targetedTypes,
      );
      _allPois = fetchedPois.map((poi) {
        final isFav = _favorites.any((fav) => fav.placeId == poi.placeId);
        return isFav ? _copyWithFavorite(poi, true) : poi;
      }).toList();
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
    Poi? targetPoi = getPoiById(placeId);
    if (targetPoi == null) return;

    final bool isCurrentlyFavorite = _favorites.any(
      (p) => p.placeId == placeId,
    );

    if (isCurrentlyFavorite) {
      _favorites.removeWhere((p) => p.placeId == placeId);
      _firestoreService.removeFavorite(placeId);
    } else {
      final newFavorite = _copyWithFavorite(targetPoi, true);
      _favorites.add(newFavorite);
      _firestoreService.addFavorite(newFavorite);
    }

    final index = _allPois.indexWhere((p) => p.placeId == placeId);
    if (index != -1) {
      _allPois[index] = _copyWithFavorite(
        _allPois[index],
        !isCurrentlyFavorite,
      );
    }

    notifyListeners();
  }

  Poi _copyWithFavorite(Poi oldPoi, bool isFavorite) {
    return Poi(
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
      isFavorite: isFavorite,
    );
  }
}
