import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../logic/poi_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  
  static const LatLng _center = LatLng(47.9025, 20.3772);
  static final LatLngBounds _egerBounds = LatLngBounds(
    southwest: const LatLng(47.8600, 20.3200),
    northeast: const LatLng(47.9600, 20.4500),
  );

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    controller.moveCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(target: _center, zoom: 13.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final poiProvider = context.watch<PoiProvider>();

    return Scaffold(
      body: poiProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 13.0,
              ),
              cameraTargetBounds: CameraTargetBounds(_egerBounds),
              minMaxZoomPreference: const MinMaxZoomPreference(12.5, null),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              
              markers: poiProvider.pois.map((poi) {
                return Marker(
                  markerId: MarkerId(poi.placeId),
                  position: LatLng(poi.lat, poi.lng),
                  infoWindow: InfoWindow(
                    title: poi.name,
                    snippet: poi.types?.first ?? '',
                  ),
                );
              }).toSet(),
            ),
    );
  }
}