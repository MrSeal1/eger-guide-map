import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
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
}
