import 'package:flutter/material.dart';
import '../../data/models/poi.dart';
import '../poi_details_page.dart';

class PoiListItem extends StatelessWidget {
  final Poi poi;

  const PoiListItem({super.key, required this.poi});

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