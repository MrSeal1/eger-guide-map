import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/logic/tour_provider.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteBuilderPage extends StatelessWidget {
  const RouteBuilderPage({super.key});

  void _showPublishTourDialog(BuildContext context, List<Poi> currentRoute) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Megosztás túraként'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Oszd meg a kedvenc útvonalad a közösséggel!'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Túra neve',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Rövid leírás',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Mégse'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (titleController.text.isEmpty ||
                              descController.text.isEmpty) {
                            return;
                          }
                          setState(() => isSubmitting = true);
                          final userDataProvider = context.read<UserDataProvider>();
                          final creatorName = userDataProvider.userEmail.split('@')[0];
                          final creatorId = userDataProvider.userId;

                          final List<String> poiIds = currentRoute
                              .map((p) => p.placeId)
                              .toList();

                          final success = await context
                              .read<TourProvider>()
                              .addTour(
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                creatorName: creatorName,
                                creatorId: creatorId,
                                poiIds: poiIds,
                              );

                          setState(() => isSubmitting = false);

                          if (success && context.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sikeresen megosztottad a túrát!',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Közzététel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchMultiStopRoute(
    BuildContext context,
    List<Poi> route,
  ) async {
    if (route.isEmpty) return;

    // ha csak 1db, sima útvonaltervezés
    if (route.length == 1) {
      final poi = route.first;
      final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=${poi.lat},${poi.lng}",
      );
      _openUrl(context, url);
      return;
    }

    // mindig az utolsó elem a célállomás
    final destination = route.last;

    // az utolsó kivételével vesszük az állomásokat
    final waypoints = route
        .take(route.length - 1)
        .map((p) => '${p.lat},${p.lng}')
        .join('|');

    // használandó szintaxis:
    // destination: az utolsó pont koordinátái
    // waypoints: '|'-al elválasztva a POI-k koordinátái
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${destination.lat},${destination.lng}&waypoints=$waypoints",
    );

    _openUrl(context, url);
  }

  Future<void> _openUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nem sikerült megnyitni a Google Térképet."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Útiterv építő'),
        centerTitle: true,
        actions: [
          Consumer<UserDataProvider>(
            builder: (context, userData, child) {
              if (userData.plannedRoute.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Megosztás publikus túraként',
                onPressed: () =>
                    _showPublishTourDialog(context, userData.plannedRoute),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userData, child) {
          final route = userData.plannedRoute;

          if (route.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Még nem adtál hozzá helyeket.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Tartsd lenyomva a két vonalat a sorrend módosításához!",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ReorderableListView.builder(
                  itemCount: route.length,
                  onReorder: (oldIndex, newIndex) {
                    userData.reorderRoute(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final poi = route[index];
                    return ListTile(
                      key: ValueKey(poi.placeId),

                      leading: CircleAvatar(
                        backgroundColor: colorScheme.onPrimary,
                        foregroundColor: colorScheme.primary,
                        child: Text('${index + 1}'),
                      ),

                      title: Text(
                        poi.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => userData.removeFromRoute(poi),
                          ),

                          const SizedBox(width: 8),

                          Icon(Icons.drag_handle, color: theme.hintColor),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchMultiStopRoute(context, route),
                    icon: const Icon(Icons.navigation),
                    label: const Text(
                      "Útvonal indítása a Google Maps-ben",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
