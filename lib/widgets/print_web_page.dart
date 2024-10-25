// ignore_for_file: deprecated_member_use

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

class PrintWebPageWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String buttonText;
  final String? urlToOpen;
  final String? pdfFilePath;

  // Named constructor for WebPage
  const PrintWebPageWidget.withWebPage({super.key, required this.buttonText})
      : pdfFilePath = null,
        urlToOpen = null;

  const PrintWebPageWidget.withWebView(
      {super.key, required this.buttonText, required this.urlToOpen})
      : pdfFilePath = null;

  // Named constructor for pdfFilePath
  const PrintWebPageWidget.withPdf({
    super.key,
    required this.buttonText,
    required this.pdfFilePath,
  }) : urlToOpen = null;
  // });

  @override
  State<PrintWebPageWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintWebPageWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  bool isEditClicked = false;
  String editTitle = "Edit";
  //
  // late final WebViewController _controller;
  InAppWebViewController? _webViewController;
  final ScreenshotController _screenshotController = ScreenshotController();
  // bool _isPageLoading = true;
  bool _isPageLoading = false;
  double _scrollHeight = 0.0;

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

  /*
  Future<void> _capturePng(BuildContext ctx) async {
    try {
      final doc = pw.Document();
      var photoBytes = await File(widget.mediaFileList[0].path).readAsBytes();
      final pageFormat = PdfPageFormat.a4;

      print(MediaQuery.of(ctx).size.height);

      doc.addPage(pw.Page(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.landscape,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                // pw.MemoryImage(_imageBytes),
                pw.MemoryImage(photoBytes),
                width: pageFormat.height - 20,
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

  */

  final String urlToOpen = "https://google.com";
// final String urlToOpen = "https://flutter.dev";

  final GlobalKey webViewKey = GlobalKey();
  Uint8List? screenshotBytes;

  // InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  final GlobalKey _globalKey = GlobalKey();
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    //
    checkPrinterInDB();
    // initWebPageController(urlToOpen);
    // screenShotView();
  }

  /*
  
  void initWebPageController(String urlToOpen) {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            //
            findTheWebPageHeight(controller).then((onValue) {
              setState(() {
                _scrollHeight = onValue ?? 1000;
              });
            });

            setState(() {
              _isPageLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
    Page resource error:
      code: ${error.errorCode}
      description: ${error.description}
      errorType: ${error.errorType}
      isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            // openDialog(request);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(urlToOpen));

    // setBackgroundColor is not currently supported on macOS.
    if (kIsWeb || !Platform.isMacOS) {
      controller.setBackgroundColor(const Color(0x80000000));
    }

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  Future<double?> findTheWebPageHeight(WebViewController controller) async {
    var scrollHeight = await controller
        .runJavaScriptReturningResult("document.documentElement.scrollHeight");
    double? y = double.tryParse(scrollHeight.toString());
    debugPrint('parse : $y');

    debugPrint('Size after Page load: $y');
    return y;
  }

  */

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

  // Future<void> captureScreenshot() async {
  //   setState(() {
  //     print('Start');
  //     isCapturing = true;
  //   });
  //   RenderRepaintBoundary boundary =
  //       _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image =
  //       await boundary.toImage(pixelRatio: 3.0); // Adjust pixelRatio as needed
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData!.buffer.asUint8List();
  //   // image bytes...
  //   capturedScreenshots.add(pngBytes);

  //   await Constants.printDocument2(capturedScreenshots, context);
  //   setState(() {
  //     isCapturing = false;
  //     print('End');
  //   });
  //   // Pass the pngBytes to your function for further processing
  //   // e.g., send it to a printer
  // }

// late WebViewController _webViewController;
  // final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _webViewKey = GlobalKey();
  List<Uint8List> _screenshots = [];

  Future<void> _captureFullPageScreenshot() async {
    // Retrieve the total height of the web page
    int totalHeight = await _webViewController?.evaluateJavascript(
        source: "document.documentElement.scrollHeight;");

    int viewportHeight = 600; // Approximate height of the WebView viewport
    double currentScrollPosition = 0;

    while (currentScrollPosition < totalHeight) {
      // Scroll the WebView to the current position
      await _webViewController?.evaluateJavascript(
          source: "window.scrollTo(0, $currentScrollPosition);");
      await Future.delayed(Duration(seconds: 2)); // Allow time for rendering

      var photoUint8List = await _webViewController?.takeScreenshot();

/*
// Capture a screenshot at the current scroll position
      RenderRepaintBoundary boundary = _webViewKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      // Create an image from the boundary
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      // Convert the image to byte data
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
*/

      // if (byteData != null) {
      // Convert byte data to Uint8List
      // Uint8List pngBytes = byteData.buffer.asUint8List();

      // _screenshots.add(pngBytes);
      _screenshots.add(photoUint8List!);
      // }

      // Move to the next scroll position
      currentScrollPosition += viewportHeight;
    }

    // Combine all screenshots into one image
    final stitchedImage = _stitchImages(_screenshots);
    if (stitchedImage != null) {
      // final directory = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();

      File file = await File('${tempDir.path}/image.png').create();

      // final imagePath = '${directory.path}/full_screenshot.png';
      // final file = File(imagePath);
      await file.writeAsBytes(stitchedImage);

      print("Full screenshot saved to $tempDir");

      try {
        // File file = await File(file.path).create();
        // file.writeAsBytesSync(imageInUnit8List);
        // file.writeAsBytesSync(pngBytes);

        final doc = pw.Document();
        var photoBytes = await File(file.path).readAsBytes();
        final pageFormat = PdfPageFormat.a4;

        // print(MediaQuery.of(ctx).size.height);

        String? base64String =
            await ScrollScreenshot.captureAndSaveScreenshot(_webViewKey);

        print("base64String : $base64String");

        doc.addPage(pw.Page(
            pageFormat: pageFormat,
            orientation: pw.PageOrientation.portrait,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  // pw.MemoryImage(_imageBytes),
                  pw.MemoryImage(photoBytes),
                  // pw.MemoryImage(base64Decode(base64String!)),
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

    // Clear the screenshots list after use
    _screenshots.clear();
  }

  Uint8List? _stitchImages(List<Uint8List> images) {
    if (images.isEmpty) return null;

    // final imageObjects = images.map((bytes) => img.decodeImage(bytes)).toList();
    // if (imageObjects.contains(null)) return null;

    // Decode all the images
    final decodedImages = images
        .map((bytes) => img.decodeImage(bytes))
        .whereType<img.Image>()
        .toList();
    if (decodedImages.isEmpty) return null;

    // Determine the final width and height
    final width = decodedImages[0].width;
    final totalHeight =
        decodedImages.fold(0, (sum, image) => sum + image.height);

    // final firstImage = imageObjects.first!;
    // final width = firstImage.width;
    // final totalHeight =
    //     imageObjects.fold(0, (sum, image) => sum + image!.height);

    final fullImage = img.Image(width: width, height: totalHeight);

    // Create a new blank image with the total height and white background
    // final fullImage = img.Image(width, totalHeight);
    // fullImage.fill(0xFFFFFFFF); // White background to avoid black color
    // Manually fill the fullImage with a white background by drawing a rectangle
    // for (int y = 0; y < totalHeight; y++) {
    //   for (int x = 0; x < width; x++) {
    //     fullImage.setPixel(x, y, 0xFFFFFFFFF); // White color
    //   }
    // }

    int offsetY = 0;
    for (final image in decodedImages) {
      // img.draw(fullImage, image!, dstY: offsetY);
      img.compositeImage(fullImage, image, dstY: offsetY);
      offsetY += image.height;
    }

    return Uint8List.fromList(img.encodePng(fullImage));
  }

  Future<void> _printWebPagePreview() async {
    try {
      final boundary = previewContainer.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      // covert to bytes
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      // temp location for storage
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      // file.writeAsBytesSync(imageInUnit8List);
      file.writeAsBytesSync(pngBytes);

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
                width: pageFormat.height - 20,
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

  // Future<void> test() async {
  //   // Capture screenshot
  //   final image = await _screenshotController.capture();
  //   if (image != null) {
  //     // Save image to a file or display it
  //     final directory = await Directory.systemTemp.createTemp();
  //     final filePath = '${directory.path}/screenshot.png';
  //     final file = File(filePath);
  //     // await file.writeAsBytes(image);
  //     await file.writeAsBytes(image);
  //     print('Screenshot saved to $filePath');
  //   }
  // }

  Future<void> _printWebPage(Uint8List onScreenShotCaptured) async {
    try {
      // Save image to a file or display it
      final directory = await Directory.systemTemp.createTemp();
      final filePath = '${directory.path}/screenshot.png';
      final file = File(filePath);
      await file.writeAsBytes(onScreenShotCaptured);
      print('Screenshot saved to $filePath');

      ///
      // if (onScreenShotCaptured != null)
      // var photoBytes = ByteData.view(onScreenShotCaptured.buffer);

      final doc = pw.Document();
      // var photoBytes = await File(widget.mediaFileList![0].path).readAsBytes();
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

  // void screenShotView() {
  //   myLongWidget = Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       SizedBox(
  //         height: _scrollHeight,
  //         child: WebViewWidget(
  //           // key: Key("webview1"),
  //           controller: _controller,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  late Builder myLongWidget;
  static GlobalKey previewContainer = GlobalKey();

  late Column myLongColumnWidget = scrollingWebPage();

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
    //
    // final scrollView = Column(
    //   children: [
    //     Expanded(
    //       child: Screenshot(
    //         controller: _screenshotController,
    //         child: SizedBox(
    //           // width: double.infinity,
    //           height: _scrollHeight,
    //           child: WebViewWidget(
    //             key: Key("webview1"),
    //             controller: _controller,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );

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
                      scrollingWebPage(),
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
                                      // await webPageInAppSS(context);

                                      await _captureFullPageScreenshot();

                                      // print web page...
                                      /*
                                      _screenshotController
                                          .capture()
                                          .then((image) {
                                        if (image != null && mounted) {
                                          _printWebPageScreenshot(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              image);
                                        }
                                      });
                                      */

                                      /*
                                      var randomItemCount =
                                          Random().nextInt(100);
                                      var container =
                                          Builder(builder: (context) {
                                        return WebViewWidget(
                                            controller: _controller);
                                      });
                                      */

/*
_screenshotController
                                          // .capture()
                                          // .captureFromWidget(scrollView,
                                          // .captureFromWidget(myLongColumnWidget,
                                          .captureFromLongWidget(
                                              InheritedTheme.captureAll(
                                                  context,
                                                  Material(
                                                      child:
                                                          myLongColumnWidget)),
                                              delay: Duration(seconds: 2),
                                              context: context)
                                          .then((image) {
                                        ShowCapturedWidget(context, image);
                                        // if (image != null && mounted) {
                                        if (mounted) {
                                          // _printWebPageScreenshot(image);
                                          _printWebPagePreview();
                                        }
                                      });
*/

                                      /////

                                      ///
                                      /*
                                      _screenshotController
                                          .capture()
                                          .then((onScreenShotCaptured) {
                                        if (onScreenShotCaptured != null) {
                                          _printWebPage(onScreenShotCaptured);
                                        }
                                      });
                                      */

                                      ///
                                      ///
                                      /*
                                      _screenshotController
                                          .captureFromLongWidget(
                                        InheritedTheme.captureAll(
                                          context,
                                          Material(child: myLongWidget),
                                        ),
                                        delay: Duration(milliseconds: 100),
                                        context: context,
                                        /// Additionally you can define constraint for your image.
                                        ///
                                        /// constraints: BoxConstraints(
                                        ///   maxHeight: 1000,
                                        ///   maxWidth: 1000,
                                        /// )
                                      )
                                          .then((capturedImage) {
                                        // Handle captured image
                                      });
                                      */
                                    } else {
                                      // open search printer ui
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ConnectUi(),
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

  // Future<File> getFileFromUrl(String url, {name}) async {
  void getFileFromUrl(String url, {name}) async {
    /*
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
    */

    ///////////
    ///// The URL of the PDF you want to download.
    final pdfUrl =
        'https://pspdfkit.com/downloads/pspdfkit-flutter-quickstart-guide.pdf';

    // Fetch the PDF from the URL.
    final pdfResponse = await http.get(Uri(path: pdfUrl));

    // Check the response status code. If it's not `200` (OK), throw an error.
    if (pdfResponse.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    Directory tempDir = await getTemporaryDirectory();
    final dirExists = await tempDir.exists();

    if (!dirExists) {
      await tempDir.create();
    }

    String tempPath = tempDir.path;

    // Create a file to store the PDF.
    final pdfFile = File('$tempPath/my-pdf.pdf');

    // Write the PDF data to the file.
    await pdfFile.writeAsBytes(pdfResponse.bodyBytes);

    // Use the PSPDFKit `PdfViewer` to display the PDF document.
    // final pdfDocument = await Pspdfkit.present(pdfFile.path);
  }

  Column scrollingWebPage() {
    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: _webViewKey,
            child: InAppWebView(
              webViewEnvironment: webViewEnvironment,
              initialUrlRequest: URLRequest(url: WebUri(urlToOpen)),
              // initialUrlRequest:
              // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
              // initialFile: "assets/index.html",
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialSettings: settings,
              // contextMenu: contextMenu,
              // pullToRefreshController: pullToRefreshController,
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
              shouldOverrideUrlLoading: (controller, navigationAction) async {
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
                // pullToRefreshController?.endRefreshing();
                setState(() {
                  _isPageLoading = false;
                });
              },
              onReceivedError: (controller, request, error) {
                // pullToRefreshController?.endRefreshing();
              },
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
      ],
    );
  }
}
