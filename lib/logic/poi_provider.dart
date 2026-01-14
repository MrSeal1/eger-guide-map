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

  PoiProvider(this._repository) {
    loadPois();
  }

  Future<void> loadPois() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPois = await _repository.getPois();
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