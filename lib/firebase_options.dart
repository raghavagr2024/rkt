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
    apiKey: 'AIzaSyDCTl0vEeHOZ3bj96XDwRnKwlMRPA0AH4s',
    appId: '1:408241291251:web:4daf5648aa5540d2441c86',
    messagingSenderId: '408241291251',
    projectId: 'rkt-summer',
    authDomain: 'rkt-summer.firebaseapp.com',
    storageBucket: 'rkt-summer.appspot.com',
    measurementId: 'G-H5JVJY9WLV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDraH1Fk0LEMkgVwm-CZA2h5oxwi7eCDPk',
    appId: '1:408241291251:android:9a1e4e2b7a54d8cb441c86',
    messagingSenderId: '408241291251',
    projectId: 'rkt-summer',
    storageBucket: 'rkt-summer.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6NPZE-5CImQ0aUi5r2pJF36xb4UaDI8w',
    appId: '1:408241291251:ios:1c81c97fb5a88790441c86',
    messagingSenderId: '408241291251',
    projectId: 'rkt-summer',
    storageBucket: 'rkt-summer.appspot.com',
    iosClientId: '408241291251-pqku12qh56qb2fhn82uusfoj51cnn2rq.apps.googleusercontent.com',
    iosBundleId: 'com.example.rkt',
  );
}
