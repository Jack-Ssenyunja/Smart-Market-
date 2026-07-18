// This file is a template. Replace with your actual Firebase config.
// Run: flutterfire configure
// to generate this file automatically from your Firebase project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚠️  Replace all placeholder values below with your actual Firebase config.
  // Get these from: Firebase Console → Project Settings → Your Apps

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCEa4U4wvkjKLDf_92bktgq97JoFCfAO0s',
    appId: '1:29357639197:web:f9f7d3b9f1d808d98ae8f4',
    messagingSenderId: '29357639197',
    projectId: 'smart-market-muk',
    authDomain: 'smart-market-muk.firebaseapp.com',
    storageBucket: 'smart-market-muk.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBq0vTlSWA_DLyCQLdZeTVnOStBGKwy9ZY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcars_WTG_9bxTjAoJ_IFtZslHw5-pKUE',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.smartMarket',
  );
}
