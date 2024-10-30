import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart'; // Make sure to include the image package in your pubspec.yaml

// Import for image manipulation

import '../../utils/colors.dart';

class PrintNotes extends StatefulWidget {
  const PrintNotes({Key? key}) : super(key: key);

  @override
  State<PrintNotes> createState() => _PrintNotesState();
}

class _PrintNotesState extends State<PrintNotes> {
  List<Image> imageList = [];
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _gridKey = GlobalKey(); // Add key for RepaintBoundary

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 15.0, bottom: 10.0, top: 10.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 40),
                        child: const Text(
                          textAlign: TextAlign.center,
                          "Notes",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tap on image container to pick a new image
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        // onTap: _pickImage,
                        child: Placeholder(),
                      ),
                    ),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                            right: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            // onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Text(
                                "Change Image",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 15,
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            // onTap: printImageGrid, // Call print function
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Text(
                                "Print Image",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // AD
                    Container(
                      margin: const EdgeInsets.only(
                          top: 0, bottom: 0, left: 0, right: 0),
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(30),
                        color: AppColor.adColor.withOpacity(0.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "AD",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to split the image into parts
List<Image> splitImage(Uint8List input, int rows, int columns) {
  img.Image? image = img.decodeImage(input);

  // Calculate width and height for each part
  int width = (image!.width / columns).round();
  int height = (image.height / rows).round();

  // Adjust for rounding issues to fit exact image size
  int lastColumnWidth = image.width - (width * (columns - 1));
  int lastRowHeight = image.height - (height * (rows - 1));

  // Split the image into parts
  List<img.Image> parts = [];
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < columns; j++) {
      int cropWidth = (j == columns - 1) ? lastColumnWidth : width;
      int cropHeight = (i == rows - 1) ? lastRowHeight : height;

      parts.add(img.copyCrop(image,
          x: j * width, y: i * height, width: cropWidth, height: cropHeight));
    }
  }

  // Convert parts into Image widgets
  return parts.map((singlePart) {
    return Image.memory(
      Uint8List.fromList(img.encodePng(singlePart)),
      fit: BoxFit.fill,
    );
  }).toList();
}

// Uint8List
// img.copyCrop(image,x: j * width,y: i * height, width: width, height: height)
//   img.Image part = img.copyCrop(image,x:  x,y:  y,width:  cropWidth,height:  cropHeight);
