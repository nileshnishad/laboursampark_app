# laboursampark_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


flutter build appbundle --release For build aap file for Plat Store

## iOS release setup

This app now includes the base iOS project changes required for App Store preparation:

- Bundle identifier: `com.laboursampark.app`
- iOS deployment target: `13.0`
- App icon asset catalog is wired in the Runner target
- Camera, photo library, location, and remote notification usage strings are declared

Manual steps still required before an App Store build will fully work:

1. Add your Apple Developer team in Xcode Signing & Capabilities for the Runner target.
2. Download the iOS `GoogleService-Info.plist` from the Firebase project and place it in `ios/Runner/`.
3. Run `flutterfire configure --platforms=ios` to regenerate `lib/firebase_options.dart` with iOS values.
4. Enable Push Notifications and Background Modes > Remote notifications in Xcode if Firebase Messaging is required on iOS.
5. Build with `flutter build ios --release` or archive from Xcode after signing is configured.
