import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maps_testing/logic/poi_provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(poi.name),
        actions: [
          Consumer<PoiProvider>(
            builder: (context, provider, child) {
              final currentpoi = provider.filteredPois.firstWhere(
                (p) => p.placeId == poi.placeId,
              );
              final isFavorite = currentpoi.isFavorite;

              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  provider.toggleFavorite(poi.placeId);
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
                    poi.photoReferences != null && poi.photoReferences!.isNotEmpty
                    ? Image.network(
                        _getPhotoUrlString(poi.photoReferences!.first)!,
                        fit: BoxFit.cover,
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
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (poi.rating != null)
                        Container(
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
                                size: 16,
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
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (poi.address != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            poi.address!,
                            style: TextStyle(color: Colors.grey.shade700),
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
                            SnackBar(content: Text("Nem sikerült megnyitni a térképet."))
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
          ],
        ),
      ),
    );
  }
}
