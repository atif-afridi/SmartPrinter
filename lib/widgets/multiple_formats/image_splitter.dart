import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart'
    as img; // Make sure to include the image package in your pubspec.yaml

// Make sure to include this in your pubspec.yaml

// Make sure to include this in your pubspec.yaml

/*

class ImageSplitter extends StatefulWidget {
  final int rows; // Number of rows
  final int cols; // Number of columns
  final double verticalSpacing; // Dynamic vertical spacing

  const ImageSplitter({
    Key? key,
    required this.rows,
    required this.cols,
    this.verticalSpacing = 20.0,
  }) : super(key: key);

  @override
  State<ImageSplitter> createState() => _ImageSplitterState();
}

class _ImageSplitterState extends State<ImageSplitter> {
  List<Image> imageList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Splitter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("Convert"),
              onPressed: () async {
                String imageUrl =
                    "https://cdn.pixabay.com/photo/2024/05/27/12/27/gargoyle-8791108_1280.jpg"; // Ensure this is a valid image URL
                try {
                  Uint8List bytes =
                      (await NetworkAssetBundle(Uri.parse(imageUrl))
                              .load(imageUrl))
                          .buffer
                          .asUint8List();
                  imageList = splitImage(bytes, widget.verticalSpacing);
                  setState(() {});
                } catch (e) {
                  print(
                      "Error loading image: $e"); // Print error if the image fails to load
                }
              },
            ),
            // Fixed height container for the GridView
            Container(
              width: MediaQuery.of(context).size.width,
              height: 500, // Height set to 400
              child: GridView.count(
                crossAxisCount: widget.cols,
                childAspectRatio: 1, // Each item is square
                mainAxisSpacing:0348575405-
                    widget.verticalSpacing, // Dynamic vertical spacing
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                padding: EdgeInsets.zero, // Remove any padding around the grid
                children: List.generate(imageList.length, (index) {
                  return ClipRect(
                    child: imageList[index],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Image> splitImage(Uint8List input, double verticalSpacing) {
    // Decode the image using the image package
    img.Image? image = img.decodeImage(input);

    if (image == null) {
      print("Failed to decode image."); // Debug statement
      return []; // Return an empty list if the image cannot be decoded
    }

    // Calculate scaled width and height for each split
    int width = (image.width / widget.cols).round();
    int height = (image.height / widget.rows).round();

    // Split the image into parts
    List<img.Image> parts = [];
    for (int row = 0; row < widget.rows; row++) {
      for (int col = 0; col < widget.cols; col++) {
        int x = col * width;
        int y = row * height;

        // Ensure we do not exceed the image bounds
        int cropWidth = (col < widget.cols - 1)
            ? width
            : image.width - (widget.cols - 1) * width;
        int cropHeight = (row < widget.rows - 1)
            ? height
            : image.height - (widget.rows - 1) * height;

        // Crop the image correctly
        img.Image part = img.copyCrop(image,
            x: x, y: y, width: cropWidth, height: cropHeight);
        parts.add(part);
      }
    }

    // Convert image parts to Image Widgets to display
    List<Image> _imageList = [];
    for (var singlePart in parts) {
      // Scaling each part
      Uint8List scaledImage = Uint8List.fromList(img.encodePng(singlePart));
      _imageList.add(Image.memory(scaledImage));
    }

    return _imageList;
  }
}


*/

// Import the image package

// Import the image package

// Import the image package

// Import the image package

// Import the image package

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageSplitter extends StatefulWidget {
  final int rows;
  final int columns;
  final String imageUrl;
  final double horizontalSpace;
  final double padding;

  const ImageSplitter({
    Key? key,
    required this.rows,
    required this.columns,
    required this.imageUrl,
    this.horizontalSpace = 0.0,
    this.padding = 4.0,
  }) : super(key: key);

  @override
  State<ImageSplitter> createState() => _ImageSplitterState();
}

class _ImageSplitterState extends State<ImageSplitter> {
  List<Image> imageList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                child: const Text("Convert"),
                onPressed: () async {
                  Uint8List bytes =
                      (await NetworkAssetBundle(Uri.parse(widget.imageUrl))
                              .load(widget.imageUrl))
                          .buffer
                          .asUint8List();
                  imageList = splitImage(bytes, widget.rows, widget.columns);
                  setState(() {});
                },
              ),
              Padding(
                padding: EdgeInsets.all(widget.padding),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.columns,
                    mainAxisSpacing: widget.padding,
                    crossAxisSpacing: widget.horizontalSpace,
                    childAspectRatio: 1, // Keep the images square
                  ),
                  itemCount: imageList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(widget.padding),
                      child: imageList[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Image> splitImage(Uint8List input, int rows, int columns) {
  img.Image? image = img.decodeImage(input);

  // Calculate exact width and height for each part
  int width = (image!.width / columns).round();
  int height = (image.height / rows).round();

  // Adjust for possible rounding issues by recalculating to fit the exact image size
  int lastColumnWidth = image.width - (width * (columns - 1));
  int lastRowHeight = image.height - (height * (rows - 1));

  // Split the image into parts
  List<img.Image> parts = [];
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < columns; j++) {
      int cropWidth = (j == columns - 1) ? lastColumnWidth : width;
      int cropHeight = (i == rows - 1) ? lastRowHeight : height;

      parts.add(img.copyCrop(image,
          x: j * width, y: i * height, width: width, height: height));
    }
  }

  // Convert the parts into Image widgets
  List<Image> _imageList = [];
  for (var singlePart in parts) {
    _imageList.add(
      Image.memory(
        Uint8List.fromList(img.encodePng(singlePart)),
        fit: BoxFit.fill, // Make the image fill the container
      ),
    );
  }

  return _imageList;
}

// Uint8List
// img.copyCrop(image,x: j * width,y: i * height, width: width, height: height)
     //   img.Image part = img.copyCrop(image,x:  x,y:  y,width:  cropWidth,height:  cropHeight);