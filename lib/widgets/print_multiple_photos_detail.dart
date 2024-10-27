// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printer_app/utils/colors.dart';
import '../database/app_database.dart';
import '../models/multi_print_menu.dart';
import 'multiple_formats/convert_to_pdf.dart';
import 'multiple_formats/four_boxes_pdf.dart';

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
              Padding(
                // appbar
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
                    Container(
                      margin: EdgeInsets.only(right: 40),
                      child: Text(
                        textAlign: TextAlign.center,
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
              // grids
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ConvertToPdfPage(),
                      Center(
                        child: Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: [
                                if (widget.multiPrintItem.frame == "2 square")
                                  twoSquares(0)
                                else if (widget.multiPrintItem.frame ==
                                    "4 cube")
                                  FourBoxesWidget()
                                // fourSquares(1)
                                else if (widget.multiPrintItem.frame ==
                                    "3 square")
                                  threeSquares(2)
                                else if (widget.multiPrintItem.frame ==
                                    "4 circle")
                                  fourCircles(3)
                                else if (widget.multiPrintItem.frame ==
                                    "6 square")
                                  sixSquares(4)
                                else if (widget.multiPrintItem.frame ==
                                    "8 square")
                                  eightSquares(5)
                                else
                                  Spacer(),
                                Container(),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
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
