// Generated Firebase options — Android only
// Run `flutterfire configure` to add iOS/Web support later

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured for Firebase. '
        'Run flutterfire configure to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS platform is not configured for Firebase yet. '
          'Run flutterfire configure to add iOS support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRSU0cd__oukeSwK2JkVVrgbpvK79Dg3k',
    appId: '1:1040537688953:android:1ba04a54f2c40eb6492da8',
    messagingSenderId: '1040537688953',
    projectId: 'laboursampark-810ef',
    storageBucket: 'laboursampark-810ef.firebasestorage.app',
  );
}
