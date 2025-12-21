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
    // Support both a flattened POI JSON and Google Places-like structure
    String id = json['place_id'] ?? json['id'] ?? '';
    String name = json['name'] ?? '';

    double? lat;
    double? lng;
    if (json['geometry'] != null && json['geometry']['location'] != null) {
      lat = (json['geometry']['location']['lat'] as num?)?.toDouble();
      lng = (json['geometry']['location']['lng'] as num?)?.toDouble();
    } else if (json['lat'] != null && json['lng'] != null) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lng'] as num).toDouble();
    }

    return Poi(
      placeId: id,
      name: name,
      description: json['description'] as String?,
      lat: lat ?? 0.0,
      lng: lng ?? 0.0,
      address: json['formatted_address'] ?? json['address'] as String?,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
      openNow: json['opening_hours'] != null ? json['opening_hours']['open_now'] as bool? : null,
      photoReferences: (json['photos'] as List<dynamic>?)?.map((p) {
        if (p is Map && p['photo_reference'] != null) return p['photo_reference'].toString();
        return p.toString();
      }).toList(),
      website: json['website'] as String?,
      phoneNumber: json['formatted_phone_number'] as String?,
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
