// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ninepatch_image/ninepatch_image.dart'; // Replace with your .9.png handling package

class DynamicNinePatchFrame extends StatefulWidget {
  @override
  _DynamicNinePatchFrameState createState() => _DynamicNinePatchFrameState();
}

class _DynamicNinePatchFrameState extends State<DynamicNinePatchFrame> {
  String selectedFrame = 'icons/frame_brown.9.png';
  List<String> frameImages = [
    'icons/frame_brown.9.png',
    'icons/frame_yellow.9.png',
    'icons/frame_grey.9.png',
    'icons/frame_red_purple.9.png',
    'icons/frame_blue_light.9.png',
    'icons/frame_green_tree.9.png',
    'icons/frame_green_light.9.png',
    'icons/frame_purple_light.9.png',
    'icons/frame_pink.9.png',
  ];

  // String selectedFrame = defaultFrame; // Default frame
  ImageProvider? childImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic 9-Patch Frame')),
      body: Column(
        children: [
          // Main Image with Selected Frame
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () async {
                  // Open gallery to pick an image
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      childImage = FileImage(File(pickedFile.path));
                    });
                  }
                },
                child: NinePatchImage(
                  hideLines: true,
                  imageProvider: AssetImage(selectedFrame),
                  child: childImage != null
                      ? Image(
                          image: childImage!,
                          fit: BoxFit.fill,
                        ) // Show selected image
                      : Center(
                          child: Text(
                            'Tap to add image',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                ),
              ),
            ),
          ),
          // Horizontal Scroll List of .9.png Frames
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: frameImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Change the selected frame when an item is tapped
                    setState(() {
                      selectedFrame = frameImages[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      frameImages[index],
                      width: 80,
                      height: 80,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DynamicNinePatchFrame(),
  ));
}
