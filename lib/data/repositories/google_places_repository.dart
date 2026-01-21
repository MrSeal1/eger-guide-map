import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/data/repositories/poi_repository.dart';

class GooglePlacesRepository implements PoiRepository {
  final String apiKey;

  GooglePlacesRepository({required this.apiKey});

  @override
  Future<List<Poi>> getPois({required double lat, required double lng, required int radius}) async {
    //const egerLat = 47.9025;
    //const egerLng = 20.3772;
    //const radius = 2000; // 2km körzet

    final placesUrl = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      // felsorolás, miket akarok lekérni
      'X-Goog-FieldMask': 'places.id,places.location,places.formattedAddress,places.displayName,places.types,places.photos,places.rating,places.userRatingCount,places.websiteUri,places.editorialSummary'
    };

    // TODO: közös neveket használni a google típusok és saját típusok között,
    // hogy a filterezés megbízhatóbban működjön
    // Map<String, List<String>> ?
    final includedTypes = [
      'tourist_attraction',
      'museum',
      'park',
      'restaurant',
      'shopping_mall',
      'convenience_store'
    ];

    final body = jsonEncode({
        "includedTypes": includedTypes,
        "maxResultCount": 20,
        "locationRestriction": {
          "circle": {
            "center": {
              "latitude": lat,
              "longitude": lng
            },
            "radius": radius.toDouble()
          }
        },
        "languageCode": "hu"
      }
    );

    try {
      final response = await http.post(placesUrl, headers: headers, body: body);

      if(response.statusCode != 200) {
        debugPrint("Hiba: ${response.statusCode}\n${response.body}");
        throw Exception("Hiba történt az API hívással");
      }
      else {
        final responseData = jsonDecode(response.body);

        if(responseData['places'] == null) {
          debugPrint('A válasz null: $responseData');
          return [];
        }
        else {
          final List placesList = responseData['places'];

          return placesList.map((place) {
            return Poi(
              placeId: place['id'], 
              name: place['displayName'] != null ? place['displayName']['text'] : 'Névtelen hely', 
              description: place['editorialSummary'] != null ? place['editorialSummary']['text'] : null,
              lat: place['location']['latitude'], 
              lng: place['location']['longitude'],
              types: (place['types'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
              address: place['formattedAddress'],
              website: place['websiteUri'] as String?,
              rating: (place['rating'] as num?)?.toDouble() ?? 0.0,
              userRatingsTotal: (place['userRatingCount'] as num?)?.toInt() ?? 0,
              photoReferences: (place['photos'] as List<dynamic>?)?.map((p) => p['name'].toString()).toList(),
              );
          }).toList();
        }
      }
    }
    catch (ex) {
      debugPrint('Hiba a lekéréssel: $ex');
      return [];
    }
  }

}