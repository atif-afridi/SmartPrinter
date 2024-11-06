// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printing/printing.dart';
// import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:screenshot/screenshot.dart';
import 'package:scroll_screenshot/scroll_screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import '../connect_ui.dart';
import '../database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;

import '../main.dart';
//

// #docregion platform_imports
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class RenderWebPageWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String buttonText;
  final String? urlToOpen;
  final String? pdfFilePath;

  // Named constructor for WebPage
  const RenderWebPageWidget.withWebPage({super.key, required this.buttonText})
      : pdfFilePath = null,
        urlToOpen = null;

  const RenderWebPageWidget.withWebView(
      {super.key, required this.buttonText, required this.urlToOpen})
      : pdfFilePath = null;

  // Named constructor for pdfFilePath
  const RenderWebPageWidget.withPdf({
    super.key,
    required this.buttonText,
    required this.pdfFilePath,
  }) : urlToOpen = null;
  // });

  @override
  State<RenderWebPageWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<RenderWebPageWidget> {
  //
  final String urlToOpen = "https://google.com";
  final GlobalKey _globalKey = GlobalKey();
  InAppWebViewController? _webViewController;
  bool isCapturing = false;
  Uint8List? screenshotBytes;
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  bool isEditClicked = false;
  String editTitle = "Edit";
  //
  // bool _isPageLoading = true;
  bool _isPageLoading = false;
  double _scrollHeight = 300.0;

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
    // initWebPageController(urlToOpen);
    // screenShotView();
  }

  Future<void> _printWebPageScreenshot(Uint8List capturedPhoto) async {
    try {
      Uint8List imageInUnit8List = capturedPhoto;
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      file.writeAsBytesSync(imageInUnit8List);

      final doc = pw.Document();
      var photoBytes = await File(file.path).readAsBytes();
      final pageFormat = PdfPageFormat.a4;

      // print(MediaQuery.of(ctx).size.height);

      doc.addPage(pw.Page(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                // pw.MemoryImage(_imageBytes),
                pw.MemoryImage(photoBytes),
                // height: _scrollHeight,
                // width: pageFormat.height - 20,
                fit: pw.BoxFit.fitWidth,
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

  void _sendPhotoToPrinter(Uint8List screenshot) async {
    try {
      Uint8List imageInUnit8List = screenshot;
      final tempDir = await getTemporaryDirectory();
      // File file = await File('${tempDir.path}/image.png').create();
      File file = await File('${tempDir.path}/image.pdf').create();
      file.writeAsBytesSync(imageInUnit8List);

      var photoBytes = await File(file.path).readAsBytes();

      /**/
      // Decode the screenshot
      final originalImage = img.decodeImage(screenshot);
      // Check if decoding was successful
      if (originalImage == null) {
        print('Error decoding the screenshot');
        return;
      }

      // Resize the image to fit A4 page width and maintain aspect ratio
      final resizedImage = img.copyResize(
        originalImage,
        // width: 595, // A4 width in points for PDF
        height: _scrollHeight.toInt(), // A4 width in points for PDF
      );

      // Convert the resized image back to Uint8List
      final resizedImageBytes = Uint8List.fromList(img.encodePng(resizedImage));

      /**/

      // print(MediaQuery.of(ctx).size.height);
      final doc = pw.Document();
      final pageFormat = PdfPageFormat.a4;
      doc.addPage(pw.Page(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                height: _scrollHeight,
                // pw.MemoryImage(photoBytes),
                pw.MemoryImage(resizedImageBytes),
                // pw.MemoryImage(capturedPhoto),
                // width: pageFormat.height - 20,
                // fit: pw.BoxFit.fitWidth,
                fit: pw.BoxFit.contain,
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

  // Future<Uint8List> _capturePng() async {
  void _capturePng() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    var screenShotUin8List = await _webViewController!.takeScreenshot();

    if (boundary.debugNeedsPaint) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }

    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);

    // _showCapturedWidget(context, byteData!.buffer.asUint8List());
    // _sendPhotoToPrinter(screenShotUin8List!);
    _showCapturedWidget(context, screenShotUin8List!);

    // return byteData!.buffer.asUint8List();

    ////////////////////

    // return Future.delayed(const Duration(milliseconds: 20), () async {
    //   RenderRepaintBoundary boundary = _globalKey.currentContext!
    //       .findRenderObject() as RenderRepaintBoundary;
    //   ui.Image image = await boundary.toImage();
    //   print("image height : ${image.height} width : ${image.width}");
    //   ByteData? byteData =
    //       await image.toByteData(format: ui.ImageByteFormat.png);
    //   Uint8List pngBytes = byteData!.buffer.asUint8List();
    //   print("created pngBytes");
    //   _showCapturedWidget(context, pngBytes);
    //   return pngBytes;
    // });
  }

  Future<dynamic> _showCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () {
                _sendPhotoToPrinter(capturedImage);
              },
              child: Text("Print"),
            ),
            Expanded(child: Center(child: Image.memory(capturedImage))),
          ],
        ),
      ),
    );
  }

  Future<void> _captureFullPageScreenshot() async {
    /*
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 1);
    print("create screenshot image");

    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    */
    // final pngBytes = await _capturePng();
    _capturePng();

    // final tempDir = await getTemporaryDirectory();
    // File file = await File('${tempDir.path}/image.png').create();
    // await file.writeAsBytes(pngBytes);
    // print("write to file ");

    // print("Full screenshot saved to $tempDir");

    // try {
    //   final doc = pw.Document();
    //   final pageFormat = PdfPageFormat.a4;

    //   doc.addPage(pw.Page(
    //       pageFormat: pageFormat,
    //       orientation: pw.PageOrientation.portrait,
    //       build: (pw.Context context) {
    //         return pw.Center(
    //           child: pw.Image(
    //             pw.MemoryImage(pngBytes),
    //             width: pageFormat.height - 20,
    //             fit: pw.BoxFit.fitWidth,
    //           ),
    //         );
    //       }));

    //   // 打印
    //   await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => doc.save(),
    //   );
    // } catch (e) {
    //   debugPrint("Error printing photo $e");
    // }
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Stack(
                    children: [
                      previewScrollingWebPage(),
                      // lottie loading
                      _isPageLoading
                          ? Lottie.asset('icons/loading_icon.json')
                          : SizedBox(),
                      // Print button...
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
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
                                    print(
                                        "isPrinterConnected : $isPrinterConnected");
                                    /* MediaQuery.of(context).size.height */

                                    if (isPrinterConnected) {
                                      await _captureFullPageScreenshot();
                                    } else {
                                      // open search printer ui
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ConnectUiWidget(),
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
                                          margin: EdgeInsets.only(
                                              right: 8, left: 0),
                                          child: Image.asset(
                                            'icons/icon_print_outline.png',
                                            height: 30,
                                            width: 30,
                                            color: Colors.white,
                                          )),
                                      Ink(
                                        child: Text(
                                          "Print ${widget.buttonText}",
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
                        ),
                      ),
                    ],
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

  // This calculates the height
  void updateHeight() async {
    int height = await _webViewController!
        .evaluateJavascript(source: "document.documentElement.scrollHeight;");
    print(height); // prints height
    if (mounted) {
      setState(() {
        _scrollHeight = height.toDouble();
        print("_scrollHeight : $_scrollHeight");
      });
    }
  }

  Column previewScrollingWebPage() {
    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: _globalKey,
            child: Column(
              children: [
                Text("testing"),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: _scrollHeight,
                      child: InAppWebView(
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            supportZoom: false,
                            javaScriptEnabled: true,
                            disableHorizontalScroll: true,
                            disableVerticalScroll: true,
                          ),
                        ),
                        webViewEnvironment: webViewEnvironment,
                        initialUrlRequest: URLRequest(url: WebUri(urlToOpen)),
                        // initialUserScripts:
                        //     UnmodifiableListView<UserScript>([]),
                        // initialSettings: settings,
                        onWebViewCreated: (controller) async {
                          _webViewController = controller;
                        },
                        onLoadStart: (controller, url) async {
                          setState(() {
                            _isPageLoading = true;
                          });
                        },
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                              resources: request.resources,
                              action: PermissionResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunchUrl(uri)) {
                              // Launch the App
                              await launchUrl(
                                uri,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          // show  screenshot.
                          _webViewController = controller;
                          await Future.delayed(Duration(seconds: 3));
                          updateHeight();
                          setState(() {
                            _isPageLoading = false;
                          });
                        },
                        onReceivedError: (controller, request, error) {},
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            // pullToRefreshController?.endRefreshing();
                          }
                          setState(() {
                            // this.progress = progress / 100;
                            // urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, isReload) {
                          setState(() {
                            // this.url = url.toString();
                            // urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print("InAppWebView : $consoleMessage");
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
