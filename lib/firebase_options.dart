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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions không được cấu hình cho macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions không được cấu hình cho Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions không được cấu hình cho Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions không được cấu hình cho platform này: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAZnz0EufqulUtS8xymp_R1MkxhJMN-M8k',
    appId: '1:188202407059:web:059fa2f6992ace7d71cdef',
    messagingSenderId: '188202407059',
    projectId: 'studentattendance-30894',
    authDomain: 'studentattendance-30894.firebaseapp.com',
    storageBucket: 'studentattendance-30894.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZnz0EufqulUtS8xymp_R1MkxhJMN-M8k',
    appId: '1:188202407059:android:7d38502fd9157171cdef',
    messagingSenderId: '188202407059',
    projectId: 'studentattendance-30894',
    storageBucket: 'studentattendance-30894.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZnz0EufqulUtS8xymp_R1MkxhJMN-M8k',
    appId: '1:188202407059:ios:8c9e5d3f1a2b3c4d71cdef',
    messagingSenderId: '188202407059',
    projectId: 'studentattendance-30894',
    storageBucket: 'studentattendance-30894.appspot.com',
    iosBundleId: 'com.example.studentmanagement_week',
  );
}
