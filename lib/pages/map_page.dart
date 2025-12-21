import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _useActualLocation = false;

  final Location _locationController = Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const _egerCoords = LatLng(47.90170735241794, 20.37649666229818);
  static const _egriVarCoords = LatLng(47.90459653061823, 20.379886214144268);
  static const _agriaParkCoords = LatLng(47.89939989199328, 20.36884744635898);

  LatLng? _currentLocation = _useActualLocation ? null : _agriaParkCoords;

  @override
  void initState() {
    super.initState();

    if (_useActualLocation) {
      getUserLocationUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: Text("Loading..."))
          : SafeArea(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) =>
                    _mapController.complete(controller),
                initialCameraPosition: CameraPosition(
                  target: _egerCoords,
                  zoom: 13,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId("_startingLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _agriaParkCoords,
                  ),
                  Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _egriVarCoords,
                  ),
                  Marker(
                    markerId: MarkerId("_currentLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _currentLocation!,
                  ),
                },
                zoomControlsEnabled: false,
              ),
            ),
    );
  }

  Future<void> cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPos = CameraPosition(target: pos, zoom: 13);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPos),
    );
  }

  Future<void> getUserLocationUpdates() async {
    bool isLocationServiceEnabled = await _locationController.serviceEnabled();
    if (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await _locationController.requestService();
      if (!isLocationServiceEnabled) return;
    }

    PermissionStatus permission = await _locationController.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _locationController.requestPermission();
      if (permission != PermissionStatus.granted) return;
    } else if (permission != PermissionStatus.granted) {
      return;
    }

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      if (lat != null && lng != null) {
        setState(() {
          _currentLocation = LatLng(lat, lng);
          debugPrint('Current location: $_currentLocation');
        });
      }
    });
  }
}
