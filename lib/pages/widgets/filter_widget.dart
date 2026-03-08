import 'package:flutter/material.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:provider/provider.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PoiProvider>();
    final currentCategory = provider.selectedCategory;

    final categories = [
      {'key': 'all', 'label': 'Minden', 'icon': Icons.explore},
      {'key': 'attraction', 'label': 'Látnivalók', 'icon': Icons.camera_alt},
      {'key': 'castle', 'label': 'Várak', 'icon': Icons.fort},
      {'key': 'museum', 'label': 'Múzeumok', 'icon': Icons.museum},
      {'key': 'shopping_mall', 'label': 'Bevásárlás', 'icon': Icons.shopping_bag},
      {'key': 'restaurant', 'label': 'Éttermek', 'icon': Icons.restaurant},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = currentCategory == cat['key'];

          return ChoiceChip(
            avatar: Icon(
              cat['icon'] as IconData,
              size: 18,
              color: isSelected ? Colors.white : Colors.green[700],
            ),
            label: Text(cat['label'] as String),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                context.read<PoiProvider>().setCategory(cat['key'] as String);
              }
            },
            selectedColor: Colors.green[700],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            elevation: 2,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}