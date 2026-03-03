import 'package:flutter/material.dart';
import 'package:maps_testing/data/repositories/google_places_repository.dart';
import 'package:maps_testing/firebase_options.dart';
import 'package:maps_testing/logic/location_provider.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'logic/poi_provider.dart';
import 'pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final poiRepository = MockPoiRepository();
    final poiRepository = GooglePlacesRepository(
      apiKey: dotenv.env['MAPS_API_KEY'] ?? '',
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoiProvider(poiRepository)),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MaterialApp(
        title: "Eger Térkép App",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[700]!),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
