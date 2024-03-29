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
        return macos;
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
    apiKey: 'AIzaSyDe8DrK3ZBm_myaMJg8rCnaX4FpTmtwyeE',
    appId: '1:375915765659:web:2babe66f98c19988808b3e',
    messagingSenderId: '375915765659',
    projectId: 'tripsitter-coen-174',
    authDomain: 'tripsitter-coen-174.firebaseapp.com',
    storageBucket: 'tripsitter-coen-174.appspot.com',
    measurementId: 'G-LNZY2EQHPZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfmu5f14Am3rj6LDZHqo8Gwp1DBHaQJNs',
    appId: '1:375915765659:android:431633d12f56afec808b3e',
    messagingSenderId: '375915765659',
    projectId: 'tripsitter-coen-174',
    storageBucket: 'tripsitter-coen-174.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRLmSKbfseSLpx5OV9ZfKAnG4svmCprCM',
    appId: '1:375915765659:ios:7fe482fe6dac84ff808b3e',
    messagingSenderId: '375915765659',
    projectId: 'tripsitter-coen-174',
    storageBucket: 'tripsitter-coen-174.appspot.com',
    iosBundleId: 'com.example.tripsitter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDRLmSKbfseSLpx5OV9ZfKAnG4svmCprCM',
    appId: '1:375915765659:ios:73cbec908f76e005808b3e',
    messagingSenderId: '375915765659',
    projectId: 'tripsitter-coen-174',
    storageBucket: 'tripsitter-coen-174.appspot.com',
    iosBundleId: 'com.example.tripsitter.RunnerTests',
  );
}
