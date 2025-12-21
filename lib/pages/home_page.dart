import 'package:flutter/material.dart';
import 'package:maps_testing/pages/list_page.dart';
import 'package:maps_testing/pages/map_page.dart';
import 'package:maps_testing/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ProfilePageWidget(),
    MapPage(),
    ListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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