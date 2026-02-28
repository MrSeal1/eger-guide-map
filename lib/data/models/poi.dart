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
  final bool isFavorite;

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
    this.isFavorite = false,
  });

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
      isFavorite: json['is_favorite'] == true,
    );
  }

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
      'is_favorite': isFavorite,
    }..removeWhere((key, value) => value == null);
  }
}
