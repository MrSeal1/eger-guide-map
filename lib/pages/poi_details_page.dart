import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_testing/data/models/place_review.dart';
import 'package:maps_testing/logic/location_provider.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:maps_testing/pages/widgets/review_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/poi.dart';

class PoiDetailsPage extends StatelessWidget {
  final Poi poi;

  const PoiDetailsPage({super.key, required this.poi});

  String? _getPhotoUrlString(String? photoReference) {
    if (photoReference == null || photoReference.isEmpty) return null;

    final apiKey = dotenv.env['MAPS_API_KEY'];
    return 'https://places.googleapis.com/v1/$photoReference/media?maxHeightPx=400&maxWidthPx=800&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = context.watch<LocationProvider>().userPosition;
    String? distance;

    if (userPosition != null) {
      final distanceMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        poi.lat,
        poi.lng,
      );

      if (distanceMeters < 1000) {
        distance = '${distanceMeters.toStringAsFixed(0)} m';
      } else {
        distance = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(poi.name),
        actions: [
          Consumer<UserDataProvider>(
            builder: (context, provider, _) {
              final isFavorite = provider.isFavorite(poi.placeId);

              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  provider.toggleFavorite(poi);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: poi.placeId,
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey.shade300,
                child:
                    poi.photoReferences != null &&
                        poi.photoReferences!.isNotEmpty
                    ? Image.network(
                        // le kell kérni a képet a Google-től, direktben nem jeleníthető
                        _getPhotoUrlString(poi.photoReferences!.first)!,
                        fit: BoxFit.cover,
                        // ha valami error keletkezik
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      )
                    : const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Google értékelések
                          if (poi.rating != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    poi.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (poi.userRatingsTotal != null)
                                    Text(
                                      " (${poi.userRatingsTotal})",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // appból származó értékelések, valós időben frissül
                          FutureBuilder<List<PlaceReview>>(
                            future: FirestoreService().getReviews(poi.placeId),
                            builder: (context, snapshot) {
                              
                              // ha nincs értékelés akkor semmit
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final reviews = snapshot.data!;
                              double sum = 0;
                              for (var review in reviews) {
                                sum += review.rating;
                              }
                              final double average = sum / reviews.length;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      average.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      " (${reviews.length})",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (poi.address != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            poi.address!,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (distance != null) const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Távolság: $distance",
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (poi.website != null)
                    Row(
                      children: [
                        Icon(Icons.link, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            child: Text(
                              poi.website!,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            onTap: () async {
                              try {
                                await launchUrl(
                                  Uri.parse(poi.website!),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Nem sikerült megnyitni a weboldalt.",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                  const Divider(height: 32),

                  Text(
                    "Leírás",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    poi.description ?? "Nincs elérhető leírás ehhez a helyhez.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final targetLat = poi.lat;
                        final targetLng = poi.lng;

                        final googleMapsUrl = Uri.parse(
                          "https://www.google.com/maps/dir/?api=1&destination=$targetLat,$targetLng",
                        );

                        if (await canLaunchUrl(googleMapsUrl)) {
                          await launchUrl(googleMapsUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Nem sikerült megnyitni a térképet.",
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text("Útvonaltervezés ide"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),

            ReviewWidget(placeId: poi.placeId, placeName: poi.name),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
