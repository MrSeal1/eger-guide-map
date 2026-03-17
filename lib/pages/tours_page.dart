import 'package:flutter/material.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:maps_testing/logic/tour_provider.dart';

class ToursPage extends StatefulWidget {
  const ToursPage({super.key});

  @override
  State<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TourProvider>().loadTours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = context.watch<TourProvider>();
    final poiProvider = context.watch<PoiProvider>();
    final userDataProvider = context.watch<UserDataProvider>();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tematikus Túrák'), centerTitle: true),
      body: tourProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tourProvider.tours.isEmpty
          ? const Center(
              child: Text(
                'Még nincsenek elérhető túrák.\nLegyél te az első, aki beküld egyet!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tourProvider.tours.length,
              itemBuilder: (context, index) {
                final tour = tourProvider.tours[index];
                final isOfficial = tour.isOfficial;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isOfficial ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isOfficial
                        ? BorderSide(color: theme.colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final tourPois = poiProvider.filteredPois
                          .where((poi) => tour.poiIds.contains(poi.placeId))
                          .toList();

                      userDataProvider.clearRoute();

                      for (var poi in tourPois) {
                        userDataProvider.addToRoute(poi);
                      }

                      context.read<TourProvider>().setActiveTour(tour);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${tour.title} betöltve a térképre!'),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isOfficial
                                    ? Icons.verified
                                    : Icons.person_outline,
                                color: isOfficial ? Colors.blue : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tour.creatorName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isOfficial ? Colors.blue : Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${tour.poiIds.length} állomás',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tour.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tour.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (context.mounted) {
            context.read<TourProvider>().loadTours();
          }
        },
        icon: const Icon(Icons.upload),
        label: const Text('Tesztadatok feltöltése'),
      ),
    );
  }
}
