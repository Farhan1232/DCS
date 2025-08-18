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
    apiKey: "AIzaSyC8rmCrnx1RznyhgIROqHBkZ1u0TNw0GCI",
    appId: "1:81248571391:web:41cb880a150ece2ddaa1ca",
    messagingSenderId: "81248571391",
    projectId: "verification-ae9dd",
    authDomain: "verification-ae9dd.firebaseapp.com",
    storageBucket: "verification-ae9dd.firebasestorage.app",
    measurementId: "G-79K0TW565P",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDZiW00yRhjIENzEUXN8KPmc9w-_-Rakgw",
    appId: "81248571391",
    messagingSenderId: "1:81248571391:android:cc0fc55a38f08f74daa1ca",
    projectId: "verification-ae9dd",
    storageBucket: "verification-ae9dd.firebasestorage.app",
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
