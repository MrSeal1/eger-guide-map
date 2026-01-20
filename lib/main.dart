import 'package:flutter/material.dart';
import 'package:maps_testing/data/repositories/google_places_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/repositories/mock_poi_repository.dart';
import 'logic/poi_provider.dart';
import 'pages/home_page.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final poiRepository = MockPoiRepository();
    final poiRepository = GooglePlacesRepository(
      apiKey: dotenv.env['MAPS_API_KEY'] ?? ''
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PoiProvider(poiRepository),
        ),
      ],
      child: MaterialApp(
        title: "Eger Térkép App",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[700]!),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}