import 'package:flutter/material.dart';
import '../data/models/poi.dart';

class PoiDetailsPage extends StatelessWidget {
  final Poi poi;

  const PoiDetailsPage({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Az AppBar átlátszóvá tétele, hogy a kép felcsússzon mögé (opcionális design elem)
      appBar: AppBar(
        title: Text(poi.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KÉP (Hero animációval)
            Hero(
              tag: poi.placeId, // Ez köti össze a listával
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey.shade300, // Helykitöltő szín
                child: poi.photoReferences != null && poi.photoReferences!.isNotEmpty
                    ? Image.network(
                        // Itt majd a valódi fotó URL-je lesz, most placeholder
                        'https://picsum.photos/seed/${poi.placeId}/800/400',
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
                  // 2. CÍM és ÉRTÉKELÉS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (poi.rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.white),
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

                  // 3. CÍM (Address)
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

                  // 4. LEÍRÁS
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

                  // 5. GOMBOK (Navigáció indítása - később kötjük be)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Navigáció indítása... (Hamarosan)")),
                        );
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