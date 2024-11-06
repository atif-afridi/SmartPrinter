// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ninepatch_image/ninepatch_image.dart';

import '../connect_ui.dart';
import '../database/app_database.dart';
import '../utils/colors.dart'; // Replace with your .9.png handling package

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class DynamicNinePatchFrame extends StatefulWidget {
  @override
  _DynamicNinePatchFrameState createState() => _DynamicNinePatchFrameState();
}

class _DynamicNinePatchFrameState extends State<DynamicNinePatchFrame> {
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
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

  ImageProvider? childImage;
  final ImagePicker _picker = ImagePicker();
  GlobalKey previewContainer = GlobalKey(); // RepaintBoundary key

  void checkPrinterInDB() {
    noteDatabase.readAll().then((printerList) {
      setState(() {
        isPrinterConnected = printerList.isNotEmpty;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkPrinterInDB();
  }

  Future<void> _printCurrentLayout() async {
    try {
      RenderRepaintBoundary boundary = previewContainer.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();
      final pdf = pw.Document();
      final imageMemory = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            final pdfWidth = PdfPageFormat.a4.width;
            final pdfHeight = PdfPageFormat.a4.height;
            double aspectRatio = image.width / image.height;
            double scaledWidth, scaledHeight;

            if (aspectRatio > pdfWidth / pdfHeight) {
              scaledWidth = pdfWidth;
              scaledHeight = pdfWidth / aspectRatio;
            } else {
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
      print("Error capturing layout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 40),
                      child: Text(
                        "Preview",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: previewContainer,
                  child: InkWell(
                    onTap: () async {
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
                          ? Image(image: childImage!, fit: BoxFit.fill)
                          : Center(
                              child: Text(
                                'Tap to add image',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: frameImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                  decoration: BoxDecoration(
                    color: AppColor.menuColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isPrinterConnected) {
                        if (childImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please add image")),
                          );
                        } else {
                          _printCurrentLayout();
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ConnectUiWidget()),
                        ).then((_) => setState(() {}));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              'icons/icon_print_outline.png',
                              height: 30,
                              width: 30,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Print",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
