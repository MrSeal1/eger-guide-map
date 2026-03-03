import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_testing/logic/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _userPosition;
  Position? get userPosition => _userPosition;

  Future<void> loadUserPosition() async {
    final pos = await _locationService.getCurrentPosition();

    if(pos != null) {
      _userPosition = pos;
      notifyListeners();
    }
    
  }
}