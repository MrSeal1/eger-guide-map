import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/mock_poi_repository.dart';
import 'logic/poi_provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final poiRepository = MockPoiRepository();

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