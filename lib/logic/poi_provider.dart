import 'package:flutter/material.dart';
import '../data/models/poi.dart';
import '../data/repositories/poi_repository.dart';

class PoiProvider extends ChangeNotifier {
  final PoiRepository _repository;
  
  List<Poi> _pois = [];
  bool _isLoading = false;

  List<Poi> get pois => _pois;
  bool get isLoading => _isLoading;

  PoiProvider(this._repository) {
    loadPois();
  }

  Future<void> loadPois() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pois = await _repository.getPois();
    } catch (e) {
      debugPrint("Hiba történt: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}