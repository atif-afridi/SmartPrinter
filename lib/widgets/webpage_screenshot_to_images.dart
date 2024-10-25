import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screenshot/screenshot.dart';

class WebpageScreenshotDisplay extends StatefulWidget {
  @override
  _WebpageScreenshotDisplayState createState() =>
      _WebpageScreenshotDisplayState();
}

class _WebpageScreenshotDisplayState extends State<WebpageScreenshotDisplay> {
  late InAppWebViewController webViewController;
  ScreenshotController screenshotController = ScreenshotController();
  List<Uint8List> screenshots = [];
  double screenshotHeight = 600; // Adjust this height as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Webpage Screenshot Display"),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () {
              if (screenshots.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ScreenshotListView(screenshots: screenshots)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No screenshots captured yet!")),
                );
              }
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://www.google.com"),
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            print("Webpage loaded: $url");
            await captureScreenshots();
          },
        ),
      ),
    );
  }

  Future<void> captureScreenshots() async {
    double contentHeight =
        (await webViewController.getContentHeight())?.toDouble() ??
            screenshotHeight;
    int numberOfScreenshots = (contentHeight / screenshotHeight).ceil();

    for (int i = 0; i < numberOfScreenshots; i++) {
      double scrollPosition = i * screenshotHeight;
      await webViewController.scrollTo(x: 0, y: scrollPosition.toInt());
      await Future.delayed(Duration(seconds: 3)); // Increased wait time

      Uint8List? screenshot = await screenshotController.capture();
      if (screenshot != null) {
        print("Screenshot captured: ${screenshot.lengthInBytes} bytes");
        screenshots.add(screenshot);
      } else {
        print("Failed to capture screenshot at position: $scrollPosition");
      }
    }

    setState(() {}); // Refresh the UI to reflect captured screenshots
    print("Total screenshots captured: ${screenshots.length}");
  }
}

class ScreenshotListView extends StatelessWidget {
  final List<Uint8List> screenshots;

  ScreenshotListView({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screenshots Preview"),
      ),
      body: ListView.builder(
        itemCount: screenshots.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(
              screenshots[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
