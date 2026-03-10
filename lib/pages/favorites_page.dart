import 'package:flutter/material.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kedvenc helyeim'), centerTitle: true),
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoritePois;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Még nincsenek kedvenc helyeid.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
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
