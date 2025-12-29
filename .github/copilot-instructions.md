# YAWA4U - Copilot Instructions

## Project Overview

Flutter workout tracking app (iOS, Android, Web, macOS, Windows, Linux) using **Riverpod 3.0** for state management and **Hive** for local-first persistence. The app tracks TrainingCycles → Workouts → Exercises → Sets.

## Architecture (Clean Architecture)

```
lib/
├── core/          # Shared utilities, constants, theme system
├── data/          # Models, repositories, services (Hive persistence)
├── domain/        # Providers (Riverpod), controllers (business logic)
├── presentation/  # Screens, widgets, navigation (go_router)
```

### Key Data Flow

- **Providers** in `domain/providers/` expose repositories and computed state
- **Repositories** in `data/repositories/` wrap Hive boxes with typed CRUD operations
- **Controllers** in `domain/controllers/` handle complex UI state (see `WorkoutHomeController`)

## Code Generation

Models with `part '*.g.dart'` require build_runner. After modifying these files, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Files needing generation: `data/models/*.dart`, `core/constants/enums.dart`, `core/theme/skins/skin_model.dart`

## State Management Patterns

### Riverpod Providers (domain/providers/)

- Use `StreamProvider` for reactive Hive box watching (see `trainingCyclesProvider`)
- Use `Provider.family` for parameterized access (e.g., `trainingCycleProvider` by ID)
- Repositories accessed via `ref.watch(trainingCycleRepositoryProvider)`

### Controller Pattern

Complex screen logic uses `Notifier<State>` pattern:

```dart
class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  // Business logic methods access repositories via ref.read()
}
```

## Skin/Theme System

The app has a dynamic theming system in `core/theme/skins/`:

- `SkinModel` - JSON-serializable theme configuration
- `SkinBuilder.buildTheme()` - Converts skin to `ThemeData`
- `SkinRepository` - Persists active skin selection
- Built-in skins in `skins/built_in_skins/` follow the pattern in `default_skin.dart`

Access theme extensions: `Theme.of(context).extension<SkinExtension>()`

## Domain Concepts

- **TrainingCycle**: Multi-period program (draft → current → completed)
- **Period**: A flexible-length training block (not fixed to 7 days). Each cycle defines `daysPerPeriod` uniformly.
- **Workout**: Represents exercises for ONE muscle group within a training day (see critical note below)
- **Exercise**: Has sets, feedback, muscle group, equipment type
- **Templates**: JSON files in `assets/templates/` define program structures

## ⚠️ Critical: Workout vs Training Day

The database stores **multiple `Workout` objects per training day** (one per muscle group). All workouts for the same day share `periodNumber` and `dayNumber`, differentiated by `label`. When displaying a "day's workout" to users, aggregate all `Workout` objects for that day.

## ⚠️ Important: Periods vs Weeks

The app uses **"periods"** instead of weeks to support flexible training schedules (8, 9, 10+ day cycles with rest days). Key terminology:

- `periodsTotal` - Total number of periods in a cycle
- `daysPerPeriod` - Days in each period (uniform across the cycle)
- `periodNumber` - Which period a workout belongs to (1-indexed)
- `recoveryPeriod` - Optional lighter period (replaces "deload week")
- `RecoveryPeriodType` - Type of recovery: deload, activeRecovery, or rest

## WiFi Sync Feature

Local device-to-device sync via `WifiSyncService` in `data/services/wifi_sync_service.dart`:

- Uses `shelf` HTTP server + QR codes (`qr_flutter`, `mobile_scanner`)
- One device hosts server, other scans QR to connect
- Transfers full backup via `DataBackupService`
- Provider: `wifiSyncServiceProvider` in `domain/providers/sync_providers.dart`

## Template Authoring

Templates in `assets/templates/*.json` define workout programs. Structure:

```json
{
  "id": "unique_id",
  "name": "Template Name",
  "description": "...",
  "periodsTotal": 5,
  "daysPerPeriod": 8,
  "recoveryPeriod": 5,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Day 1",
      "exercises": [
        {
          "name": "Exercise Name",
          "muscleGroup": "quads", // matches MuscleGroup enum
          "equipmentType": "barbell", // matches EquipmentType enum
          "sets": 3,
          "reps": "8-12",
          "setType": "regular"
        }
      ]
    }
  ]
}
```

After adding templates, they're auto-discovered via `AssetManifest`.

## Navigation

Uses `go_router` configured in `presentation/navigation/app_router.dart`. Routes defined in `AppRoutes` class. Onboarding redirect handled in router's `redirect` callback.

## Testing

```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Specific test
```

Tests wrap widgets in `ProviderScope` for Riverpod support.

## Firebase & Sentry

- Firebase Analytics tracks anonymous events (no PII)
- Sentry captures crashes; DSN configured in `core/config/`
- Disable Sentry: `flutter run --dart-define=SENTRY_ENABLED=false`

## Common Tasks

| Task            | Command                                                                   |
| --------------- | ------------------------------------------------------------------------- |
| Run app         | `flutter run`                                                             |
| Regenerate code | `dart run build_runner build --delete-conflicting-outputs`                |
| Add package     | `flutter pub add <package>`                                               |
| Platform builds | `flutter build apk --release` / `flutter build ipa` / `flutter build web` |

## Conventions

- Enums use Hive `@HiveType` with `@HiveField` annotations (see `core/constants/enums.dart`)
- Models have `copyWith()` methods for immutable updates
- Color values in skins stored as hex strings, parsed via `SkinColors.parseHex()`
- Repositories expose underlying `box` for stream-based watching
- The `workouts` list inside `TrainingCycle` is a snapshot at creation—use `workoutsByTrainingCycleProvider` for current state
