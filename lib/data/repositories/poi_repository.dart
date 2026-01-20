import '../models/poi.dart';

abstract class PoiRepository {
  Future<List<Poi>> getPois({required double lat, required double lng});
  
}