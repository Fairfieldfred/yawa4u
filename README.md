# YAWA4U — Yet Another Workout App (For You!)

<p align="center">
  <img src="assets/yawa4u-icon-dark-124.png" alt="YAWA4U Logo" width="124"/>
</p>

<p align="center">
  <strong>A free, open-source, multi-sport training app built with Flutter</strong>
</p>

<p align="center">
  <a href="#features">Features</a> &bull;
  <a href="#tech-stack">Tech Stack</a> &bull;
  <a href="#installation">Installation</a> &bull;
  <a href="#architecture">Architecture</a> &bull;
  <a href="#contributing">Contributing</a>
</p>

---

## Overview

YAWA4U is a local-first training tracker for strength, running, cycling, and swimming. Plan periodized training cycles, log workouts on the fly, import sessions from Apple Health / Health Connect / Strava, and review your progress — all without an account or subscription.

Your data lives on your device. Export, import, and device-to-device WiFi sync keep you in control.

### Why YAWA4U?

- **Multi-sport** — Strength, run, bike, and swim in a single app with sport-aware defaults
- **Periodized planning** — Training cycles with flexible periods, recovery phases, and muscle-group priorities
- **Privacy first** — No cloud dependency, no PII collected, anonymous analytics only
- **Cross-platform** — iOS, Android, macOS, Web, Windows, Linux
- **Open source** — No ads, no subscriptions, no paywalls

---

## Features

### Training Cycles

- Create cycles with configurable periods, days per period, and recovery weeks (deload / taper / recovery)
- Mixed-sport cycles — a single cycle can hold strength workouts and cardio sessions side by side
- Optional primary sport hint with sport-aware `daysPerPeriod` defaults (strength: 4, endurance: 7)
- Muscle-group priority editor for emphasizing lagging body parts
- Pre-built templates and community-contributed cycle blueprints
- User-chosen terminology: Block, Mesocycle, Phase, Module, Wave, or default "Training Cycle"

### Strength Training

- Intuitive set logging: weight, reps, RIR (Reps In Reserve), RPE
- Set types: Regular, Myorep, Myorep Match, Max Reps, End With Partials, Drop Set
- Per-exercise feedback: joint pain, muscle pump, workload, soreness
- Exercise notes with pin-to-top option
- Exercise history overlay showing previous performances
- Smart weight pre-fill from your last performance, with a tappable "Try X" progression suggestion
- PR badge when a logged set beats your best historical set
- Configurable rest timers per exercise — the countdown survives phone lock and notifies you (haptic + local notification) when rest is over

### Cardio Sessions

- Log runs, rides, and swims with distance, duration, heart rate, cadence, and power
- Structured interval builder with nested repeat groups (warmup / work / recovery / cooldown / rest)
- Planned vs. logged sessions — plan cardio during cycle drafting, log when performed
- Swim-specific fields: pool length, stroke type, lap count, SWOLF
- Post-session feedback: RPE, breathing, GI comfort, weather notes
- Cardio session template library for common workouts (5k tempo, sweet-spot intervals, etc.)

### Home Screen

- Unified vertical scroll of strength and cardio cards, sorted by completion status
- Five deep-linkable tabs (Workout, Cycles, Exercises, Calendar, More) backed by router branches
- Pinned sport grid footer for one-tap session creation (Lift, Run, Bike, Swim)
- Grid adapts to the sports you selected during onboarding — show only what you train
- Quick-log action in the app bar of every non-Workout tab

### Integrations

- **Apple Health / Health Connect** — Import workouts via the `health` plugin; de-duped by external ID
- **Strava** — OAuth connect + activity import
- **Peloton** — Covered via the HealthKit bridge (Peloton syncs to Apple Health)
- HR / pace / power zone configuration per sport

### Exercise Library

- 335 built-in exercises loaded from CSV, covering all muscle groups and equipment types
- Create custom exercises with muscle group, equipment, video link, and default rest timer
- YouTube video integration for exercise demonstrations

### Calendar

- Visual calendar with colored sport dots per day (strength, run, bike, swim)
- Drag-and-drop rescheduling and rest-day edits, all undoable from the confirmation snackbar
- Quick navigation between training days
- Desktop and mobile calendar variants with consistent data

### Statistics

- **Strength:** Volume progression, personal records, sets by muscle group, completion rate
- **Cardio:** Per-sport aggregates (distance, duration, elevation), weekly volume buckets, sport distribution charts
- Cycle selector shared across all stats tabs

### Community Library

- Browse and download community-contributed training templates and skins (Firestore-backed)
- Downloading a template creates a ready-to-use draft cycle in one tap
- Upload your own templates and skins to share (email verification required for uploads)

### Theming

- Custom "Skins" system — create themes from seed colors or images
- Light and dark mode with system-follows option
- Share skins between devices via QR code or the community library

### Localization

- Full UI translation: English and Spanish
- Exercise names translated at display time — stored data stays canonical so history and PRs are language-independent
- See `.claude/rules/LOCALIZATION.md` to contribute a new language

### Data Management

- Local-first SQLite storage via Drift
- JSON export/import (backup format v4 — multi-sport aware)
- One-tap backup to a file via the share sheet, and restore from a picked file (merge semantics — nothing is deleted)
- Device-to-device WiFi sync via embedded HTTP server
- Template sharing between devices

---

## Tech Stack

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter | SDK ^3.10.0 |
| Language | Dart | ^3.10.0 |
| Database | Drift (SQLite) | ^2.22.1 |
| State management | Riverpod | ^3.0.3 |
| Routing | go_router | ^17.0.0 |
| Charts | fl_chart | ^1.1.1 |
| Calendar | table_calendar | ^3.2.0 |
| Health data | health | ^13.1.4 |
| Strava OAuth | flutter_web_auth_2 | ^5.0.0 |
| Local notifications | flutter_local_notifications | ^22.0.1 |
| Analytics | Firebase Analytics | ^12.0.4 |
| Error tracking | Sentry | ^9.8.0 |
| WiFi sync | shelf + shelf_router | ^1.4.2 / ^1.1.4 |
| QR sharing | qr_flutter + mobile_scanner | — |

---

## Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x or later
- Xcode (iOS/macOS) or Android Studio (Android)

### Build

```bash
git clone https://github.com/Fairfieldfred/yawa4u.git
cd yawa4u
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Target a specific platform:

```bash
flutter run -d chrome      # Web
flutter run -d macos        # macOS
flutter run -d ios          # iOS simulator
```

### Environment variables (optional)

```bash
flutter run --dart-define=SENTRY_ENABLED=false           # Disable Sentry
flutter run --dart-define=SENTRY_ENVIRONMENT=production   # Set environment
```

---

## Architecture

### Project layout

```
lib/
├── core/               # Config, constants, enums, theme/skins, extensions, utils
│   ├── constants/      # Enums, muscle groups, equipment types, sports
│   ├── theme/skins/    # Custom skin system
│   └── utils/          # Helpers, user-facing error copy, session defaults
├── data/               # Data layer
│   ├── database/       # Drift tables, DAOs, mappers, migrations
│   ├── models/         # Domain models (Session, Exercise, CardioStats, etc.)
│   ├── repositories/   # Repository pattern (Session, Workout facade, Exercise, etc.)
│   └── services/       # Analytics, health sync, Strava, CSV loader, backup, WiFi sync
├── domain/             # Business logic
│   └── providers/      # Riverpod providers (training cycle, session, workout, stats, etc.)
└── presentation/       # UI layer
    ├── navigation/     # GoRouter configuration with onboarding redirect
    ├── screens/        # Workout, cardio, calendar, stats, settings, onboarding
    └── widgets/        # Reusable widgets (exercise card, cardio card, sport grid, etc.)
```

### Data model

The database is a normalized relational schema at **schema version 6** (Drift / SQLite).

The core abstraction is the **sealed `Session` class** with two variants — `StrengthSession` and `CardioSession`. Every training action is a row in the `sessions` table, discriminated by sport. The compiler enforces exhaustive handling via `switch`.

```
Session (sealed)
├── StrengthSession → exercises → exercise_sets, exercise_feedbacks
└── CardioSession   → session_cardio (1:1), session_intervals, session_samples (opt-in)
                    └── cardio_feedback (loaded separately via repository)
```

`WorkoutRepository` exists as a **facade** over `SessionRepository` so that pre-expansion UI code keeps working. New code uses `SessionRepository` directly.

Key tables: `training_cycles`, `sessions`, `session_cardio`, `session_intervals`, `session_samples`, `cardio_feedback`, `cycle_periods`, `sport_zones`, `exercises`, `exercise_sets`, `exercise_feedbacks`, `custom_exercise_definitions`, `user_measurements`, `skins`.

### State management

- **Riverpod `StreamProvider`** for reactive Drift queries (training cycles, sessions, workouts)
- **`Provider.family`** for parameterized lookups (sessions by cycle, stats by sport)
- **Repository pattern** — repositories own all reads/writes; DAOs used directly only for hot-path debounced updates (e.g., weight/reps entry)

### Terminology

| Concept | User-facing | Code |
|---|---|---|
| A training action | Workout | `Session` (sealed) |
| A training plan | Training Cycle (user's choice of term) | `TrainingCycle` |
| A repeating segment | Period | `CyclePeriod` |
| A cardio interval step | Step | `SessionInterval` |

---

## Onboarding

A 4-screen flow guides new users:

1. **Profile** — Height and weight (optional — you can add them later in Body stats)
2. **Sports** — Multi-select: Strength, Run, Bike, Swim. Seeds per-sport unit preferences
3. **Equipment** — Available equipment types for exercise filtering (skipped when Strength isn't selected)
4. **Terminology** — Pick preferred term for "Training Cycle" (Block, Mesocycle, Phase, etc.)

Finishing lands on the Home tab, where the empty state offers "Create cycle" and "Use a template" as next steps.

---

## Contributing

### Reporting bugs

1. Check [existing issues](https://github.com/Fairfieldfred/yawa4u/issues)
2. Open a new issue with device info, reproduction steps, expected vs. actual behavior, and screenshots

### Feature requests

Open an issue with the "enhancement" label.

### Code contributions

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Run `dart run build_runner build --delete-conflicting-outputs` after schema changes
4. Run tests (`flutter test`)
5. Open a pull request

### Contributing templates

Add a JSON file to `assets/templates/` following the existing format and submit a PR.

---

## Documentation

Detailed reference documents:

| Document | Purpose |
|---|---|
| `CLAUDE.md` | Developer quick-start: commands, architecture, domain pitfalls |
| `.claude/rules/DATA_STRUCTURE_v6.md` | Schema v6 reference — tables, models, providers, enums, pitfalls |
| `.claude/rules/TERMINOLOGY.md` | Naming conventions: Workout vs Session, Period vs Week |
| `.claude/rules/LOCALIZATION.md` | Adding a new language (UI strings + exercise names) |
| `.claude/rules/SETUP.md` | Firebase and Sentry configuration |
| `docs/watch_build_plan.md` | Planned watchOS companion app |

---

## Acknowledgments

- Exercise database compiled from public fitness resources
- Built with Flutter and the Dart ecosystem
- Multi-sport expansion designed and implemented with Claude Code

---

<p align="center">
  <a href="https://github.com/Fairfieldfred/yawa4u/stargazers">Star this repo</a> if you find it useful!
</p>
