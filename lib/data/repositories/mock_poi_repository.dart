import '../models/poi.dart';
import 'poi_repository.dart';

class MockPoiRepository implements PoiRepository {
  @override
  Future<List<Poi>> getPois({required double lat, required double lng}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // mesterséges delay, hihetőbb egyelőre...

    return [
      Poi(
        placeId: '1',
        name: 'Agria Park',
        description: 'Bevásárlóközpont és közösségi tér.',
        lat: 47.89939989199328,
        lng: 20.36884744635898,
        address: 'Eger, Törvényház u. 4, 3300',
        types: ['shopping_mall'],
      ),
      Poi(
        placeId: '2',
        name: 'Egri Vár',
        description: 'Magyarország híres történelmi vára.',
        lat: 47.90459653061823,
        lng: 20.379886214144268,
        address: 'Eger, Vár 1, 3300',
        types: ['castle', 'tourist_attraction'],
        rating: 4.8,
      ),
      Poi(
        placeId: '3',
        name: 'Dobó István tér',
        description: 'A város főtere, a barokk belváros szíve.',
        lat: 47.902535, 
        lng: 20.377256,
        address: 'Eger, Dobó István tér, 3300',
        types: ['plaza'],
      ),
    ];
  }
}