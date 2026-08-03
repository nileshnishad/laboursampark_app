# Labour Sampark Release Checklist

## iPhone and iPad

### App identity

- App name: Labour Sampark
- Bundle ID: com.laboursampark.app
- Apple Team ID: 63H92VU56P

### Xcode setup

- Open ios/Runner.xcworkspace in Xcode
- Select the Labour Sampark Apple Developer Team
- Confirm signing is Automatic or your chosen manual profile is attached
- Make sure GoogleService-Info.plist is present in ios/Runner/
- Verify Push Notifications capability if Firebase Messaging is used
- Verify Background Modes > Remote notifications if required

### App Store Connect

- Create the app record using the same bundle ID
- Fill app name, subtitle, description, keywords, category, and age rating
- Add support URL and privacy policy URL
- Add support email and contact phone
- Upload screenshots for supported iPhone sizes
- Add iPad screenshots if iPad support is enabled

### Build and test

- Run flutter build ios --release after signing is ready
- Test on a real iPhone before archive upload
- Archive from Xcode and upload to App Store Connect

## macOS

### App identity

- App name: Labour Sampark
- Bundle ID: com.laboursampark.app.macos
- Apple Team ID: 63H92VU56P

### Xcode setup

- Open macos/Runner.xcworkspace in Xcode
- Select the Labour Sampark Apple Developer Team
- Confirm the macOS bundle ID is com.laboursampark.app.macos
- Verify app icon asset catalog is set on the Runner target
- Confirm code signing for the Runner target

### Mac App Store / distribution

- Create or confirm a Mac app record with the macOS bundle ID
- Fill metadata in App Store Connect for Mac if you are distributing there
- Add screenshots for Mac
- Verify privacy and support links

### Build and test

- Run flutter build macos --release after signing is ready
- Test the app on a Mac before archive upload
- Archive from Xcode and upload if distributing through App Store Connect

## Shared items

- Privacy policy must explain what data is collected and why
- Support email should be monitored by a real team
- Any camera, photos, location, or notification usage text must match the app behavior
- Firebase and API endpoints must be verified on both iOS and macOS
- Run a final clean build before submission

## Recommended order

1. Finish Apple Developer signing
2. Add required Firebase iOS/macOS config files
3. Fill App Store metadata in App Store Connect
4. Test on real devices
5. Archive and submit
