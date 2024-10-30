// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printing/printing.dart';
import '../connect_ui.dart';
import '../database/app_database.dart';
import '../models/multi_print_menu.dart';
import 'package:pdf/widgets.dart' as pw;

class MultiplePhotosDetailWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final MultiPrintItem multiPrintItem;

  const MultiplePhotosDetailWidget.withMultiplePhotos(
      {super.key, required this.multiPrintItem});

  @override
  State<MultiplePhotosDetailWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<MultiplePhotosDetailWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  //
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

  void checkPrinterInDB() {
    noteDatabase.readAll().then((printerList) {
      setState(() {
        // _printListDataBase = printerList;
        print("printerList : ${printerList.length}");
        if (printerList.isEmpty) {
          isPrinterConnected = false;
        } else {
          isPrinterConnected = true;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    //
    checkPrinterInDB();
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(),
          child: Column(
            children: [
              // appbar
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 15.0, bottom: 10.0, top: 10.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 40),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Preview",
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // content view
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 15.0, bottom: 10.0, top: 10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *
                      0.6, // 60% of screen height
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  alignment: Alignment.center,
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: SizedBox(
                        child: buildLayout(widget.multiPrintItem.frame)),
                  ),
                ),
                /*
               child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 40),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Select Layout",
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            // fontWeight: FontWeight.w900,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20),
                      ),
                    )
                  ],
                ),
               
                */
              ),
              // print image button
              Row(
                // Print button
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.menuColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        print("isPrinterConnected : $isPrinterConnected");
                        if (isPrinterConnected) {
                          // print screenshot photo...
                          var frameNumber =
                              int.parse(widget.multiPrintItem.frame[0]);
                          var filledCount = _selectedImages
                              .where((object) => object != null)
                              .length;

                          if (filledCount < frameNumber) {
                            //
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("please fill the Layout"),
                            ));
                          } else {
                            //
                            _printCurrentLayout();
                          }
                          //
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectUi(),
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Row(children: [
                          Container(
                              margin: EdgeInsets.only(right: 8, left: 0),
                              child: Image.asset(
                                'icons/icon_print_outline.png',
                                height: 30,
                                width: 30,
                                color: Colors.white,
                              )),
                          Ink(
                            child: Text(
                              "Print ${widget.multiPrintItem.title}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              /*
         InkWell(
                onTap: () {},
                child: Container(
                  // AD
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
                ),
              )
                    
                  */
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLayout(String frame) {
    switch (frame) {
      case '2 square':
        return buildVerticalBoxes(2, 100 * scaleFactor, 50 * scaleFactor);
      case '4 cube':
        return buildGridBoxes(4, 2, 50 * scaleFactor, 30 * scaleFactor);
      case '3 square':
        return buildVerticalBoxes(3, 100 * scaleFactor, 30 * scaleFactor);
      case '4 circle':
        return buildGridCircularBoxes(4);
      case '6 square':
        return buildGridBoxes(6, 2, 50 * scaleFactor, 30 * scaleFactor);
      case '8 square':
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
            color: AppColor.menuColor,
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
    double screenWidth = MediaQuery.of(context).size.width * 0.88;
    double screenHeight = MediaQuery.of(context).size.height *
        0.6; // 60% of screen height for preview

    // Define a base margin for circles
    double margin = 10.0;

    // Calculate the maximum diameter for each circle to avoid overlap
    double maxDiameter =
        ((screenWidth - (margin * 2)) / 2).clamp(50.0, screenHeight / 2);

    // Calculate columns based on screen width and diameter including margins
    int columns = (screenWidth / (maxDiameter + margin)).floor();
    double diameter =
        (screenWidth / columns) - margin; // Adjust diameter for each circle

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
                onTap: () => _pickImage(boxIndex),
                child: Container(
                  width: diameter,
                  height: diameter,
                  margin:
                      EdgeInsets.all(margin), // Add margin around each circle
                  decoration: BoxDecoration(
                    color: AppColor.menuColor,
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
                              style: TextStyle(color: Colors.white)),
                        ),
                ),
              );
            } else {
              return SizedBox(
                width: diameter,
                height: diameter,
              ); // Empty space for alignment
            }
          }),
        );
      }),
    );
  }

  Widget buildGridBoxes(int count, int columns, double width, double height) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =
        MediaQuery.of(context).size.height * 0.5; // 50% of screen height

    // Calculate the width for each box based on columns
    double boxWidth = screenWidth / columns;

    // Calculate the height for each box based on rows required for `count`
    int rows = (count / columns).ceil();
    double boxHeight = screenHeight / rows;

    return Center(
      child: SizedBox(
        width: screenWidth, // Full screen width for the grid
        height: screenHeight, // 50% of screen height for the grid
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: boxWidth / boxHeight,
          ),
          itemCount: count,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: boxWidth,
                height: boxHeight,
                margin: EdgeInsets.all(5), // Margin for spacing
                color: AppColor.menuColor,
                child: _selectedImages[index] != null
                    ? Image.file(
                        File(_selectedImages[index]!.path),
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text("Tap to select image",
                            style: TextStyle(color: Colors.white)),
                      ),
              ),
            );
          },
        ),
      ),
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

  Column twoSquares(int index) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 50,
          color: widget.multiPrintItem.isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          width: 100,
          height: 50,
          color: widget.multiPrintItem.isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
      ],
    );
  }

  Row fourSquares(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              width: 50,
              height: 50,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              width: 50,
              height: 50,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 50,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 50,
              height: 50,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
      ],
    );
  }

  Column threeSquares(int index) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 30,
          color: widget.multiPrintItem.isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 30,
          color: widget.multiPrintItem.isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 30,
          color: widget.multiPrintItem.isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
      ],
    );
  }

  Row fourCircles(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.multiPrintItem.isSelected
                    ? AppColor.skyBlue
                    : AppColor.borderColor,
              ),
              margin: EdgeInsets.only(bottom: 10),
              width: 50,
              height: 50,
              // color: AppColor.blueColor,
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.multiPrintItem.isSelected
                    ? AppColor.skyBlue
                    : AppColor.borderColor,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(bottom: 10),
              width: 50,
              height: 50,
              // color: AppColor.blueColor,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.multiPrintItem.isSelected
                    ? AppColor.skyBlue
                    : AppColor.borderColor,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 50,
              // color: AppColor.blueColor,
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.multiPrintItem.isSelected
                    ? AppColor.skyBlue
                    : AppColor.borderColor,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 50,
              // color: AppColor.blueColor,
            ),
          ],
        ),
      ],
    );
  }

  Column sixSquares(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
      ],
    );
  }

  Column eightSquares(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(bottom: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 50,
              height: 30,
              color: widget.multiPrintItem.isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
      ],
    );
  }
}
