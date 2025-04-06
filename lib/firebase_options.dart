import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
          'DefaultFirebaseOptions have not been configured for $defaultTargetPlatform - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKlNEaXX0-3szOfTT-Gz_IxyXwWfxyl6E',
    appId: '1:734282374704:web:a500208ff62329f69d17f5',
    messagingSenderId: '734282374704',
    projectId: 'jeevan-setu-121205',
    authDomain: 'jeevan-setu-121205.firebaseapp.com',
    storageBucket: 'jeevan-setu-121205.firebasestorage.app',
    measurementId: 'G-G92SBG9F3R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYiC1T0zfnCxyLe8-BUtTsqGJiB34CJBc',
    appId: '1:734282374704:android:71b4e9b954cc28499d17f5',
    messagingSenderId: '734282374704',
    projectId: 'jeevan-setu-121205',
    storageBucket: 'jeevan-setu-121205.firebasestorage.app',
  );
}

// Import the functions you need from the SDKs you need
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional