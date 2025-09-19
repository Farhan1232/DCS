// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the app.
/// Replace the placeholder values with the actual keys from your Firebase Console.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "YOUR_web_API_KEY",
  authDomain: "YOUR_web_API_KEY",
  projectId: "YOUR_web_API_KEY",
  storageBucket: "YOUR_web_API_KEYp",
  messagingSenderId: "YOUR_web_API_KEY",
  appId: "YOUR_web_API_KEY",
  measurementId: "YOUR_web_API_KEY"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YOUR_android_API_KEY",
    appId: "YOUR_android_API_KEY",
    messagingSenderId: "YOUR_android_API_KEY",
    projectId: "YOUR_android_API_KEY",
    storageBucket: "YOUR_android_API_KEY",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    iosClientId: "YOUR_IOS_CLIENT_ID",
    iosBundleId: "YOUR_IOS_BUNDLE_ID",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "YOUR_MACOS_API_KEY",
    appId: "YOUR_MACOS_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    iosClientId: "YOUR_MACOS_CLIENT_ID",
    iosBundleId: "YOUR_MACOS_BUNDLE_ID",
  );
}
