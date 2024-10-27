import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DynamicGridWidget extends StatefulWidget {
  @override
  _DynamicGridWidgetState createState() => _DynamicGridWidgetState();
}

class _DynamicGridWidgetState extends State<DynamicGridWidget> {
  int currentLayout = 1;
  GlobalKey _globalKey = GlobalKey();
  double scaleFactor = 1.0; // Define the scale factor
  List<XFile?> _selectedImages = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null
  ]; // List to hold selected images

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: currentLayout,
              items: [
                DropdownMenuItem(value: 1, child: Text("2 Boxes (100x50)")),
                DropdownMenuItem(value: 2, child: Text("3 Boxes (100x30)")),
                DropdownMenuItem(value: 3, child: Text("4 Circles (50x50)")),
                DropdownMenuItem(
                    value: 4, child: Text("6 Boxes (50x30, 2 columns)")),
                DropdownMenuItem(
                    value: 5, child: Text("8 Boxes (50x30, 2 columns)")),
              ],
              onChanged: (value) {
                setState(() {
                  currentLayout = value ?? 1;
                });
              },
            ),
            SizedBox(height: 20),
            // Preview the layout before printing with full screen dimensions
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height *
                  0.6, // 60% of screen height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: RepaintBoundary(
                key: _globalKey,
                child: buildLayout(currentLayout),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _printCurrentLayout(),
              child: Text("Print Layout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLayout(int layout) {
    switch (layout) {
      case 1:
        return buildVerticalBoxes(2, 100 * scaleFactor, 50 * scaleFactor);
      case 2:
        return buildVerticalBoxes(3, 100 * scaleFactor, 30 * scaleFactor);
      case 3:
        return buildGridCircularBoxes(4); // Adjusted to 4 for scaling
      case 4:
        return buildGridBoxes(6, 2, 50 * scaleFactor, 30 * scaleFactor);
      case 5:
        return buildGridBoxes(8, 2, 50 * scaleFactor, 30 * scaleFactor);
      default:
        return Container();
    }
  }

  Widget buildVerticalBoxes(int count, double width, double height) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height *
        0.5; // Adjusted for 50% of screen height

    // Calculate the actual width for the boxes
    double boxWidth =
        (screenWidth); // Each box fills the available width based on count

    // Calculate the height for each box based on available height and count
    double boxHeight =
        (screenHeight / count); // Height based on available height and limit

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return GestureDetector(
          onTap: () => _pickImage(index), // Open image picker on tap
          child: Container(
            width: boxWidth,
            height: boxHeight,
            margin: EdgeInsets.symmetric(
                vertical: 5, horizontal: 10), // Margin for spacing
            color: Colors.blue,
            child: _selectedImages[index] != null
                ? Image.file(
                    File(_selectedImages[index]!.path),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text("Tap to select image",
                        style: TextStyle(color: Colors.white))),
          ),
        );
      }),
    );
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages[index] =
            image; // Store the selected image in the corresponding index
      });
    }
  }

  Widget buildGridCircularBoxes(int totalBoxes) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height *
        0.6; // 60% of screen height for preview

    // Calculate the maximum diameter for the circles
    double maxDiameter = (screenWidth / 2)
        .clamp(50.0, screenHeight / 2); // Ensure circles are not too small

    // Adjust the max diameter to account for margins
    double adjustedMaxDiameter =
        maxDiameter - 30; // Subtract margin space (10 on each side)

    // Calculate the number of columns based on available width
    int columns = (screenWidth / adjustedMaxDiameter).floor();
    double diameter =
        adjustedMaxDiameter; // Set the diameter based on adjusted max diameter

    // Calculate the number of rows needed
    int rows = (totalBoxes / columns).ceil();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(rows, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(columns, (columnIndex) {
            int boxIndex = rowIndex * columns + columnIndex;
            if (boxIndex < totalBoxes) {
              return GestureDetector(
                onTap: () => _pickImage(rowIndex),
                child: Container(
                  width: diameter,
                  height: diameter,
                  margin: EdgeInsets.all(10), // Add margin to each circle
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: _selectedImages[boxIndex] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: Image.file(
                            File(_selectedImages[boxIndex]!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text("Tap to select image",
                              style: TextStyle(color: Colors.white))),
                ),
              );
            } else {
              return SizedBox(
                  width: diameter,
                  height: diameter); // Empty space for alignment
            }
          }),
        );
      }),
    );
  }

  Widget buildGridBoxes(int count, int columns, double width, double height) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height *
        0.5; // Use 50% of the screen height

    // Calculate the width for each box based on the number of columns
    double boxWidth = (screenWidth / columns)
        .clamp(0, width); // Each box fills the available width based on columns

    // Calculate the height for each box based on the total boxes and available height
    double boxHeight = (screenHeight / ((count / columns).ceil()))
        .clamp(0, height); // Adjust height based on rows

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: boxWidth /
            boxHeight, // Maintain aspect ratio based on width and height
      ),
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => _pickImage(index),
          child: Container(
            width: boxWidth,
            height: boxHeight,
            margin: EdgeInsets.all(5), // Margin for spacing
            color: Colors.blue,
            child: _selectedImages[index] != null
                ? Image.file(
                    File(_selectedImages[index]!.path),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text("Tap to select image",
                        style: TextStyle(color: Colors.white))),
          ),
        );
      },
    );
  }

  Future<void> _printCurrentLayout() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final imageMemory = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            // A4 dimensions in points (1 point = 1/72 inch)
            final pdfWidth = PdfPageFormat.a4.width;
            final pdfHeight = PdfPageFormat.a4.height;

            // Calculate the aspect ratio of the image
            double aspectRatio = image.width / image.height;

            // Determine the width and height to scale the image without cropping
            double scaledWidth, scaledHeight;
            if (aspectRatio > pdfWidth / pdfHeight) {
              // Width is limiting factor
              scaledWidth = pdfWidth;
              scaledHeight = pdfWidth / aspectRatio;
            } else {
              // Height is limiting factor
              scaledHeight = pdfHeight;
              scaledWidth = pdfHeight * aspectRatio;
            }

            return pw.Container(
              width: pdfWidth,
              height: pdfHeight,
              child: pw.Center(
                child: pw.Image(
                  imageMemory,
                  width: scaledWidth,
                  height: scaledHeight,
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
          },
          pageFormat: PdfPageFormat.a4,
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print(e);
    }
  }
}
