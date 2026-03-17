import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/tour.dart';

class TourProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Tour> _tours = [];
  bool _isLoading = false;
  Tour? _activeTour;

  List<Tour> get tours => _tours;
  bool get isLoading => _isLoading;
  Tour? get activeTour => _activeTour;

  void setActiveTour(Tour? tour) {
    _activeTour = tour;
    notifyListeners();
  }

  Future<void> loadTours() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('tours')
          .orderBy('isOfficial', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      _tours = snapshot.docs.map((doc) => Tour.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Hiba a túrák betöltésekor: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTour({
    required String title,
    required String description,
    required String creatorName,
    required String creatorId,
    required List<String> poiIds,
  }) async {
    try {
      final newTour = Tour(
        id: '',
        title: title,
        description: description,
        creatorName: creatorName,
        creatorId: creatorId,
        isOfficial: false,
        poiIds: poiIds,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('tours').add(newTour.toMap());
      
      await loadTours(); 
      return true;
    } catch (e) {
      debugPrint('Hiba a túra mentésekor: $e');
      return false;
    }
  }
}