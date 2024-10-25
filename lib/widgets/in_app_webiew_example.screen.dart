import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/colors.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  Uint8List? screenshotBytes;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: Text("InAppWebView")),
        // drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
      TextField(
        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
        controller: urlController,
        keyboardType: TextInputType.text,
        onSubmitted: (value) {
          var url = WebUri(value);
          if (url.scheme.isEmpty) {
            url = WebUri((!kIsWeb
                    ? "https://www.google.com/search?q="
                    : "https://www.bing.com/search?q=") +
                value);
          }
          webViewController?.loadUrl(urlRequest: URLRequest(url: url));
        },
      ),
      Expanded(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              webViewEnvironment: webViewEnvironment,
              initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
              // initialUrlRequest:
              // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
              // initialFile: "assets/index.html",
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialSettings: settings,
              contextMenu: contextMenu,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
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

                screenshotBytes = await controller.takeScreenshot();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Column(
                        children: [
                          Expanded(child: Image.memory(screenshotBytes!)),
                        ],
                      ),
                    );
                  },
                );

                pullToRefreshController?.endRefreshing();
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onReceivedError: (controller, request, error) {
                pullToRefreshController?.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                  urlController.text = this.url;
                });
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
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
                          // print(
                          //     "isPrinterConnected : $isPrinterConnected");
                          /* MediaQuery.of(context).size.height */

                          if (true) {
                            // TODO navigate
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) =>
                            //         InAppWebViewExampleScreen()));
                            webViewController?.takeScreenshot();

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
                                              context: context,
                                              constraints: BoxConstraints(
                                                maxHeight: 1000,
                                                maxWidth: 1000,
                                              ))
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const ConnectUi(),
                            //   ),
                            // ).then((value) {
                            //   setState(() {});
                            // });
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
                                "Print web page",
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
      // ButtonBar(
      //   alignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     ElevatedButton(
      //       child: Icon(Icons.arrow_back),
      //       onPressed: () {
      //         webViewController?.goBack();
      //       },
      //     ),
      //     ElevatedButton(
      //       child: Icon(Icons.arrow_forward),
      //       onPressed: () {
      //         webViewController?.goForward();
      //       },
      //     ),
      //     ElevatedButton(
      //       child: Icon(Icons.refresh),
      //       onPressed: () {
      //         webViewController?.reload();
      //       },
      //     ),
      //   ],
      // ),
    ])));
  }
}
