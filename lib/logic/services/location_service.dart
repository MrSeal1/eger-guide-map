import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool isServiceEnabled;
    LocationPermission permission;

    try {
      isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      // GPS ki
      if(!isServiceEnabled) {
        debugPrint("A GPS szolgáltatás ki van kapcsolva");
        return null;
      }

      permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        // Elutasítás
        if(permission == LocationPermission.denied) {
          debugPrint("Helymeghatározás engedély elutasítva");
          return null;
        }
      }

      return await Geolocator.getCurrentPosition();
    }
    catch (e) {
      debugPrint("Hiba a hely lekérésekor: $e");
      return null;
    }
  }
}