import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:maps_testing/data/models/place_review.dart';
import 'package:maps_testing/data/models/poi.dart';

///
/// Firestore struktúra referencia:
///
///   users (collection)
///     - {userId} (egyedi UID, Firebase Auth generálja)
///       - favorites (collection)
///         - {placeId} (a hely Google Places Id-ja)
///           - placeId: "..."
///           - name: "..."
///           - ...
///         - {placeId} (másik kedvenc hely Id-ja)
///
///     - {userId} (másik felhasználó)
///       - favorites
///         - ...
///
///   reviews (collection)
///     - {reviewId}
///       - {placeId}
///       - {placeName}
///       - {userId} (aki értékelte)
///       - rating (0-5)
///       - createdAt
///

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get _userId => auth.currentUser?.uid;

  Future<List<Poi>> getFavorites() async {
    if (_userId == null) return [];

    try {
      final query = await db
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .get();

      return query.docs.map((doc) => Poi.fromFirestore(doc.data())).toList();
    } catch (e) {
      debugPrint("Hiba a kedvenc hely lekérésekor: $e");
      return [];
    }
  }

  Future<void> addFavorite(Poi poi) async {
    if (_userId == null) return;

    try {
      await db
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(poi.placeId)
          .set(poi.toFirestore());
    } catch (e) {
      debugPrint("Hiba a kedvenc hely mentésekor: $e");
    }
  }

  Future<void> removeFavorite(String placeId) async {
    if (_userId == null) return;

    try {
      await db
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(placeId)
          .delete();
    } catch (e) {
      debugPrint("Hiba a kedvenc hely törlésekor: $e");
    }
  }

  Future<void> addReview({
    required String placeId,
    required String placeName,
    required double rating,
    String? comment,
  }) async {
    if (_userId == null) return;

    try {
      final userEmail = auth.currentUser?.email ?? 'Ismeretlen';

      await db.collection('reviews').add({
        'placeId': placeId,
        'placeName': placeName,
        'userId': _userId,
        'userEmail': userEmail,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Hiba az értékelés mentésével: $e");
      rethrow;
    }
  }

  Future<List<PlaceReview>> getReviews(String placeId) async {
    final snapshot = await db
        .collection('reviews')
        .where('placeId', isEqualTo: placeId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PlaceReview.fromFirestore(doc)).toList();
  }

  Future<List<PlaceReview>> getMyReviews() async {
    if (_userId == null) return [];

    final snapshot = await db
        .collection('reviews')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PlaceReview.fromFirestore(doc)).toList();
  }

  Future<List<Poi>> getRoute() async {
    if (_userId == null) return [];

    try {
      final doc = await db.collection('users').doc(_userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        if (data.containsKey('plannedRoute')) {
          final routeList = data['plannedRoute'] as List<dynamic>;

          return routeList
              .map((item) => Poi.fromFirestore(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Hiba az útiterv betöltésével: $e");
      return [];
    }
  }

  Future<void> saveRoute(List<Poi> route) async {
    if (_userId == null) return;

    try {
      final routeData = route.map((poi) => poi.toFirestore()).toList();

      await db.collection('users').doc(_userId).set({
        'plannedRoute': routeData,
      }, SetOptions(merge: true)); // SetOptions(true): ha valamilyen más adat már van, akkor ne cserélje le hanem gyúrja össze
    } catch (e) {
      debugPrint('Hiba az útiterv mentésével: $e');
    }
  }
}
