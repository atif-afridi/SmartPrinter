import 'package:flutter/material.dart';
import 'package:printer_app/utils/colors.dart';
import '../database/app_database.dart';

class PrintFramesWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String buttonText;

  // Named constructor for WebPage
  const PrintFramesWidget.withFrames({super.key, required this.buttonText});
  // : pdfFilePath = null,
  //   urlToOpen = null;

  // const PrintFramesWidget.withPoster(
  //     {super.key, required this.buttonText, required this.urlToOpen})
  //     : pdfFilePath = null;

  // Named constructor for pdfFilePath
  // const PrintFramesWidget.withMultiplePhotos({
  //   super.key,
  //   required this.buttonText,
  //   required this.pdfFilePath,
  // }) : urlToOpen = null;

  @override
  State<PrintFramesWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintFramesWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;

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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text("data comes here"),
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
}
