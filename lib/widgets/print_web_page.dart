// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../connect_ui.dart';
import '../database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;
//

import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PrintWebPageWidget extends StatefulWidget {
  // const PrintWebPageWidget(
  //     {super.key, required this.title, required this.mediaFileList});

  // final String title;
  // final List<XFile> mediaFileList;

  // whats the usage of 'final' before data_type
  final String buttonText;
  // final List<XFile>? mediaFileList;
  final String? pdfFilePath;

  // Named constructor for photoList
  const PrintWebPageWidget.withWebPage({super.key, required this.buttonText})
      : pdfFilePath = null;

  // Named constructor for pdfFilePath
  const PrintWebPageWidget.withPdf({
    super.key,
    required this.buttonText,
    required this.pdfFilePath,
    // }) : mediaFileList = null;
  });

  @override
  State<PrintWebPageWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintWebPageWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  bool isEditClicked = false;
  String editTitle = "Edit";

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

  final Uri _url = Uri.parse('https://flutter.dev');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _printPdf() async {
    try {
      final doc = pw.Document();

      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text('Hello Jimmy'),
            );
          }));

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      print(e);
    }
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

  @override
  void initState() {
    super.initState();
    checkPrinterInDB();
  }

/*
Future<void> _cropImage() async {
    // if (_pickedFile != null) {
    if (widget.mediaFileList.isNotEmpty) {
      final croppedFile = await ImageCropper().cropImage(
        // sourcePath: _pickedFile!.path,
        sourcePath: widget.mediaFileList[0].path,
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

*/

  /*
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
    } else if (widget.mediaFileList.isNotEmpty) {
      final path = widget.mediaFileList[0].path;
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

  */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // app bar
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
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
                                // fontWeight: FontWeight.w900,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // preview
                Stack(
                  children: [
                    SizedBox(
                      height: 600,
                      child: Center(child: WebViewScreenshotExample()),
                    ),
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
                                onTap: () {
                                  print(
                                      "isPrinterConnected : $isPrinterConnected");
                                  if (isPrinterConnected) {
                                    // print photo...
                                    // _capturePng(context);
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
                                        margin:
                                            EdgeInsets.only(right: 8, left: 0),
                                        child: Image.asset(
                                          'icons/icon_print_outline.png',
                                          height: 30,
                                          width: 30,
                                          color: Colors.white,
                                        )),
                                    Ink(
                                      child: Text(
                                        "Print Image",
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

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

const String kLocalExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
  This is an example page used to demonstrate how to load a local file or HTML
  string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
  webview</a> plugin.
</p>

</body>
</html>
''';

const String kTransparentBackgroundPage = '''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Transparent background test</title>
  </head>
  <style type="text/css">
    body { background: transparent; margin: 0; padding: 0; }
    #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
    #shape { background: red; width: 200px; height: 200px; margin: 0; padding: 0; position: absolute; top: calc(50% - 100px); left: calc(50% - 100px); }
    p { text-align: center; }
  </style>
  <body>
    <div id="container">
      <p>Transparent background test</p>
      <div id="shape"></div>
    </div>
  </body>
  </html>
''';

const String kLogExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body onload="console.log('Logging that the page is loading.')">

<h1>Local demo page</h1>
<p>
  This page is used to test the forwarding of console logs to Dart.
</p>

<style>
    .btn-group button {
      padding: 24px; 24px;
      display: block;
      width: 25%;
      margin: 5px 0px 0px 0px;
    }
</style>

<div class="btn-group">
    <button onclick="console.error('This is an error message.')">Error</button>
    <button onclick="console.warn('This is a warning message.')">Warning</button>
    <button onclick="console.info('This is a info message.')">Info</button>
    <button onclick="console.debug('This is a debug message.')">Debug</button>
    <button onclick="console.log('This is a log message.')">Log</button>
</div>

</body>
</html>
''';

class WebViewScreenshotExample extends StatefulWidget {
  @override
  _WebViewScreenshotExampleState createState() =>
      _WebViewScreenshotExampleState();
}

class _WebViewScreenshotExampleState extends State<WebViewScreenshotExample> {
  //
  late WebViewController _webViewController;
  final ScreenshotController _screenshotController = ScreenshotController();
  //
  late final WebViewController _controller;

  String? webPagePhoto;

  @override
  void initState() {
    super.initState();

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
            openDialog(request);
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
      ..loadRequest(Uri.parse('https://google.com'));
    // ..loadRequest(Uri.parse('https://flutter.dev'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (webPagePhoto != null)
              SizedBox(
                  height: 50,
                  child: Image.file(
                    File(webPagePhoto!),
                  )),
            Screenshot(
              controller: _screenshotController,
              child: SingleChildScrollView(
                  child: SizedBox(
                height: 1000,
                child: WebViewWidget(
                  // key: Key("webview1"),
                  controller: _controller,
                ),
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: favoriteButton(),
      // appBar: AppBar(
      //   title: Text('WebView Screenshot Example'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.camera),
      //       onPressed: () async {
      //         // Capture screenshot
      //         final image = await _screenshotController.capture();
      //         if (image != null) {
      //           // Save image to a file or display it
      //           final directory = await Directory.systemTemp.createTemp();
      //           final filePath = '${directory.path}/screenshot.png';
      //           final file = File(filePath);
      //           await file.writeAsBytes(image);
      //           print('Screenshot saved to $filePath');
      //         }
      //       },
      //     ),
      //   ],
      // ),
      // // body: Screenshot(
      //   controller: _screenshotController,
      //   child: WebView(
      //     initialUrl:
      //         'https://www.example.com', // Replace with your desired URL
      //     javascriptMode: JavascriptMode.unrestricted,
      //     onWebViewCreated: (WebViewController webViewController) {
      //       _webViewController = webViewController;
      //     },
      //   ),
      // ),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        final image = await _screenshotController.capture();
        if (image != null) {
          // Save image to a file or display it
          final directory = await Directory.systemTemp.createTemp();
          final filePath = '${directory.path}/screenshot.png';
          final file = File(filePath);
          await file.writeAsBytes(image);
          print('Screenshot saved to $filePath');
          setState(() {
            webPagePhoto = filePath;
          });
        }

        // final String? url = await _controller.currentUrl();
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Favorited $url')),
        //   );
        // }
      },
      child: const Icon(Icons.favorite),
    );
  }

  Future<void> openDialog(HttpAuthRequest httpRequest) async {
    final TextEditingController usernameTextController =
        TextEditingController();
    final TextEditingController passwordTextController =
        TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${httpRequest.host}: ${httpRequest.realm ?? '-'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  autofocus: true,
                  controller: usernameTextController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  controller: passwordTextController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Explicitly cancel the request on iOS as the OS does not emit new
            // requests when a previous request is pending.
            TextButton(
              onPressed: () {
                httpRequest.onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                httpRequest.onProceed(
                  WebViewCredential(
                    user: usernameTextController.text,
                    password: passwordTextController.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Authenticate'),
            ),
          ],
        );
      },
    );
  }
}
