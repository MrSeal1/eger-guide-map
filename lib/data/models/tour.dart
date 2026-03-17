import 'package:cloud_firestore/cloud_firestore.dart';

class Tour {
  final String id;
  final String title;
  final String description;
  final String creatorName;
  final String creatorId;
  final bool isOfficial;
  final List<String> poiIds;
  final DateTime createdAt;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorName,
    required this.creatorId,
    required this.isOfficial,
    required this.poiIds,
    required this.createdAt,
  });

  factory Tour.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tour(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorName: data['creatorName'] ?? 'Ismeretlen felhasználó',
      creatorId: data['creatorId'] ?? 'ismeretlen',
      isOfficial: data['isOfficial'] ?? false,
      poiIds: List<String>.from(data['poiIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'creatorName': creatorName,
      'creatorId': creatorId,
      'isOfficial': isOfficial,
      'poiIds': poiIds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}