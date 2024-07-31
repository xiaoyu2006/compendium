import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'albumtab.dart';
import 'cameratab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(CompendiumApp());
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
      home: HomeTabController(),
    );
  }
}

class HomeTabController extends StatelessWidget {
  const HomeTabController({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Compendium"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo_camera)),
              Tab(icon: Icon(Icons.photo_album)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CameraTab(),
            AlbumTab(),
          ],
        ),
      ),
    );
  }
}
