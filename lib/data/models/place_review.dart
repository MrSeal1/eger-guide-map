import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceReview {
  final String id;
  final String placeId;
  final String userEmail;
  final String? comment;
  final double rating;
  final DateTime createdAt;

  PlaceReview({
    required this.id,
    required this.placeId,
    required this.userEmail,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  factory PlaceReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaceReview(
      id: doc.id,
      placeId: data['placeId'],
      userEmail: data['userEmail'] ?? 'Ismeretlen',
      comment: data['comment'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
    );
  }
}
