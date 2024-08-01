import 'dart:async';

import 'package:flutter/material.dart';

import 'albumtab.dart';
import 'cameratab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CompendiumApp());
}

class CompendiumApp extends StatelessWidget {
  const CompendiumApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const HomeTabController(),
    );
  }
}

class HomeTabController extends StatefulWidget {
  const HomeTabController({super.key});

  @override
  State<HomeTabController> createState() => _HomeTabControllerState();
}

class _HomeTabControllerState extends State<HomeTabController> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CameraTab(),
    AlbumTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compendium"),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.library_add),
            label: 'New Entry',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: 'Album',
          ),
        ],
      ),
    );
  }
}
