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

## macOS release setup

This app also includes base macOS project changes for desktop builds:

- macOS bundle identifier: `com.laboursampark.app.macos`
- macOS app name: `Labour Sampark`
- macOS app icon asset catalog is wired in the Runner target

Manual steps still required before a macOS build will fully work:

1. Open `macos/Runner.xcworkspace` in Xcode.
2. Set the Team for the Runner target to your Apple Developer team.
3. Confirm the macOS bundle identifier is `com.laboursampark.app.macos`.
4. Build with `flutter build macos --release` or archive from Xcode after signing is configured.

## Platform summary

- iPhone/iPad: use the iOS Runner target and the bundle ID `com.laboursampark.app`.
- macOS: use the macOS Runner target and the bundle ID `com.laboursampark.app.macos`.
- Both targets share the same Flutter codebase, settings screen, and metadata approach.

See also: [docs/platform_release_checklist.md](docs/platform_release_checklist.md) for the full release checklist.

## iOS App Store fields

The following app-facing support items are now exposed in the app under Settings > App Support and are controlled from `lib/core/app_metadata.dart`:

- App name
- Privacy Policy URL
- Support URL
- Support email
- Support phone
- App Store category reference
- App Store age rating reference
- App Store keywords reference

Items that still must be entered in App Store Connect:

- Screenshots for iPhone and iPad if you support iPad
- App description
- Keywords
- Category
- Age rating questionnaire
- Contact details
- Privacy policy URL
- Support URL

Recommended next step: replace the empty values in `lib/core/app_metadata.dart` with your official support and privacy links before submission.
