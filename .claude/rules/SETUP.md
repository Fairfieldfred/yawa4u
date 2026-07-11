# YAWA Gym Setup Guide

This guide will help you set up Firebase and Sentry for the YAWA Gym app.

## Firebase Setup

Firebase is already configured for this project. The configuration files have been generated:

- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **macOS**: `macos/Runner/GoogleService-Info.plist`
- **Dart/Flutter**: `lib/firebase_options.dart`

### What's Already Configured

✅ Firebase Core
✅ Firebase Analytics (anonymous tracking)
✅ Platform-specific configuration files
✅ Analytics service wrapper in `lib/data/services/analytics_service.dart`

### Firebase Project Details

- **Project ID**: yawa-39ce6
- **Android App ID**: 1:281676506648:android:1894af38824381ec05c56d
- **iOS App ID**: 1:281676506648:ios:4d9dc7120013cbe305c56d
- **Web App ID**: 1:281676506648:web:a1d3ec5520351a6005c56d

### Privacy & Analytics

The app tracks the following events **without** collecting personal data:
- Mesocycle lifecycle (created, started, completed, deleted)
- Workout completion/skipping
- Template usage
- Export/import events
- Feature usage (filters, feedback, Myorep sets)

**Never tracked**:
- User weights, reps, or performance data
- Personal identifying information
- Workout content details

## Sentry Setup

Sentry is configured for crash reporting and error tracking.

### Configuration File

Edit `lib/core/config/sentry_config.dart` and replace the DSN:

```dart
static const String dsn = 'YOUR_SENTRY_DSN_HERE';
```

### Getting Your Sentry DSN

1. Go to [https://sentry.io](https://sentry.io)
2. Create a new project or use an existing one
3. Navigate to **Settings** → **Projects** → **[Your Project]** → **Client Keys (DSN)**
4. Copy the DSN URL
5. Paste it into `lib/core/config/sentry_config.dart`

### Sentry Properties File

The `sentry.properties` file is already configured with your auth token for uploading debug symbols.

**⚠️ Important**: This file contains sensitive credentials and should be kept secure.

### Sentry Configuration Options

You can customize Sentry behavior in `lib/core/config/sentry_config.dart`:

- **Environment**: Set via `SENTRY_ENVIRONMENT` environment variable (default: `development`)
- **Release**: Set via `SENTRY_RELEASE` environment variable (default: `1.0.0+1`)
- **Traces Sample Rate**: 0.2 (20% of transactions sent to Sentry)
- **Enable/Disable**: Set via `SENTRY_ENABLED` environment variable (default: `true`)

### Privacy Configuration

Sentry is configured to **NOT** send personal identifiable information:

```dart
options.sendDefaultPii = false;
```

Session replay is disabled by default to protect user privacy.

## Local Notifications (rest timer)

The rest timer schedules a one-shot local notification at its deadline via
`flutter_local_notifications` (wrapped by
`lib/data/services/notification_service.dart`). Platform setup is already
in place; keep it intact when touching build files:

- **Android** (`android/app/`):
  - `build.gradle.kts` enables core library desugaring
    (`isCoreLibraryDesugaringEnabled = true` + the
    `coreLibraryDesugaring(...)` dependency) — required by the plugin.
  - `AndroidManifest.xml` declares `POST_NOTIFICATIONS` (Android 13+
    runtime permission), `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`,
    and the two `com.dexterous.flutterlocalnotifications` receivers.
  - On Android 14+ the exact-alarm permission can be denied;
    `NotificationService` falls back to an inexact schedule automatically.
- **iOS/macOS** (`ios/Runner/AppDelegate.swift`): sets
  `UNUserNotificationCenter.current().delegate` so notifications present
  while the app is foregrounded. No Info.plist entries are needed for
  local notifications.

Permission is requested lazily the first time a rest timer starts (not at
app launch). Tests never touch the plugin — override
`notificationServiceProvider` with a fake.

## Running the App

### Development

```bash
flutter run
```

By default, Sentry won't initialize if the DSN is not configured. Firebase Analytics will work in anonymous mode.

### Production Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release

# Web
flutter build web --release
```

### Environment Variables

You can customize the build with environment variables:

```bash
# Disable Sentry
flutter run --dart-define=SENTRY_ENABLED=false

# Set environment
flutter build apk --dart-define=SENTRY_ENVIRONMENT=production

# Set release version
flutter build apk --dart-define=SENTRY_RELEASE=1.0.1+2
```

## Verifying Setup

### Test Firebase Analytics

The app automatically logs screen views. You can verify in the Firebase Console:
1. Go to Firebase Console → Analytics → Events
2. Wait 24 hours for data to appear (or use DebugView for immediate testing)

### Test Sentry

If Sentry DSN is configured, errors will be automatically captured. You can manually test:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

// In your code
Sentry.captureException(Exception('Test exception'));
```

Then check your Sentry dashboard for the error.

## Analytics Service Usage

Use the `AnalyticsService` class to track events:

```dart
import 'package:yawa_gym/data/services/analytics_service.dart';

final analytics = AnalyticsService();

// Track mesocycle created
await analytics.logMesocycleCreated(
  weeks: 6,
  daysPerWeek: 5,
  gender: 'male',
  templateName: 'Dr. Mike\'s Favorite',
);

// Track workout completed
await analytics.logWorkoutCompleted(
  weekNumber: 2,
  dayNumber: 3,
  exerciseCount: 8,
  hadMyorepSets: true,
);

// Track screen views
await analytics.logScreenView(screenName: 'Workout');
```

## Troubleshooting

### Firebase Not Working on iOS

1. Make sure `GoogleService-Info.plist` is added to your Xcode project
2. Clean build: `flutter clean && flutter pub get`
3. Rebuild iOS app

### Sentry Not Capturing Errors

1. Check that DSN is set correctly in `sentry_config.dart`
2. Verify `SENTRY_ENABLED` is not set to `false`
3. Check Sentry dashboard for issues

### Build Errors

If you encounter build errors:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Sentry Flutter Documentation](https://docs.sentry.io/platforms/flutter/)
- [Firebase Analytics Best Practices](https://firebase.google.com/docs/analytics/best-practices)
- [Sentry Privacy Policy](https://sentry.io/privacy/)
