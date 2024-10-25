// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis/drive/v3.dart' hide User;
import 'package:printer_app/utils/colors.dart';
import '../database/app_database.dart';
import '../utils/google_http_client.dart';

class PrintGoogleDrivePageWidget extends StatefulWidget {
  // whats the usage of 'final' before data_type
  final String buttonText;

  const PrintGoogleDrivePageWidget.withGoogleDrive(
      {super.key, required this.buttonText});

  @override
  State<PrintGoogleDrivePageWidget> createState() => _PrintPhotoWidgetState();
}

class _PrintPhotoWidgetState extends State<PrintGoogleDrivePageWidget> {
  //
  bool isPrinterConnected = false;
  AppDatabase noteDatabase = AppDatabase.instance;
  // google signin
  DriveApi? driveApi;
  final storage = FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  late GoogleSignInAccount googleSignInAccount;
  ga.FileList? list;
  var signedIn = false;

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

  Future<void> _setDrive() async {
    final googleAuthData = await GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/drive',
      ],
    ).signIn();

    if (googleAuthData == null) {
      return;
    }

    final client = GoogleHttpClient(await googleAuthData.authHeaders);
    driveApi = DriveApi(client);
  }

  Future<void> _loginWithGoogle() async {
    signedIn = await storage.read(key: "signedIn") == "true" ? true : false;
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? googleSignInAccount) async {
      if (googleSignInAccount != null) {
        _afterGoogleLogin(googleSignInAccount);
      }
    });
    if (signedIn) {
      try {
        googleSignIn.signInSilently().whenComplete(() => () {});
      } catch (e) {
        storage.write(key: "signedIn", value: "false").then((value) {
          setState(() {
            signedIn = false;
          });
        });
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      _afterGoogleLogin(googleSignInAccount!);
    }
  }

  Future<void> _afterGoogleLogin(GoogleSignInAccount gSA) async {
    googleSignInAccount = gSA;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    // final User user = authResult.user!;
    final User user = FirebaseAuth.instance.currentUser!;
    ;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser!;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    storage.write(key: "signedIn", value: "true").then((value) {
      setState(() {
        signedIn = true;
      });
    });
  }

  void _logoutFromGoogle() async {
    googleSignIn.signOut().then((value) {
      print("User Sign Out");
      storage.write(key: "signedIn", value: "false").then((value) {
        setState(() {
          signedIn = false;
        });
      });
    });
  }

// _uploadFileToGoogleDrive() async {
//   var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
//   var drive = ga.DriveApi(client);
//   ga.File fileToUpload = ga.File();
//   // var file = await FilePicker.getFile();
//   // var file = await filepicker.FilePicker.platform.getDirectoryPath();
//   var file = await FilePicker.platform.pickFiles();
//   fileToUpload.parents = ["appDataFolder"];
//   fileToUpload.name = path.basename(file.absolute.path);
//   var response = await drive.files.create(
//     fileToUpload,
//     uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
//   );
//   print(response);
//   _listGoogleDriveFiles();
// }

  Future<void> _listGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list(spaces: 'appDataFolder').then((value) {
      // setState(() {
      list = value;
      // });
      for (var i = 0; i < list!.files!.length; i++) {
        print("Id: ${list!.files![i].id} File Name:${list!.files![i].name}");
      }
    });
  }

// Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
//   var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
//   var drive = ga.DriveApi(client);
//   ga.Media file = await drive.files
//       .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
//   print(file.stream);

//   final directory = await getExternalStorageDirectory();
//   print(directory.path);
//   final saveFile = File(
//       '${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
//   List<int> dataStore = [];
//   file.stream.listen((data) {
//     print("DataReceived: ${data.length}");
//     dataStore.insertAll(dataStore.length, data);
//   }, onDone: () {
//     print("Task Done");
//     saveFile.writeAsBytes(dataStore);
//     print("File saved at ${saveFile.path}");
//   }, onError: (error) {
//     print("Some Error");
//   });
// }

// List<Widget> generateFilesWidget() {
//   List<Widget> listItem = List<Widget>();
//   if (list != null) {
//     for (var i = 0; i < list.files.length; i++) {
//       listItem.add(Row(
//         children: <Widget>[
//           Container(
//             width: MediaQuery.of(context).size.width * 0.05,
//             child: Text('${i + 1}'),
//           ),
//           Expanded(
//             child: Text(list.files[i].name),
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.3,
//             child: FlatButton(
//               child: Text(
//                 'Download',
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//               color: Colors.indigo,
//               onPressed: () {
//                 _downloadGoogleDriveFile(list.files[i].name, list.files[i].id);
//               },
//             ),
//           ),
//         ],
//       ));
//     }
//   }
//   return listItem;
// }

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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      (signedIn
                          ? TextButton(
                              style: TextButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              onPressed: () {
                                //write onPressed function here
                                print('Button Pressed');
                              },
                              child: Text('Upload File to Google Drive'),
                            )
                          : Container()),
                      (signedIn
                          ? TextButton(
                              style: TextButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              onPressed: () {
                                //write onPressed function here
                                print('Button Pressed');
                              },
                              child: Text('List Google Drive Files'),
                            )
                          : Container()),
                      (signedIn
                          ? Expanded(
                              flex: 10,
                              child: Column(
                                  // children: generateFilesWidget(),
                                  ),
                            )
                          : Container()),
                      (signedIn
                          ? TextButton(
                              style: TextButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              onPressed: () {
                                // _logoutFromGoogle
                                //write onPressed function here
                                print('Button Pressed');
                              },
                              child: Text('Google Logout'),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              onPressed: () {
                                _loginWithGoogle();
                                //write onPressed function here
                                print('Button Pressed');
                              },
                              child: Text('Google Login'),
                            )),
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
}
