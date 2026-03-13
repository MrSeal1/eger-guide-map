import 'package:flutter/material.dart';
import 'package:maps_testing/logic/location_provider.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:maps_testing/pages/list_page.dart';
import 'package:maps_testing/pages/map_page.dart';
import 'package:maps_testing/pages/profile_page.dart';
import 'package:maps_testing/pages/route_builder_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // térképen kezd

  @override
  void initState() {
    super.initState();
    context.read<LocationProvider>().loadUserPosition();
  }

  final List<Widget> _pages = const [
    ProfilePageWidget(),
    RouteBuilderPage(),
    MapPage(),
    ListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Consumer<UserDataProvider>(
        builder: (context, userData, child) {
          final routeCount = userData.plannedRoute.length;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.person),
                label: "Profil",
              ),

              NavigationDestination(
                icon: Badge(
                  isLabelVisible: routeCount > 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: Text(
                    routeCount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  child: const Icon(Icons.alt_route_rounded),
                ),
                label: "Útvonal",
              ),

              const NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: "Térkép",
              ),
              
              const NavigationDestination(
                icon: Icon(Icons.list_rounded),
                label: "Lista",
              ),
            ],
          );
        },
      ),
    );
  }
}
