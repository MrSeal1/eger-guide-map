import 'package:flutter/material.dart';
import 'package:maps_testing/logic/poi_provider.dart';
import 'package:maps_testing/pages/list_page.dart';
import 'package:maps_testing/pages/map_page.dart';
import 'package:maps_testing/pages/profile_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // térképen kezd

  @override
  void initState() {
    super.initState();
    context.read<PoiProvider>().loadUserPosition();
  }

  final List<Widget> _pages = const [
    ProfilePageWidget(),
    MapPage(),
    ListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Térkép"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: "Lista"
          )
        ],
      ),
    );
  }
}