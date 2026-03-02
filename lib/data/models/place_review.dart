import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceReview {
  final String id;
  final String placeId;
  final double rating;
  final DateTime createdAt;

  PlaceReview({
    required this.id,
    required this.placeId,
    required this.rating,
    required this.createdAt,
  });

  factory PlaceReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data as Map<String, dynamic>;
    return PlaceReview(
      id: doc.id,
      placeId: data['placeId'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
    );
  }
}
