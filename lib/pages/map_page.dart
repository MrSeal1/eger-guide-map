import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/pages/widgets/custom_marker_widget.dart';
import 'package:maps_testing/pages/widgets/filter_widget.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:provider/provider.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  String? _lightMapStyle;
  String? _darkMapStyle;

  bool _showSearchButton = true;

  Poi? _selectedPoi;

  final Map<String, BitmapDescriptor> _customMarkers = {};

  // alapból Eger koordinátái, tesztelés miatt
  CameraPosition _currentCameraPos = const CameraPosition(
    target: _center,
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyles();
    _generateCustomMarkers();
  }

Future<void> _loadMapStyles() async {
    try {
      _lightMapStyle = await rootBundle.loadString('assets/maps_theme_light.json');
      _darkMapStyle = await rootBundle.loadString('assets/maps_theme_dark.json');
      
      if (mounted) setState(() {});
    } catch (err) {
      debugPrint('Hiba a stílus beolvasásakor: $err');
    }
  }
  
  Future<void> _generateCustomMarkers() async {
    _customMarkers['museum'] = await const CustomMarkerWidget(icon: Icons.museum, backgroundColor: Colors.purple).toBitmapDescriptor();
    _customMarkers['shopping'] = await const CustomMarkerWidget(icon: Icons.shopping_bag, backgroundColor: Colors.blue).toBitmapDescriptor();
    _customMarkers['restaurant'] = await const CustomMarkerWidget(icon: Icons.restaurant, backgroundColor: Colors.orange).toBitmapDescriptor();
    _customMarkers['park'] = await const CustomMarkerWidget(icon: Icons.park, backgroundColor: Colors.green).toBitmapDescriptor();
    _customMarkers['attraction'] = await const CustomMarkerWidget(icon: Icons.camera_alt, backgroundColor: Colors.red).toBitmapDescriptor();
    
    if (mounted) setState(() {});
  }

  static const LatLng _center = LatLng(47.9025, 20.3772);
  static final LatLngBounds _egerBounds = LatLngBounds(
    southwest: const LatLng(47.8600, 20.3200),
    northeast: const LatLng(47.9600, 20.4500),
  );

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _currentCameraPos = position;
  }

  void _onCameraIdle() {
    setState(() {
      _showSearchButton = true;
    });
  }

  void _searchArea() async {
    setState(() {
      _showSearchButton = false;
    });

    final controller = await _controller.future;

    final screenBounds = await controller.getVisibleRegion();
    final center = _currentCameraPos.target;

    final double radius = Geolocator.distanceBetween(
      center.latitude,
      center.longitude,
      screenBounds.northeast.latitude,
      screenBounds.northeast.longitude,
    );

    final searchTarget = _currentCameraPos.target;

    context.read<PoiProvider>().loadPois(
      lat: searchTarget.latitude,
      lng: searchTarget.longitude,
      radius: radius.toInt(),
    );
  }

  BitmapDescriptor _getCustomMarkerForPoi(Poi poi) {
    const fallbackMarker = BitmapDescriptor.defaultMarker;

    final types = poi.types;
    if (types == null || types.isEmpty) return _customMarkers['attraction'] ?? fallbackMarker;
    
    if (types.any((t) => PoiProvider.categoryMapping['museum']!.contains(t))) return _customMarkers['museum'] ?? fallbackMarker;
    if (types.any((t) => PoiProvider.categoryMapping['shopping']!.contains(t))) return _customMarkers['shopping'] ?? fallbackMarker;
    if (types.any((t) => PoiProvider.categoryMapping['restaurant']!.contains(t))) return _customMarkers['restaurant'] ?? fallbackMarker;
    if (types.any((t) => PoiProvider.categoryMapping['park']!.contains(t))) return _customMarkers['park'] ?? fallbackMarker;
    
    return _customMarkers['attraction'] ?? fallbackMarker;
  }

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();

    final currentMapStyle = Theme.of(context).brightness == Brightness.dark ? _darkMapStyle : _lightMapStyle;

    return Stack(
      children: [
        // térkép
        GoogleMap(
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          initialCameraPosition: _currentCameraPos,
          style: currentMapStyle,
          //cameraTargetBounds: CameraTargetBounds(_egerBounds),
          cameraTargetBounds:
              CameraTargetBounds.unbounded, // ideiglenes, tesztelésre csak
          minMaxZoomPreference: const MinMaxZoomPreference(12.5, null),
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          onTap: (_) => setState(() {
            _selectedPoi = null;
          }),
          markers: poiProvider.filteredPois.map((poi) {
            return Marker(
              markerId: MarkerId(poi.placeId),
              position: LatLng(poi.lat, poi.lng),
              icon: _getCustomMarkerForPoi(poi),
              onTap: () {
                setState(() {
                  _selectedPoi = poi;
                });
              },
            );
          }).toSet(),
        ),

        // filterek
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: const FilterWidget(),
            ),
          ),
        ),

        // kereső gomb
        if (_showSearchButton)
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: ElevatedButton.icon(
                  onPressed: _searchArea,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text(
                    'Keresés a területen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 20,
          right: 20,
          bottom: _selectedPoi != null ? 25 : -250,
          child: _selectedPoi != null
              ? PoiListItem(poi: _selectedPoi!)
              : const SizedBox(),
        ),

        if (poiProvider.isLoading) Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
