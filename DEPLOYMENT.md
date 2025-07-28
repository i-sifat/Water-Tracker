# Deployment Guide - Water Tracker

This guide covers the complete deployment process for the Water Tracker app to various platforms.

## 📋 Pre-Deployment Checklist

### Code Quality
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis passes (`flutter analyze`)
- [ ] Code formatting is consistent (`dart format`)
- [ ] No debug prints or test code in production
- [ ] All TODO comments resolved or documented

### Version Management
- [ ] Version number updated in `pubspec.yaml`
- [ ] Build number incremented
- [ ] `CHANGELOG.md` updated with release notes
- [ ] Git tags created for release version

### Assets and Resources
- [ ] All required assets included
- [ ] App icons generated for all platforms
- [ ] Splash screens configured
- [ ] Localization files up to date

### Configuration
- [ ] Production API endpoints configured
- [ ] Debug flags disabled
- [ ] Analytics and crash reporting enabled
- [ ] Performance monitoring configured

## 🏗️ Build Configuration

### Environment Setup

```bash
# Verify Flutter installation
flutter doctor -v

# Clean previous builds
flutter clean
flutter pub get

# Generate localization files
flutter gen-l10n
```

### Build Commands

#### Android Release Build

```bash
# APK (for testing)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64
```

#### iOS Release Build

```bash
# iOS Archive
flutter build ios --release

# Or build from Xcode
open ios/Runner.xcworkspace
# Product > Archive
```

#### Web Build

```bash
flutter build web --release
```

## 📱 Android Deployment

### Google Play Store

#### 1. Prepare App Bundle

```bash
# Build release bundle
flutter build appbundle --release

# Verify bundle
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
```

#### 2. Store Listing Assets

Create the following assets:

**App Icon**
- 512 x 512 px PNG
- High-resolution, no transparency

**Screenshots**
- Phone: 1080 x 1920 px (minimum 2, maximum 8)
- 7-inch tablet: 1200 x 1920 px
- 10-inch tablet: 1920 x 1200 px

**Feature Graphic**
- 1024 x 500 px JPG or PNG
- No transparency

**Store Listing Content**
```
Title: Water Tracker - Hydration Reminder
Short Description: Track daily water intake with smart reminders and analytics
Full Description: [See store listing template below]
```

#### 3. Upload Process

1. **Google Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Select your app or create new app
   - Navigate to "Release" > "Production"

2. **Upload Bundle**
   - Click "Create new release"
   - Upload the AAB file
   - Add release notes

3. **Store Listing**
   - Complete all required fields
   - Upload all assets
   - Set content rating
   - Configure pricing and distribution

4. **Review and Publish**
   - Review all information
   - Submit for review
   - Monitor review status

### Firebase App Distribution (Beta Testing)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init

# Upload to App Distribution
firebase appdistribution:distribute build/app/outputs/bundle/release/app-release.aab \
  --app YOUR_APP_ID \
  --groups "beta-testers" \
  --release-notes "Beta release with new features"
```

## 🍎 iOS Deployment

### App Store Connect

#### 1. Xcode Configuration

```bash
# Open iOS project
open ios/Runner.xcworkspace

# Configure signing
# Select Runner target
# Signing & Capabilities tab
# Select your team and provisioning profile
```

#### 2. Archive and Upload

1. **Create Archive**
   - Product > Archive
   - Wait for archive to complete
   - Organizer window opens

2. **Upload to App Store**
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow upload wizard

#### 3. App Store Connect Configuration

1. **App Information**
   - App name: Water Tracker
   - Bundle ID: com.yourcompany.watertracker
   - SKU: unique identifier

2. **Pricing and Availability**
   - Free app
   - Available in all territories

3. **App Store Information**
   - Screenshots for all device types
   - App description and keywords
   - Support URL and privacy policy URL

4. **Build Selection**
   - Select uploaded build
   - Add "What's New" text

5. **Submit for Review**
   - Complete all sections
   - Submit for App Store review

### TestFlight (Beta Testing)

1. **Upload Build** (same as App Store process)
2. **TestFlight Configuration**
   - Add beta testers
   - Create test groups
   - Add test information
3. **Distribute to Testers**
   - Send invitations
   - Monitor feedback

## 🌐 Web Deployment

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

### GitHub Pages

```bash
# Build web version
flutter build web --release --base-href "/water-tracker/"

# Deploy to gh-pages branch
# (Use GitHub Actions or manual deployment)
```

### Custom Server

```bash
# Build web version
flutter build web --release

# Upload build/web/ contents to your server
# Configure web server for SPA routing
```

## 🔧 CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build appbundle --release
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.yourcompany.watertracker
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production

  deploy-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ios --release --no-codesign
      - name: Build and upload to App Store
        env:
          APP_STORE_CONNECT_USERNAME: ${{ secrets.APP_STORE_CONNECT_USERNAME }}
          APP_STORE_CONNECT_PASSWORD: ${{ secrets.APP_STORE_CONNECT_PASSWORD }}
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath Runner.xcarchive archive
          xcodebuild -exportArchive -archivePath Runner.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist
```

## 📊 Store Listing Templates

### Google Play Store Description

```
🌊 Water Tracker - Your Personal Hydration Companion

Stay hydrated and healthy with Water Tracker, the most intuitive and feature-rich hydration app available. Track your daily water intake, set personalized goals, and build healthy habits that last.

✨ KEY FEATURES:
• Smart daily goal calculation based on your profile
• Multiple drink types with accurate water content
• Beautiful progress visualization and animations
• Comprehensive history and analytics
• Customizable reminders and notifications
• Dark and light theme support
• Multi-language support with RTL layout

🏆 PREMIUM FEATURES (Donation-based unlock):
• Advanced weekly and monthly analytics
• Custom drink types and water percentages
• Data export in multiple formats
• Health app integration (Google Fit)
• Unlimited history access
• Custom reminder scheduling

🎯 PERFECT FOR:
• Health-conscious individuals
• Fitness enthusiasts
• People with busy lifestyles
• Anyone wanting to improve their hydration habits

🔒 PRIVACY FIRST:
• All data stored locally on your device
• No account required
• No personal information collected
• Complete control over your data

📱 BEAUTIFUL DESIGN:
• Clean, modern interface
• Smooth animations and interactions
• Accessibility features included
• Optimized for all screen sizes

Download Water Tracker today and start your journey to better hydration!

Support: support@watertracker.app
Privacy Policy: [URL]
```

### App Store Description

```
Water Tracker - Hydration Reminder

Stay hydrated with the most beautiful and intuitive water tracking app. Set personalized goals, track your intake, and build healthy habits.

FEATURES:
• Smart goal calculation
• Multiple drink types
• Progress visualization
• History and analytics
• Custom reminders
• Premium features via donation

Perfect for health-conscious users who want to improve their hydration habits with a clean, easy-to-use interface.

Privacy-focused: All data stays on your device.
```

## 🔍 Post-Deployment Monitoring

### Analytics Setup

```dart
// Firebase Analytics
FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Track app launches
analytics.logAppOpen();

// Track feature usage
analytics.logEvent(
  name: 'water_added',
  parameters: {'amount': 250, 'drink_type': 'water'},
);
```

### Crash Reporting

```dart
// Firebase Crashlytics
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  fatal: false,
);
```

### Performance Monitoring

```dart
// Firebase Performance
final trace = FirebasePerformance.instance.newTrace('water_add_trace');
trace.start();
// ... perform operation
trace.stop();
```

## 🚨 Rollback Procedures

### Google Play Store

1. **Staged Rollout**
   - Start with 5% rollout
   - Monitor crash rates and reviews
   - Gradually increase percentage

2. **Emergency Rollback**
   - Go to Play Console
   - Release Management > App releases
   - Halt rollout or rollback to previous version

### App Store

1. **Phased Release**
   - Enable phased release for automatic rollout
   - Monitor metrics in App Store Connect

2. **Emergency Actions**
   - Remove app from sale (temporary)
   - Submit hotfix version
   - Contact Apple for expedited review

## 📞 Support and Maintenance

### Monitoring Checklist

- [ ] App store ratings and reviews
- [ ] Crash reports and error rates
- [ ] Performance metrics
- [ ] User feedback and support requests
- [ ] Analytics data and user engagement

### Regular Maintenance

- [ ] Security updates
- [ ] Dependency updates
- [ ] Performance optimizations
- [ ] Bug fixes
- [ ] Feature enhancements

### Emergency Response

1. **Critical Bug Detected**
   - Assess impact and severity
   - Prepare hotfix
   - Fast-track through stores
   - Communicate with users

2. **Store Policy Violations**
   - Review store policies
   - Make necessary changes
   - Resubmit for review
   - Appeal if necessary

---

## 📝 Deployment Checklist

### Pre-Release
- [ ] Code review completed
- [ ] All tests passing
- [ ] Performance testing done
- [ ] Security audit completed
- [ ] Store assets prepared

### Release Day
- [ ] Builds uploaded to stores
- [ ] Store listings updated
- [ ] Release notes published
- [ ] Team notified
- [ ] Monitoring enabled

### Post-Release
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Verify analytics data
- [ ] Respond to user feedback
- [ ] Plan next iteration

**Remember**: Always test thoroughly before deployment and have a rollback plan ready!