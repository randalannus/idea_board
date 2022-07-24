// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQaE7slDePVSkl18W-cPapAlFQL9Pl1rk',
    appId: '1:1023311527913:web:a24fdf648337ec7dce9578',
    messagingSenderId: '1023311527913',
    projectId: 'mind-boxes',
    authDomain: 'mind-boxes.firebaseapp.com',
    storageBucket: 'mind-boxes.appspot.com',
    measurementId: 'G-8TJ143W2XE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAW3LY3Szy_NamYky0eEzFxGRLDO9bMfQE',
    appId: '1:1023311527913:android:969e1c321ed51fecce9578',
    messagingSenderId: '1023311527913',
    projectId: 'mind-boxes',
    storageBucket: 'mind-boxes.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgEmfWG1ZduCsPesS2JKfsGYQMcPVvXAI',
    appId: '1:1023311527913:ios:e00c6355fb3bdc9fce9578',
    messagingSenderId: '1023311527913',
    projectId: 'mind-boxes',
    storageBucket: 'mind-boxes.appspot.com',
    iosClientId: '1023311527913-uvea9icoqei3lia0514ut4iog1n377ph.apps.googleusercontent.com',
    iosBundleId: 'com.example.ideaBoard',
  );
}
