import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/tour.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:maps_testing/logic/tour_provider.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:provider/provider.dart';

class MyToursPage extends StatefulWidget {
  const MyToursPage({super.key});

  @override
  State<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends State<MyToursPage> {
  late Future<List<Tour>> _myToursFuture;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  void _loadTours() {
    final userId = context.read<UserDataProvider>().userId;
    _myToursFuture = context.read<TourProvider>().getUserTours(userId);
  }

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();
    final userDataProvider = context.watch<UserDataProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saját túráim'), centerTitle: true),
      body: FutureBuilder<List<Tour>>(
        future: _myToursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tours = snapshot.data;

          if (tours == null || tours.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Még nem osztottál meg túrát.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.map, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    tour.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text('${tour.poiIds.length} állomás\n${tour.description}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Túra törlése'),
                          content: const Text('Biztosan törlöd ezt a túrát? Ezt utólag nem lehet visszavonni.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), 
                              child: const Text('Mégse')
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true), 
                              child: const Text('Törlés', style: TextStyle(color: Colors.red))
                            ),
                          ],
                        )
                      );

                      if (confirm == true && context.mounted) {
                        final success = await context.read<TourProvider>().deleteTour(tour.id);
                        if (success) {
                          setState(() {
                            _loadTours();
                          });
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A túra sikeresen törölve lett.'))
                          );
                          }
                        }
                      }
                    },
                  ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}