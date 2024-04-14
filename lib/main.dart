import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/service/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:idea_board/ui/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

String fbHost = const String.fromEnvironment("FIREBASE_EMULATOR_HOST");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode && fbHost.isNotEmpty) {
    AuthService.useEmulator(fbHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(fbHost, 8080);
  }
  // Force device orientation to vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const IdeaBoardApp());
}
