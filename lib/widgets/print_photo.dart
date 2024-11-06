// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printing/printing.dart';
import '../connect_ui.dart';
import '../database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintPhotoWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String title;
  final List<XFile>? mediaFileList;
  final String? pdfFilePath;

  // Named constructor for photoList
  const PrintPhotoWidget.withPhotos({
    super.key,
    required this.title,
    required this.mediaFileList,
  }) : pdfFilePath = null;

  // Named constructor for pdfFilePath
  const PrintPhotoWidget.withPdf({
    super.key,
    required this.title,
    required this.pdfFilePath,
  }) : mediaFileList = null;

  @override
  State<PrintPhotoWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintPhotoWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  bool isEditClicked = false;
  String editTitle = "Edit";
  CroppedFile? _croppedFile;

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

  Future<void> _printPdf() async {
    try {
      final doc = pw.Document();
      var photoOrPdf = widget.pdfFilePath ?? widget.mediaFileList![0].path;
      var photoBytes = await File(photoOrPdf).readAsBytes();
      final pageFormat = PdfPageFormat.a4;

      // doc.addPage(pw.Page(
      //     pageFormat: PdfPageFormat.a4,
      //     build: (pw.Context context) {
      //       return pw.Center(
      //         child: pw.Text('Hello Jimmy'),
      //       );
      //     }));

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => photoBytes,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _printPhoto(BuildContext ctx) async {
    try {
      final doc = pw.Document();
      var photoOrPdf = widget.pdfFilePath ?? widget.mediaFileList![0].path;
      var photoBytes = await File(photoOrPdf).readAsBytes();
      final pageFormat = PdfPageFormat.a4;

      doc.addPage(pw.Page(
          pageFormat: pageFormat,
          // orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            // return pw.Center(
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(
                // pw.MemoryImage(_imageBytes),
                pw.MemoryImage(photoBytes),
                // width: pageFormat.height - 20,
                // fit: pw.BoxFit.fitWidth,
              ),
            );
          }));

      // 打印
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      debugPrint("Error printing photo $e");
    }
  }

// Future<void> _printPdf() async {
//     try {
//       final doc = pw.Document();
//       var photoOrPdf = widget.mediaFileList![0].path;
//       var photoBytes = await File(photoOrPdf).readAsBytes();
//       final pageFormat = PdfPageFormat.a4;

  @override
  void initState() {
    super.initState();
    checkPrinterInDB();
  }

  Future<void> _cropImage() async {
    // if (_pickedFile != null) {
    if (widget.mediaFileList != null && widget.mediaFileList!.isNotEmpty) {
      final croppedFile = await ImageCropper().cropImage(
        // sourcePath: _pickedFile!.path,
        sourcePath: widget.mediaFileList![0].path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColor.menuColor,
            activeControlsWidgetColor: AppColor.menuColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          // WebUiSettings(
          //   context: context,
          //   presentStyle: WebPresentStyle.dialog,
          //   size: const CropperSize(
          //     width: 520,
          //     height: 520,
          //   ),
          // ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  PDFView _previewPDF(String path) {
    return PDFView(
      filePath: path,
      fitEachPage: true,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      backgroundColor: Colors.grey,
      onRender: (_pages) {
        setState(() {
          // pages = _pages;
          // isReady = true;
        });
      },
      onError: (error) {
        print(error.toString());
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // _controller.complete(pdfViewController);
      },
      // onPageChanged: (int page, int total) {
      //   print('page change: $page/$total');
      // },
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
      // } else if (_pickedFile != null) {
    } else if (widget.mediaFileList != null &&
        widget.mediaFileList!.isNotEmpty) {
      final path = widget.mediaFileList![0].path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // app bar
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, bottom: 15.0),
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
                          child: Text(
                            textAlign: TextAlign.center,
                            // Title
                            "Preview",
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
                  ),
                  // Edit button
                  Visibility(
                    visible: widget.mediaFileList != null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Preview.
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            // top: 15,
                            bottom: 15,
                          ),
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 8,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.menuColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              _cropImage();
                            },
                            child: Text(
                              editTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // preview
                  if (widget.mediaFileList != null)
                    _image()
                  else
                    Center(
                      child: SizedBox(
                        height: 600,
                        width: double.infinity,
                        child: _previewPDF(widget.pdfFilePath!),
                      ),
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
                          onTap: () async {
                            print("isPrinterConnected : $isPrinterConnected");
                            if (isPrinterConnected) {
                              // print photo...
                              widget.pdfFilePath == null
                                  ? _printPhoto(context)
                                  : _printPdf();
                            } else {
                              /*
                              // Start the flow by navigating to ConnectUiWidget
                              final result = await Navigator.pushNamed(
                                  context, 'ConnectUiWidget');

                              // Check if the result indicates the printer was connected
                              if (result == "printer connected") {
                                print('Printer connection status: $result');
                                // Update UI or perform any additional actions here
                              }
                              */

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConnectUiWidget(),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                              /* OLD CODE */
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
                                  "Print ${widget.title}",
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
                  Container(
                    margin: const EdgeInsets.only(
                        top: 0, bottom: 25, left: 25, right: 25),
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
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
                          fontSize: 50,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
