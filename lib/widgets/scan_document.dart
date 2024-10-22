import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printer_app/models/scan_menu_pojo.dart';

import '../connect_ui.dart';
import '../models/print_menu_pojo.dart';
import '../scanner/cunning_document_scanner.dart';
import '../utils/colors.dart';

class ScanDocumentWidget extends StatefulWidget {
  final String title;

  const ScanDocumentWidget({super.key, required this.title});

  @override
  State<ScanDocumentWidget> createState() => _ScanDocumentWidgetState();
}

class _ScanDocumentWidgetState extends State<ScanDocumentWidget> {
  // code
  List<ScanItem> documentTypeList = [
    ScanItem(title: "Scan Document", iconName: "icons/icon_scan_document.png"),
    ScanItem(title: "View Document", iconName: "icons/icon_view_document.png"),
  ];

  List<PrintItem> dataDetectorList = [
    PrintItem(
        title: "QR\nCode",
        startColor: const Color(0xFF947fe9),
        endColor: const Color(0xFFc4d0ff),
        iconName: "icons/icon_qr_code.png"),
    PrintItem(
        title: "Barcode\nScan",
        startColor: const Color(0xFFca47eb),
        endColor: const Color(0xFFf19fff),
        iconName: "icons/icon_barcode_code.png"),
    PrintItem(
        title: "OCR\nImage",
        startColor: const Color(0xFFff9178),
        endColor: const Color(0xFFffd6c9),
        iconName: "icons/icon_ocr_code.png"),
  ];

  Widget bigCircle = Positioned(
    top: -180.0,
    left: -110.0,
    child: Container(
      width: 450,
      height: 350.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          transform: GradientRotation(8),
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColor.lightBlueColor,
            Color(0xFF85f0ff),
          ],
        ),
      ),
    ),
  );

  Widget twoCircles = Positioned(
    top: 150.0,
    right: -20.0,
    child: Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFcbecf1),
          width: 15.0,
        ),
      ),
    ),
  );

  List<String> _pictures = [];

  void onPressed() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;
      setState(() {
        _pictures = pictures;
        print("picture returned");
      });
    } catch (exception) {
      // Handle exception here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      bigCircle,
      twoCircles,
      Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
              // Scan || View Documents.
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // if (kDebugMode) {
                          onPressed();
                          print("open scanning ui");
                          // }
                        },
                        child: Container(
                          height: 100,
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                documentTypeList[0].iconName,
                                height: 50,
                                width: 50,
                              ),
                              Text(
                                documentTypeList[0].title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 20.0),
                    Expanded(
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              documentTypeList[1].iconName,
                              height: 50,
                              width: 50,
                            ),
                            Text(
                              documentTypeList[1].title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // TODO pass the source to widget.
              for (var picture in _pictures)
                Image.file(
                  File(picture),
                  width: double.infinity,
                  height: 100,
                ),

              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text(
                    "Data Detectors",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  )),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 0.0,
                    childAspectRatio: (1 / .66),
                  ),
                  itemCount: dataDetectorList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 60,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      // width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          transform: const GradientRotation(9),
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            dataDetectorList[index].startColor,
                            dataDetectorList[index].endColor,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataDetectorList[index].title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              dataDetectorList[index].iconName,
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 25, bottom: 25),
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
    ]);
  }
}
