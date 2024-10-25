import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'google_http_client.dart';

import 'package:file_picker/file_picker.dart' as filepicker;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

DriveApi? driveApi;
bool signedIn = false;
late FlutterSecureStorage storage;
late GoogleSignIn googleSignIn;
final FirebaseAuth _auth = FirebaseAuth.instance;
late GoogleSignInAccount googleSignInAccount;
ga.FileList? list;

void init() {
  storage = FlutterSecureStorage();
}
