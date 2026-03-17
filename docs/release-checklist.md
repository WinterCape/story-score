# StoryScore Release Checklist

## Version Bumping

Update `pubspec.yaml` version before every release:

```yaml
version: 1.2.0+5   # <marketing version>+<build number>
```

- **Marketing version** (`1.2.0`): Visible to users. Increment major/minor/patch per semver.
- **Build number** (`+5`): Must be strictly increasing for each store upload. Never reuse.

---

## iOS Build Checklist

### Prerequisites
- [ ] Apple Developer Program membership (active)
- [ ] Xcode installed with latest stable release
- [ ] CocoaPods installed (`gem install cocoapods`)

### Certificates & Provisioning
- [ ] Distribution certificate created in Apple Developer portal (or Xcode auto-managed)
- [ ] App ID registered: `com.yourorg.storyscore`
- [ ] Provisioning profile created (App Store distribution)
- [ ] In Xcode: Signing & Capabilities set to "Automatically manage signing" or manual profile selected

### App Store Connect Setup
- [ ] App record created in App Store Connect
- [ ] Bundle ID matches `com.yourorg.storyscore`
- [ ] App name: "StoryScore"
- [ ] Primary language set
- [ ] Category: Games > Board
- [ ] Age rating questionnaire completed
- [ ] App privacy section filled (select "Data Not Collected")
- [ ] Screenshots uploaded (see `store-materials.md` screenshot plan)
- [ ] App description, keywords, support URL, marketing URL filled

### Build & Upload
```bash
# Clean and build
flutter clean
flutter build ipa --release

# Output at build/ios/ipa/story_score.ipa
```
- [ ] Open `build/ios/ipa/` in Transporter app (or use `xcrun altool`)
- [ ] Upload IPA to App Store Connect
- [ ] Wait for processing to complete

### TestFlight
- [ ] Build appears in TestFlight tab after processing
- [ ] Add internal testers (up to 100, no review required)
- [ ] Add external testers (requires Beta App Review on first build)
- [ ] Set "What to Test" notes for testers
- [ ] Distribute build to test groups

### App Review Submission
- [ ] Select build in App Store Connect version
- [ ] Fill in "What's New" text
- [ ] Add app review notes (see `store-materials.md` template)
- [ ] Submit for review

---

## Android Build Checklist

### Prerequisites
- [ ] Google Play Developer account (active, one-time $25 fee)
- [ ] Java/Kotlin SDK installed
- [ ] Android SDK with target API level

### Signing
- [ ] Upload keystore created:
  ```bash
  keytool -genkey -v -keystore upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias upload
  ```
- [ ] `android/key.properties` configured (not checked into git):
  ```properties
  storePassword=<password>
  keyPassword=<password>
  keyAlias=upload
  storeFile=<path>/upload-keystore.jks
  ```
- [ ] `android/app/build.gradle` references `key.properties` for release signing
- [ ] Google Play App Signing enrolled (recommended -- Google manages the app signing key)

### Google Play Console Setup
- [ ] App created in Google Play Console
- [ ] Package name: `com.yourorg.storyscore`
- [ ] Store listing completed (title, descriptions, screenshots, icon)
- [ ] Content rating questionnaire completed
- [ ] Target audience and content section filled
- [ ] Data safety section completed (select "No data collected")
- [ ] App category: Game > Board

### Build & Upload
```bash
# Build app bundle (preferred over APK for Play Store)
flutter clean
flutter build appbundle --release

# Output at build/app/outputs/bundle/release/app-release.aab
```
- [ ] Upload AAB to Play Console release track

### Internal Testing Track
- [ ] Create internal testing release
- [ ] Upload AAB
- [ ] Add tester email list (up to 100)
- [ ] Share opt-in link with testers
- [ ] Promote to closed testing when ready for wider audience

### Production Release
- [ ] Promote from internal/closed testing to production
- [ ] Set rollout percentage (start at 20%, increase gradually)
- [ ] Monitor crash reports in Play Console

---

## Pre-Release Verification

- [ ] `flutter analyze` passes with zero issues
- [ ] `flutter test` passes all tests
- [ ] Code generation is up to date (`dart run build_runner build`)
- [ ] App icon and splash screen are final
- [ ] All placeholder screens replaced with real UI
- [ ] IAP products configured in both stores (if applicable)
- [ ] Privacy policy URL live and accessible
- [ ] Support email configured

## Post-Release

- [ ] Monitor crash reports (Crashlytics / Play Console / Xcode Organizer)
- [ ] Respond to user reviews within 48 hours
- [ ] Tag release in git: `git tag v1.0.0`
