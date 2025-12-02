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
  apiKey: "AIzaSyARBT8ENh1UsFL9RL4SaNQAknsCjn5-drQ",
  authDomain: "inventorysystem-4d9d4.firebaseapp.com",
  projectId: "inventorysystem-4d9d4",
  storageBucket: "inventorysystem-4d9d4.firebasestorage.app",
  messagingSenderId: "66994658980",
  appId: "1:66994658980:web:9a2f2097422b91f0855031",
  measurementId: "G-S4CZ9LLHQS"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAPyc6SKTYOiOrlA7FbVKlf0yrc9rgwSH8",
    appId: "66994658980",
    messagingSenderId: "1:66994658980:android:fe762e9ec7a271b5855031",
    projectId: "inventorysystem-4d9d4",
    storageBucket: "inventorysystem-4d9d4.firebasestorage.app",
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
