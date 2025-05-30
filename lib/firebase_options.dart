// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDFqv0213RMUhOF_sgG9KYd8VyD9ZmxNj4',
    appId: '1:898393754970:web:3257642a8fc54d7fd6b763',
    messagingSenderId: '898393754970',
    projectId: 'foliox-e75a6',
    authDomain: 'foliox-e75a6.firebaseapp.com',
    storageBucket: 'foliox-e75a6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfm-HKelE7RqjhEm3ZfQzZMJBtupHc6bQ',
    appId: '1:898393754970:android:4a9183573bb8ab4dd6b763',
    messagingSenderId: '898393754970',
    projectId: 'foliox-e75a6',
    storageBucket: 'foliox-e75a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuiFjB1gFWrM3JDbeXpsba4AjBeGW0FuM',
    appId: '1:898393754970:ios:da614e2d717fd3fed6b763',
    messagingSenderId: '898393754970',
    projectId: 'foliox-e75a6',
    storageBucket: 'foliox-e75a6.firebasestorage.app',
    iosBundleId: 'com.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuiFjB1gFWrM3JDbeXpsba4AjBeGW0FuM',
    appId: '1:898393754970:ios:5db8a45d88f1f45fd6b763',
    messagingSenderId: '898393754970',
    projectId: 'foliox-e75a6',
    storageBucket: 'foliox-e75a6.firebasestorage.app',
    iosBundleId: 'com.example.myProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFqv0213RMUhOF_sgG9KYd8VyD9ZmxNj4',
    appId: '1:898393754970:web:4257da7bc293222ad6b763',
    messagingSenderId: '898393754970',
    projectId: 'foliox-e75a6',
    authDomain: 'foliox-e75a6.firebaseapp.com',
    storageBucket: 'foliox-e75a6.firebasestorage.app',
  );
}
