import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_testing/pages/widgets/filter_widget.dart';
import 'package:provider/provider.dart';
import '../logic/poi_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  String? _mapStyle;

  bool _showSearchButton = true;
  LatLng? _lastSearchedPos;
  // alapból Eger koordinátái, tesztelés miatt
  CameraPosition _currentCameraPos = const CameraPosition(
    target: _center,
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _lastSearchedPos = _center;
  }

  void _loadMapStyle() {
    rootBundle
        .loadString('assets/maps_theme.json')
        .then((String styleString) {
          setState(() {
            _mapStyle = styleString;
          });
        })
        .catchError((err) {
          debugPrint('Hiba a stílus beolvasásakor: $err');
        });
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
    // TODO
  }

  void _onCameraIdle() {
    // TODO
  }

  void _searchArea() {
    // TODO
  }

  // kategóriától függően más-más színt ad vissza
  double _getMarkerColor(List<String>? types) {
    if (types == null || types.isEmpty) return BitmapDescriptor.hueRed;

    if (types.contains('castle')) return BitmapDescriptor.hueMagenta;

    if (types.contains('shopping_mall') ||
        types.contains('store') ||
        types.contains('shopping'))
      return BitmapDescriptor.hueBlue;

    if (types.contains('restaurant')) return BitmapDescriptor.hueYellow;

    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();
    return Scaffold(
      body: poiProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // térkép
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  initialCameraPosition: _currentCameraPos,
                  style: _mapStyle,
                  //cameraTargetBounds: CameraTargetBounds(_egerBounds),
                  cameraTargetBounds: CameraTargetBounds
                      .unbounded, // ideiglenes, tesztelésre csak
                  minMaxZoomPreference: const MinMaxZoomPreference(12.5, null),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: poiProvider.filteredPois.map((poi) {
                    return Marker(
                      markerId: MarkerId(poi.placeId),
                      position: LatLng(poi.lat, poi.lng),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        _getMarkerColor(poi.types),
                      ),
                      infoWindow: InfoWindow(
                        title: poi.name,
                        snippet: poi.types?.first ?? '',
                      ),
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
                        padding: EdgeInsets.only(top: 60),
                        child: GestureDetector(
                          onTap: _searchArea,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Keresés itt',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
