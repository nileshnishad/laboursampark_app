# iOS App Store Submission Checklist

## App-side items already implemented

- App display name is set in iOS `Info.plist`
- App icon asset catalog is wired for iOS
- iOS permission strings are present for camera, photos, location, and remote notifications
- App support entries are exposed in `Settings > App Support`
- App metadata constants live in `lib/core/app_metadata.dart`

## Configure these values in the app

Update `lib/core/app_metadata.dart` with your official values:

- `supportEmail`
- `supportPhone`
- `privacyPolicyUrl`
- `supportUrl`

## Fill these in App Store Connect

- App name
- App description
- Keywords
- Category
- Age rating questionnaire
- Contact details
- Privacy policy URL
- Support URL
- Screenshots

## Copy-ready App Store draft

### App name

Labour Sampark

### Category

Business

### Age rating

4+

### Keywords

labour, contractor, jobs, workers, hiring, recruitment, work, business, local jobs, service

### Short description

Labour Sampark connects labourers, contractors, and businesses in one simple app for job discovery, profile visibility, and hiring.

### Full description

Labour Sampark is a platform for labourers, contractors, and businesses to connect faster and work more efficiently.

Key features:

- Create and manage labour, contractor, and business profiles
- Discover jobs and opportunities based on your role and location
- Post jobs and manage applications
- Track job history and activity
- Share profile details with others quickly
- Use secure login and OTP verification
- Receive notifications and updates when needed

Labour Sampark is designed to simplify hiring and job discovery for field workers, contractors, and business owners.

### Support contact

- Support email: add your official support email
- Support phone: add your official support phone number
- Support URL: add your help or contact page
- Privacy policy URL: add your privacy policy page

## Screenshot checklist

Capture these screens before uploading to App Store Connect:

- Login screen
- OTP verification screen
- Dashboard home screen
- Jobs screen
- Labour list screen
- Contractor list screen
- Profile screen
- Settings screen with App Support section
- Create job screen
- History screen

Recommended screenshot order:

1. Login / onboarding
2. Dashboard
3. Jobs listing
4. Profile
5. Settings / Support

If you support iPad, capture the same core flows on iPad size as well.

## Screenshot requirements

Prepare these sizes if you support the corresponding devices:


## Recommended support details

Use an email that is monitored by your team and can answer review and user issues quickly.

Suggested minimum support channels:


## Notes for review


## macOS build notes

If you want the app to run on macOS as well, use the separate macOS target with bundle ID `com.laboursampark.app.macos`.

macOS-specific items to verify:

- Open `macos/Runner.xcworkspace` in Xcode
- Set the Apple Developer Team
- Confirm the bundle ID is `com.laboursampark.app.macos`
- Test the app on a Mac before release
- Archive the app with `flutter build macos --release` or Xcode archive
