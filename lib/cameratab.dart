import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
              icon: const Icon(Icons.photo_camera),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image == null) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: image.path)),
                );
              },
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              label: const Text("Select a picture"),
              icon: const Icon(Icons.photo_album),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image == null) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: image.path)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
