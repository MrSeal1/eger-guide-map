import 'package:flutter/material.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:maps_testing/pages/poi_details_page.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kedvenc helyeim'),
        centerTitle: true,
      ),
      body: Consumer<PoiProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoritePois;

          if(favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Még nincsenek kedvenceid.')
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final poi = favorites[index];

              return PoiListItem(poi: poi);
            },
          );
        },
      ),
    );
  }
}