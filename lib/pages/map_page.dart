import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_testing/data/models/poi.dart';
import 'package:maps_testing/pages/widgets/filter_widget.dart';
import 'package:maps_testing/pages/widgets/poi_list_item_widget.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:provider/provider.dart';

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

  Poi? _selectedPoi;

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

    final double radius = _calculateDistance(center, screenBounds.northeast);

    final searchTarget = _currentCameraPos.target;
    _lastSearchedPos = searchTarget;

    context.read<PoiProvider>().loadPois(
      lat: searchTarget.latitude,
      lng: searchTarget.longitude,
      radius: radius.toInt()
    );
  }

  // köszi gemini
  double _calculateDistance(LatLng p1, LatLng p2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((p2.latitude - p1.latitude) * p) / 2 +
        c(p1.latitude * p) * c(p2.latitude * p) *
        (1 - c((p2.longitude - p1.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  // kategóriától függően más-más színt ad vissza
  double _getMarkerColor(List<String>? types) {
    if (types == null || types.isEmpty) return BitmapDescriptor.hueRed;
    if (types.contains('castle')) return BitmapDescriptor.hueMagenta;
    if (types.contains('shopping_mall') || types.contains('store') || types.contains('shopping')) return BitmapDescriptor.hueBlue;
    if (types.contains('restaurant')) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();

    return Stack(
      children: [
        // térkép
        GoogleMap(
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          initialCameraPosition: _currentCameraPos,
          style: _mapStyle,
          //cameraTargetBounds: CameraTargetBounds(_egerBounds),
          cameraTargetBounds: CameraTargetBounds.unbounded, // ideiglenes, tesztelésre csak
          minMaxZoomPreference: const MinMaxZoomPreference(12.5, null),
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          markers: poiProvider.filteredPois.map((poi) {
            return Marker(
              markerId: MarkerId(poi.placeId),
              position: LatLng(poi.lat, poi.lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerColor(poi.types),
              ),
              /* infoWindow: InfoWindow(
                title: poi.name,
                snippet: poi.types?.first ?? '',
              ), */
              onTap: () {
                setState(() {
                  _selectedPoi = poi;                  
                });

              }
                
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
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
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

          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: 20,
            right: 20,
            bottom: _selectedPoi != null ? 55 : -250,
            child: _selectedPoi != null
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                    ),
                  ]
                ),
                child: PoiListItem(poi: _selectedPoi!),
              )
              : SizedBox(),
          ),

        if (poiProvider.isLoading) Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
