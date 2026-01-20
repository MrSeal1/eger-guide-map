import 'package:flutter/material.dart';
import 'package:maps_testing/pages/widgets/filter_widget.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:provider/provider.dart';
import '../logic/poi_provider.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();
    final pois = poiProvider.filteredPois;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Látnivalók listája"),
        centerTitle: true,
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
                : pois.isEmpty
                    ? const Center(child: Text("Nincs találat ebben a kategóriában."))
                    : ListView.builder(
                        itemCount: pois.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final poi = pois[index];
                          return PoiListItem(poi: poi);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}