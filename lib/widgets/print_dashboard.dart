import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printer_app/database/printer_model.dart';
import 'package:printer_app/widgets/multiple_formats/image_notes.dart';
import 'package:printer_app/widgets/print_clipboard.dart';
import 'package:printer_app/widgets/print_frames_photo_patch.dart';
import 'package:printer_app/widgets/print_google_drive.dart';
import 'package:printer_app/widgets/print_photo.dart';
import 'package:printer_app/widgets/print_web_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../connect_ui.dart';
import '../database/app_database.dart';
import '../models/print_menu_pojo.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';
import 'multiple_formats/image_splitter.dart';
import 'print_create_quizzes.dart';
import 'print_help_center.dart';
import 'print_multiple_photos.dart';
import 'print_notes.dart';
import 'print_quizzes.dart';
import 'webpage_screenshot_to_images.dart';

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);

class PrintDashboardWidget extends StatefulWidget {
  ////
  final String title;
  // late Future<List<PrintModel>> connectedPrinterList;

  const PrintDashboardWidget({super.key, required this.title});

  @override
  State<PrintDashboardWidget> createState() => _PrintDashboardWidgetState();
}

class _PrintDashboardWidgetState extends State<PrintDashboardWidget> {
  //
  AppDatabase noteDatabase = AppDatabase.instance;

  late Future<List<PrintModel>> connectedPrinterList;

  List<PrintItem> printDashboardMenuList = [
    PrintItem(
        title: Strings.printPhoto,
        startColor: const Color(0xFF947fe9),
        endColor: const Color(0xFFc4d0ff),
        iconName: "icons/print_photo.png"),
    PrintItem(
        title: Strings.printDocument,
        startColor: const Color(0xFFca47eb),
        endColor: const Color(0xFFf19fff),
        iconName: "icons/print_document.png"),
    PrintItem(
        title: Strings.printWebPage,
        startColor: const Color(0xFFff9178),
        endColor: const Color(0xFFffd6c9),
        iconName: "icons/print_web_page.png"),
    PrintItem(
        title: Strings.printOneDrive,
        startColor: const Color(0xFF01ded1),
        endColor: const Color(0xFF85fff8),
        iconName: "icons/print_one_drive.png"),
    PrintItem(
        title: Strings.printFormats,
        startColor: const Color(0xFFeba902),
        endColor: const Color(0xFFffd467),
        iconName: "icons/print_formats.png"),
    PrintItem(
        title: Strings.printLabels,
        startColor: const Color(0xFF47c744),
        endColor: const Color(0xFF73ff6f),
        iconName: "icons/print_labels.png"),
    PrintItem(
        title: Strings.printEmails,
        startColor: const Color(0xFF967fe9),
        endColor: const Color(0xFFc3d1ff),
        iconName: "icons/print_email.png"),
    PrintItem(
        title: Strings.printNotes,
        startColor: const Color(0xFFca47eb),
        endColor: const Color(0xFFf2a0ff),
        iconName: "icons/print_notes.png"),
    PrintItem(
        title: Strings.printQuizzes,
        startColor: const Color(0xFFff9178),
        endColor: const Color(0xFFffd6c9),
        iconName: "icons/print_quizzes.png"),
    PrintItem(
        title: Strings.printClipboard,
        startColor: const Color(0xFF01ded1),
        endColor: const Color(0xFF85fff8),
        iconName: "icons/print_clipboard.png"),
    PrintItem(
        title: Strings.printCalendar,
        startColor: const Color(0xFFeba902),
        endColor: const Color(0xFFffd467),
        iconName: "icons/print_calendar.png"),
    PrintItem(
        title: Strings.printHelpCenter,
        startColor: const Color(0xFF47c744),
        endColor: const Color(0xFF73ff6f),
        iconName: "icons/print_help_center.png"),
  ];

  Widget bigCircle = Positioned(
    // top: -10.0,
    top: -180.0,
    left: -110.0,
    // RotatedBox
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
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(200),
        //   bottomRight: Radius.circular(200),
        //   // Radius.circular(270),
        // ),
        // border: Border.all(
        //     width: 3, color: Colors.green, style: BorderStyle.none),
      ),
    ),
  );

  Widget twoCircles = Positioned(
    top: 150.0,
    right: -20.0,
    child: Container(
      width: 150.0,
      height: 150.0,
      // color: Color(0xFFf8ffff),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFFcbecf1),
          width: 15.0,
        ),
        // borderRadius: BorderRadius.all(Radius.circular(50.0)),
      ),
    ),
  );

  List<XFile>? _mediaFileList;
  String connectButtonText = '';
  String connectTitleText = '';
  bool isPrinterConnected = false;

  Future<void>? _launched;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
    navigateToPhotoEditing(_mediaFileList!);
  }

  void navigateToPhotoEditing(List<XFile> mediaFileList) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrintPhotoWidget.withPhotos(
                  title: "Photo",
                  mediaFileList: mediaFileList,
                )));
  }

  void navigateToPdfEditing(String pdfFilePath) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrintPhotoWidget.withPdf(
                  title: "Pdf",
                  pdfFilePath: pdfFilePath,
                )));
  }

  void navigateToWebView(String buttonText, String urlToOpen) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrintWebPageWidget.withWebView(
                  buttonText: buttonText,
                  urlToOpen: urlToOpen,
                )));
  }

  void navigateGoogleDrive(String buttonText, String urlToOpen) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrintGoogleDrivePageWidget.withGoogleDrive(
                buttonText: buttonText)));
  }

  void navigateToWebPage(String buttonText) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrintWebPageWidget.withWebPage(
                  buttonText: buttonText,
                )));
  }

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  Future<void> _pickPhoto(
      BuildContext context, OnPickImageCallback onPick) async {
    final double? width = maxWidthController.text.isNotEmpty
        ? double.parse(maxWidthController.text)
        : null;
    final double? height = maxHeightController.text.isNotEmpty
        ? double.parse(maxHeightController.text)
        : null;
    final int? quality = qualityController.text.isNotEmpty
        ? int.parse(qualityController.text)
        : null;
    final int? limit = limitController.text.isNotEmpty
        ? int.parse(limitController.text)
        : null;
    onPick(width, height, quality, limit);
  }

  Future<void> _onPickImage(ImageSource source, BuildContext context) async {
    await _pickPhoto(context,
        (double? maxWidth, double? maxHeight, int? quality, int? limit) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _setImageFileListFromFile(pickedFile);
        });
      } catch (e) {
        setState(() {
          // TODO log to output
          // _pickImageError = e;
        });
      }
    });
  }

  Future<List<PrintModel>>? alwaysLate() {
    // connectedPrinterList = noteDatabase.readAll();
    return noteDatabase.readAll();
    // return connectedPrinterList;
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  void _openPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // allowedExtensions: ['jpg', 'pdf', 'doc'],
      allowedExtensions: <String>['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      navigateToPdfEditing(file.path);
      // it opens in new activity
      // OpenFilex.open(file.path);
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // _validateUserInput();
    // alwaysLate();
    super.initState();
  }

  @override
  dispose() {
    //close the database
    // noteDatabase.close();
    super.dispose();
  }

  ///Gets all the notes from the database and updates the state
  refreshNotes() {
    noteDatabase.readAll().then((printerList) {
      setState(() {
        // widget.connectedPrinterList = value;
        if (printerList.isEmpty) {
          isPrinterConnected = true;
        } else {
          isPrinterConnected = false;
        }
      });
    });
  }

  ///Deletes the note from the database and navigates back to the previous screen
  deleteNote() {
    noteDatabase.deleteAll();
    setState(() {});
    // alwaysLate();
  }

  @override
  Widget build(BuildContext context) {
// onPressed calls using this URL are not gated on a 'canLaunch' check
    // because the assumption is that every device can launch a web URL.
    final Uri toLaunch =
        Uri(scheme: 'https', host: 'www.google.com', path: 'headers/');

    return Stack(children: [
      bigCircle,
      twoCircles,
      Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Title
                widget.title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    // fontWeight: FontWeight.w900,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
              Container(
                // No printer connected.
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xFFFFFFFF),
                          spreadRadius: 1,
                          blurRadius: 1 //edited
                          )
                    ],
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColor.skyBlue,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: FutureBuilder(
                      // future: refreshNotes(),
                      future: alwaysLate(),
                      builder: (context, snapshot) {
                        print("DATABASE RESPONSE ${snapshot.data}");
                        // checks data handling...
                        if (!snapshot.hasData) {
                          isPrinterConnected = false;
                          return printerConnectDisconnect(
                              context, "No printer connected", "Connect");
                        }
                        if (snapshot.hasData) {
                          // validate the response
                          var printerListDB = snapshot.data;
                          if (printerListDB != null &&
                              printerListDB.isNotEmpty) {
                            isPrinterConnected = true;
                            return printerConnectDisconnect(
                                context, "Printer connected", "Disconnect");
                          } else {
                            isPrinterConnected = false;
                            return printerConnectDisconnect(
                                context, "No printer connected", "Connect");
                          }
                        }

                        isPrinterConnected = false;
                        return CircularProgressIndicator();
                      }),
                ),
              ),
              Container(
                  // What to Print
                  margin: const EdgeInsets.only(top: 40),
                  child: const Text(
                    "What to Print",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 16,
                      // fontWeight: FontWeight.w600,
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
                    childAspectRatio: (1 / .7),
                    // childAspectRatio: (itemWidth / itemHeight),
                  ),
                  itemCount: printDashboardMenuList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => {
                        setState(() {
                          switch (index) {
                            case 0: // print photo
                              _onPickImage(ImageSource.gallery, context);
                              break;
                            case 1: // print document
                              /*
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NotesView()),
                              );
                            */
                              _openPdf();
                              break;
                            case 2: // print Web page
                              // navigateToWebPage("Web Page");

                              /** Render Web Page **/
                              /**/
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WebpageScreenshotDisplay()),
                              );

                              /** Render Web Page **/
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           const RenderWebPageWidget.withWebPage(
                              //             buttonText: "Render",
                              //           )),
                              // ).then((value) {
                              //   // alwaysLate();
                              //   setState(() {});
                              // });

                              /*
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TestDataBaseWidget()),
                              ).then((value) {
                                // alwaysLate();
                                setState(() {});
                              });
                            */
                              break;
                            case 3: // print Google Drive
                              navigateGoogleDrive(
                                  "Web Page", "www.googledrive.com");
                              break;
                            case 4: // print Formats menu
                              showFormatsBottomSheet(context);
                              break;
                            case 5: // print labels
                              // showFormatsBottomSheet(context);
                              break;
                            case 6: // print emails

                              break;
                            case 7: // print notes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // builder: (context) => const PrintNotes()),
                                    builder: (context) => PrinterNotes()),
                              ).then((value) {
                                // alwaysLate();
                                setState(() {});
                              });
                              break;
                            case 8: // print quizzes
                              //
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QuizCreationWidget()),
                              ).then((value) {
                                // alwaysLate();
                                setState(() {});
                              });
                              break;
                            case 9: // print clip_board
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PrintClipboardWidget()),
                              ).then((value) {
                                // alwaysLate();
                                setState(() {});
                              });
                              break;
                            case 10: // print calendar

                              break;
                            case 11: // print help_center
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PrintHelpCenter()),
                              ).then((value) {
                                // alwaysLate();
                                setState(() {});
                              });

                              break;
                          }
                        })
                      },
                      child: Container(
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
                              printDashboardMenuList[index].startColor,
                              printDashboardMenuList[index].endColor,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              // width: 80,
                              child: Text(
                                printDashboardMenuList[index].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.asset(
                                    printDashboardMenuList[index].iconName))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  void showFormatsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(20),
          // height: 200,
          // color: Colors.amber,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Multiple Photos on Same page
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PrintMultiplePhotosWidget.withMultiplePhotos(
                                    buttonText: "multiple")),
                      )
                          // ConvertToPdfPage())
                          .then((value) {
                        // alwaysLate();
                        setState(() {});
                      });
                      // Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: SvgPicture.asset("icons/multiple_photo.svg",
                              // colorFilter:
                              //     ColorFilter.mode(Colors.red, BlendMode.srcIn),
                              semanticsLabel: 'A red up arrow'),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            child: const Text('Multiple Photos on Same page')),
                      ],
                    ),
                  ),
                ),
                // Print as a Poster
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageSplitter(
                              rows: 3,
                              columns: 3,
                            ),
                          )).then((value) {
                        // alwaysLate();
                        setState(() {});
                      });
                      // Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: SvgPicture.asset("icons/print_as_poster.svg",
                              // colorFilter:
                              //     ColorFilter.mode(Colors.red, BlendMode.srcIn),
                              semanticsLabel: 'A red up arrow'),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            child: const Text('Print as a Poster')),
                      ],
                    ),
                  ),
                ),
                // Print with Frame
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                // PrintFramesPhotoWidget.withMultiplePhotos(
                                //     buttonText: "multiple")
                                DynamicNinePatchFrame(),
                          ));
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: SvgPicture.asset("icons/print_with_frame.svg",
                              // colorFilter:
                              //     ColorFilter.mode(Colors.red, BlendMode.srcIn),
                              semanticsLabel: 'A red up arrow'),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            child: const Text('Print with Frame')),
                      ],
                    ),
                  ),
                ),
                //////////////////
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                  /*
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PrintFramesWidget.withFrames(
                                              buttonText: "Frames")));
                              */
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Row printerConnectDisconnect(
      BuildContext context, String connectTitleText, String connectButtonText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          connectTitleText,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () => {
            if (isPrinterConnected)
              {deleteNote()}
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnectUi(),
                  ),
                ).then((value) {
                  // alwaysLate();
                  setState(() {});
                })
              }
          },
          child: Container(
            height: 20,
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Text(
              connectButtonText,
              style: TextStyle(
                color: AppColor.skyBlueText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      ],
    );
  }
}
