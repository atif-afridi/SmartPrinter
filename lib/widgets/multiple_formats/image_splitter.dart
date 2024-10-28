import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image/image.dart'
    as img; // Make sure to include the image package in your pubspec.yaml

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