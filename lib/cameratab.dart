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
          Navigator.pop(context);
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
              (jsonDecode(snapshot.data!) as Map<String, dynamic>)["response"];
          return ShowResponse(
            responseJson: responseJson,
            imagePath: widget.imagePath,
          );
        },
      ),
    );
  }
}

class ShowResponse extends StatelessWidget {
  const ShowResponse({
    super.key,
    required this.responseJson,
    required this.imagePath,
  });

  final Map<String, dynamic> responseJson;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageWithRect(
              imagePath: imagePath,
              x1: responseJson['x1'],
              y1: responseJson['y1'],
              x2: responseJson['x2'],
              y2: responseJson['y2']),
          Text(responseJson.toString()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => (context) async {
                final newEntry = await CompendiumEntry.fromResponse(
                  responseJson,
                  imagePath,
                );
                await CompendiumDBManager().insert(newEntry);
                Navigator.pop(context);
              }(context),
          child: const Icon(Icons.library_add)),
    );
  }
}

class ImageWithRect extends StatefulWidget {
  const ImageWithRect({
    super.key,
    required this.imagePath,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final String imagePath;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  @override
  State<ImageWithRect> createState() => _ImageWithRectState();
}

class _ImageWithRectState extends State<ImageWithRect> {
  final GlobalKey _imageKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });

    return Stack(
      children: [
        Image.file(
          File(widget.imagePath),
          key: _imageKey,
        ),
      ],
    );
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final x = widget.x1 * size.width;
    final y = widget.y1 * size.height;
    final w = (widget.x2 - widget.x1) * size.width;
    final h = (widget.y2 - widget.y1) * size.height;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + x,
        top: position.dy + y, // Adjust the position as needed
        child: Container(
          width: w, // Adjust the size as needed
          height: h, // Adjust the size as needed
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 3,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}
