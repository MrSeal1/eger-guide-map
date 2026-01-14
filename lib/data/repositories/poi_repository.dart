import '../models/poi.dart';

abstract class PoiRepository {
  // Lekéri az összes helyet
  Future<List<Poi>> getPois();
  
}