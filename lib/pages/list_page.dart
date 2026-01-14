import 'package:flutter/material.dart';
import 'package:maps_testing/pages/poi_details_page.dart';
import 'package:provider/provider.dart';
import '../logic/poi_provider.dart';
import '../data/models/poi.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();
    final pois = poiProvider.pois;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Látnivalók listája"),
        centerTitle: true,
      ),
      body: poiProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pois.isEmpty
              ? const Center(child: Text("Nincs megjeleníthető hely."))
              : ListView.builder(
                  itemCount: pois.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final poi = pois[index];
                    return _PoiListItem(poi: poi);
                  },
                ),
    );
  }
}

class _PoiListItem extends StatelessWidget {
  final Poi poi;

  const _PoiListItem({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForType(poi.types),
            color: Colors.green.shade800,
            size: 30,
          ),
        ),
        title: Text(
          poi.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poi.address != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      poi.address!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (poi.rating != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    poi.rating.toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ]
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiDetailsPage(poi: poi),
            ),
          );
        },
      ),
    );
  }

  // helytípustól függően más ikont ad vissza
  IconData _getIconForType(List<String>? types) {
    if (types == null || types.isEmpty) return Icons.place;
    if (types.contains('castle')) return Icons.fort;
    if (types.contains('museum')) return Icons.museum;
    if (types.contains('shopping_mall')) return Icons.shopping_bag;
    if (types.contains('restaurant') || types.contains('food')) return Icons.restaurant;
    if (types.contains('park')) return Icons.park;
    return Icons.place;
  }
}