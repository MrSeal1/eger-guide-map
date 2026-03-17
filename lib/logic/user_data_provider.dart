import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/logic/services/auth_service.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';

class UserDataProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String get userEmail => _authService.currentUser?.email ?? 'Ismeretlen';
  String get userId => _authService.currentUser?.uid ?? 'ismeretlen';

  List<Poi> _favorites = [];
  List<Poi> get favoritePois => _favorites;

  final List<Poi> _plannedRoute = [];
  List<Poi> get plannedRoute => _plannedRoute;

  UserDataProvider() {
    loadDataFromDb();
  }

  void clearUserData() {
    _favorites.clear();
    _plannedRoute.clear();
    notifyListeners();
  }

  Future<void> loadDataFromDb() async {
    clearUserData();
    _favorites = await _firestoreService.getFavorites();
    _plannedRoute.addAll(await _firestoreService.getRoute());
    notifyListeners();
  }

  void toggleFavorite(Poi poi) {
    final isFavorite = _favorites.any((p) => p.placeId == poi.placeId);
    if (isFavorite) {
      _favorites.removeWhere((p) => p.placeId == poi.placeId);
      _firestoreService.removeFavorite(poi.placeId);
    } else {
      _favorites.add(poi);
      _firestoreService.addFavorite(poi);
    }
    notifyListeners();
  }

  bool isFavorite(String placeId) {
    return _favorites.any((p) => p.placeId == placeId);
  }

  void addToRoute(Poi poi) {
    if (!_plannedRoute.any((p) => p.placeId == poi.placeId)) {
      _plannedRoute.add(poi);
      _firestoreService.saveRoute(_plannedRoute);
      notifyListeners();
    }
  }

  void removeFromRoute(Poi poi) {
    _plannedRoute.removeWhere((p) => p.placeId == poi.placeId);
    _firestoreService.saveRoute(_plannedRoute);
    notifyListeners();
  }

  void reorderRoute(int oldIndex, int newIndex) {
    // index fixálás
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final Poi item = _plannedRoute.removeAt(oldIndex);
    _plannedRoute.insert(newIndex, item);
    _firestoreService.saveRoute(_plannedRoute);
    notifyListeners();
  }

  void clearRoute() {
    _plannedRoute.clear();
    notifyListeners();
  }
}
