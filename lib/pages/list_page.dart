import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/logic/location_provider.dart';
import 'package:maps_testing/pages/widgets/filter_widget.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:provider/provider.dart';
import '../logic/poi_provider.dart';

enum SortMode { defaultOrder, name, rating, distance, popularity }

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  SortMode sortMode = SortMode.defaultOrder;

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();
    final locationProvider = context.watch<LocationProvider>();

    final userPos = locationProvider.userPosition;

    // lista másolása, hogy ne az igazival végezze a műveleteket
    List<Poi> displayPois = List.from(poiProvider.filteredPois);

    if (sortMode != SortMode.defaultOrder) {
      displayPois.sort((a, b) {
        switch (sortMode) {
          case SortMode.name:
            return a.name.compareTo(b.name); // A-Z

          case SortMode.rating:
            return (b.rating ?? 0).compareTo(
              a.rating ?? 0,
            ); // Legjobb értékelés elöl

          case SortMode.popularity:
            return (b.userRatingsTotal ?? 0).compareTo(
              a.userRatingsTotal ?? 0,
            ); // Legtöbb értékelés elöl

          case SortMode.distance:
            if (userPos == null)
              return 0; // Ha nincs GPS, marad az eredeti sorrend
            final distA = Geolocator.distanceBetween(
              userPos.latitude,
              userPos.longitude,
              a.lat,
              a.lng,
            );
            final distB = Geolocator.distanceBetween(
              userPos.latitude,
              userPos.longitude,
              b.lat,
              b.lng,
            );
            return distA.compareTo(distB); // Legközelebbi elöl

          default:
            return 0;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Látnivalók listája"),
        centerTitle: true,
        actions: [
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: 'Rendezés',
            onSelected: (SortMode selected) {
              setState(() {
                sortMode = selected;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
              const PopupMenuItem<SortMode>(
                value: SortMode.defaultOrder,
                child: Text('Alapértelmezett'),
              ),

              const PopupMenuItem<SortMode>(
                value: SortMode.distance,
                child: Text('Távolság szerint'),
              ),

              const PopupMenuItem<SortMode>(
                value: SortMode.rating,
                child: Text('Értékelés szerint'),
              ),

              const PopupMenuItem<SortMode>(
                value: SortMode.popularity,
                child: Text('Népszerűség szerint'),
              ),

              const PopupMenuItem<SortMode>(
                value: SortMode.name,
                child: Text('Név szerint'),
              ),

            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: FilterWidget(),
          ),

          Expanded(
            child: poiProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayPois.isEmpty
                  ? const Center(
                      child: Text("Nincs találat ebben a kategóriában."),
                    )
                  : ListView.builder(
                      itemCount: displayPois.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final poi = displayPois[index];
                        return PoiListItem(poi: poi);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
