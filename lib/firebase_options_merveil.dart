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
      apiKey: "AIzaSyCrHpnPK69vpn0RhY5mEPh2mHxwbSEQ61E",
      authDomain: "presenceapp-bj.firebaseapp.com",
      projectId: "presenceapp-bj",
      storageBucket: "presenceapp-bj.appspot.com",
      messagingSenderId: "213819952157",
      appId: "1:213819952157:web:7bf2f256095c7963d80af4",
      measurementId: "G-SN5Z7SEBD3"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAs3Y-miH0mGDGS6yuBREexw9I2o2yb6bc",
    projectId: "presenceapp-bj",
    storageBucket: "presenceapp-bj.appspot.com",
    messagingSenderId: "213819952157",
    appId: "1:213819952157:android:4371b202b15f2b17d80af4"
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOC5Qf2mWTWT-z40yJYEB-ARGcOZ0EdDI',
    appId: '1:213819952157:ios:b475de982480358ad80af4',
    messagingSenderId: '213819952157',
    projectId: 'presenceapp-bj',
    storageBucket: 'presenceapp-bj.appspot.com',
    iosClientId: '213819952157-oeo8v44ifncc85untldapij1b4rddsso.apps.googleusercontent.com',
    iosBundleId: 'com.example.presenceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOC5Qf2mWTWT-z40yJYEB-ARGcOZ0EdDI',
    appId: '1:213819952157:ios:85f6f15110990400d80af4',
    messagingSenderId: '213819952157',
    projectId: 'presenceapp-bj',
    storageBucket: 'presenceapp-bj.appspot.com',
    iosClientId: '213819952157-dit65fsoa8b7u37c2dfi9g1qca9lgrs5.apps.googleusercontent.com',
    iosBundleId: 'com.example.presenceApp.RunnerTests',
  );
}
