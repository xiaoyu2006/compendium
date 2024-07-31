import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'model.dart';

class CameraTab extends StatelessWidget {
  const CameraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              label: const Text("Take a picture"),
              heroTag: 'Take a picture',
              icon: const Icon(Icons.add_a_photo),
              onPressed: () => (context) async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image == null) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ConfirmPictureScreen(imagePath: image.path)),
                );
              }(context),
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              label: const Text("Select a picture"),
              heroTag: 'Select a picture',
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: () => (context) async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image == null) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ConfirmPictureScreen(imagePath: image.path)),
                );
              }(context),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmPictureScreen extends StatelessWidget {
  final String imagePath;

  const ConfirmPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Picture')),
      body: Center(child: Image.file(File(imagePath))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceQuery(imagePath: imagePath)),
          );
        },
        tooltip: 'Confirm',
        heroTag: 'Confirm $imagePath',
        child: const Icon(Icons.check),
      ),
    );
  }
}

class ServiceQuery extends StatefulWidget {
  final String imagePath;

  const ServiceQuery({super.key, required this.imagePath});

  @override
  State<ServiceQuery> createState() => _ServiceQueryState();
}

class _ServiceQueryState extends State<ServiceQuery> {
  late final Future<String> response = () async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("https://compendium.ycao.top/query/"),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', widget.imagePath));
    final response = await request.send();
    return response.stream.bytesToString();
  }();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection')),
      body: FutureBuilder<String>(
        future: response,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final responseJson =
              jsonDecode(snapshot.data!) as Map<String, dynamic>;
          return Scaffold(
            body: Center(child: Text('Response: ${snapshot.data}')),
            floatingActionButton: FloatingActionButton(
                onPressed: () => (context) async {
                      final newEntry = await CompendiumEntry.fromResponse(
                        responseJson["response"],
                        widget.imagePath,
                      );
                      await CompendiumDBManager().insert(newEntry);
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    }(context),
                child: const Icon(Icons.library_add)),
          );
        },
      ),
    );
  }
}
