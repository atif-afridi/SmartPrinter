// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printer_app/widgets/multiple_formats/image_splitter.dart';
import '../database/app_database.dart';
import '../models/multi_print_menu.dart';
import 'multiple_formats/convert_to_pdf.dart';
import 'multiple_formats/dynamic_grid_widget.dart';
import 'print_multiple_photos_detail.dart';

class PrintMultiplePhotosWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String buttonText;

  const PrintMultiplePhotosWidget.withMultiplePhotos(
      {super.key, required this.buttonText});

  @override
  State<PrintMultiplePhotosWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintMultiplePhotosWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  //
  List<MultiPrintItem> multiPrintList = [
    MultiPrintItem(
        isSelected: true,
        title: "2 Per Sheet",
        heightWidth: "100*150 px",
        frame: "2 square",
        iconName: "icons/print_photo.png"),
    MultiPrintItem(
        isSelected: false,
        title: "4 Per Sheet",
        heightWidth: "150*50 px",
        frame: "4 cube",
        iconName: "icons/print_photo.png"),
    MultiPrintItem(
        isSelected: false,
        title: "3 Per Sheet",
        heightWidth: "100*30 px",
        frame: "3 square",
        iconName: "icons/print_photo.png"),
    MultiPrintItem(
        isSelected: false,
        title: "4 Per Sheet",
        heightWidth: "50*50 px",
        frame: "4 circle",
        iconName: "icons/print_photo.png"),
    MultiPrintItem(
        isSelected: false,
        title: "6 Per Sheet",
        heightWidth: "50*30 px",
        frame: "6 square",
        iconName: "icons/print_photo.png"),
    MultiPrintItem(
        isSelected: false,
        title: "8 Per Sheet",
        heightWidth: "50*30 px",
        frame: "8 square",
        iconName: "icons/print_photo.png"),
  ];

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
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: (1 / 1.2),
                          // childAspectRatio: (itemWidth / itemHeight),
                        ),
                        itemCount: multiPrintList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => {
                              for (var i = 0; i < multiPrintList.length; i++)
                                {multiPrintList[i].isSelected = false},
                              setState(() {
                                multiPrintList[index].isSelected = true;
                              }),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      // MultiplePhotosDetailWidget
                                      //     .withMultiplePhotos(
                                      //         multiPrintItem:
                                      //             multiPrintList[index])
                                      /**/
                                      ConvertToPdfPage(),
                                  /**/
                                  //     ImageSplitter(
                                  //   rows: 3,
                                  //   columns: 3,
                                  //   imageUrl:
                                  //       "https://cdn.pixabay.com/photo/2024/05/27/12/27/gargoyle-8791108_1280.jpg",
                                  // ),
                                  // ),
                                  /**/
                                  // DynamicGridWidget()),
                                ),
                              )
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              // width: 150,
                              // height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: multiPrintList[index].isSelected
                                      ? AppColor.skyBlue
                                      : Colors.transparent,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                // color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // logic for grids
                                    if (multiPrintList[index].frame ==
                                        "2 square")
                                      twoSquares(index)
                                    else if (multiPrintList[index].frame ==
                                        "4 cube")
                                      fourSquares(index)
                                    else if (multiPrintList[index].frame ==
                                        "3 square")
                                      threeSquares(index)
                                    else if (multiPrintList[index].frame ==
                                        "4 circle")
                                      fourCircles(index)
                                    else if (multiPrintList[index].frame ==
                                        "6 square")
                                      sixSquares(index)
                                    else if (multiPrintList[index].frame ==
                                        "8 square")
                                      eightSquares(index)
                                    else
                                      Spacer(),
                                    /////
                                    ///
                                    Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Column(
                                        children: [
                                          Text(
                                            multiPrintList[index].title,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            multiPrintList[index].heightWidth,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                // AD
                margin:
                    const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
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
      ),
    );
  }

  Column twoSquares(int index) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.height * 0.1,
          color: multiPrintList[index].isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          width: 100,
          height: 50,
          color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              width: 50,
              height: 50,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 50,
              height: 50,
              color: multiPrintList[index].isSelected
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
          color: multiPrintList[index].isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 30,
          color: multiPrintList[index].isSelected
              ? AppColor.skyBlue
              : AppColor.borderColor,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: 100,
          height: 30,
          color: multiPrintList[index].isSelected
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
                color: multiPrintList[index].isSelected
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
                color: multiPrintList[index].isSelected
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
                color: multiPrintList[index].isSelected
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
                color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
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
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 50,
              height: 30,
              color: multiPrintList[index].isSelected
                  ? AppColor.skyBlue
                  : AppColor.borderColor,
            ),
          ],
        ),
      ],
    );
  }
}
