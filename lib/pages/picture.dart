// ignore_for_file: depend_on_referenced_packages, use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sedo/models/box.dart';
import 'package:sedo/pages/drawer_secondary.dart';

class ImageGalleryPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    setState(() {
      _images = files.whereType<File>().toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final File newImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$fileName.png');

      setState(() {
        _images.add(newImage);
      });
    }
  }

  Future<void> _deleteImage(int index) async {
    final file = _images[index];
    await file.delete();

    setState(() {
      _images.removeAt(index);
    });
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Image'),
        content: Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteImage(index);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImagePage(image: image)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSecondary(),

      body: _images.isEmpty
          ? Center(child: Text('No images found'))
          : GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: GestureDetector(
                    onTap: () => _openFullScreen(_images[index]),
                    onLongPress: () => _showDeleteDialog(index),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final File image;

  const FullScreenImagePage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.back_hand,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Box(
        child: ListView(
          children: [InteractiveViewer(child: Image.file(image))],
        ),
      ),
    );
  }
}
