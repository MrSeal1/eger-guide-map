class Poi {
  final String placeId;
  final String name;
  final String? description;
  final double lat;
  final double lng;
  final String? address;
  final List<String>? types;
  final double? rating;
  final int? userRatingsTotal;
  final bool? openNow;
  final List<String>? photoReferences;
  final String? website;
  final String? phoneNumber;

  Poi({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    this.description,
    this.address,
    this.types,
    this.rating,
    this.userRatingsTotal,
    this.openNow,
    this.photoReferences,
    this.website,
    this.phoneNumber,
  });


  // Google API
  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      placeId: json['id'] ?? '', 
      name: json['displayName'] != null ? json['displayName']['text'] : 'Névtelen hely',
      description: json['editorialSummary'] != null ? json['editorialSummary']['text'] : null,
      lat: (json['location']?['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (json['location']?['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['formattedAddress'] as String?,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['userRatingCount'] as num?)?.toInt(),
      photoReferences: (json['photos'] as List<dynamic>?)?.map((p) => p['name'].toString()).toList(),
      website: json['websiteUri'] as String?,
      phoneNumber: json['nationalPhoneNumber'] as String?,
    );
  }

  // Google API
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'formatted_address': address,
      'types': types,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'opening_hours': openNow != null ? {'open_now': openNow} : null,
      'photos': photoReferences?.map((r) => {'photo_reference': r}).toList(),
      'website': website,
      'formatted_phone_number': phoneNumber,
    }..removeWhere((key, value) => value == null);
  }

  // Firestore
  factory Poi.fromFirestore(Map<String, dynamic> json) {
    return Poi(
      placeId: json['placeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt(),
      photoReferences: (json['photoReferences'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      website: json['website'],
      phoneNumber: json['phoneNumber'],
    );
  }

  // Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'placeId': placeId,
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'address': address,
      'types': types,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'photoReferences': photoReferences,
      'website': website,
      'phoneNumber': phoneNumber,
    }..removeWhere((key, value) => value == null);
  }
}
