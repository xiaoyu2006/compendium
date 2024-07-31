import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'model.dart';

class AlbumTab extends StatefulWidget {
  const AlbumTab({Key? key}) : super(key: key);

  @override
  State<AlbumTab> createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab> {
  final Future<List<CompendiumEntry>> entries = CompendiumDBManager().entries();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CompendiumEntry>>(
      future: entries,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10.0, // Horizontal space between grid items
              mainAxisSpacing: 10.0, // Vertical space between grid items
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final CompendiumEntry entry = data[index];
              Uint8List imageBytes = base64Decode(entry.imageBase64);
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: GridTile(
                  child: Column(
                    children: [
                      Image.memory(
                        imageBytes,
                        height: 120.0,
                        width: 120.0,
                        fit: BoxFit.contain,
                      ),
                      Text(entry.wikipediaEntry),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
