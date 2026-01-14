# YAWA4U - Yet Another Workout App (For You!)

<p align="center">
  <!-- TODO: Add app logo/icon here -->
  <img src="docs/images/app_logo_placeholder.png" alt="YAWA4U Logo" width="150"/>
</p>

<p align="center">
  <strong>A free, open-source, multi-platform workout tracking app built with Flutter</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 📱 Overview

YAWA4U is a comprehensive gym workout tracking application designed to help you plan, track, and progress through your training programs. Built with a local-first architecture, your data stays on your device with easy export/import capabilities for backup and cross-device sync.

### Why YAWA4U?

- **100% Free & Open Source** - No subscriptions, no ads, no hidden costs
- **Privacy First** - Your workout data stays on your device
- **Progressive Overload** - Built-in support for progressive training principles
- **Multi-Platform** - Works on iOS, Android, Web, macOS, Windows, and Linux
- **Community Driven** - Contribute templates and help improve the app

---

## ✨ Features

### Training Cycle Management

- Create and manage training cycles, blocks, phases, waves, mesocycles
- Customizable weeks, days per week, and taper, recover/rest, deload weeks
- Set muscle group priorities to emphasize specific areas
- Track progress with comprehensive summaries

### Workout Logging

- Intuitive workout interface with easy set logging
- Support for weight, reps, and RIR (Reps In Reserve) tracking
- Multiple set types: Regular, Myorep, Myorep Match
- Exercise feedback system (joint pain, muscle pump, workload, soreness)
- Workout notes and exercise notes

### Exercise Library

- Extensive exercise database with muscle groups and equipment types
- Create custom exercises
- Exercise history tracking
- YouTube video integration for exercise demonstrations

### Templates

- Pre-built workout templates to get started quickly
- Browse templates by days per week and category
- Create training cycles from templates
- Community-contributed templates

### Calendar Navigation

- Visual calendar view of your training cycle
- Quick navigation between workout days
- Color-coded completion status (completed, current, upcoming)

### Data Management

- **Local-first storage** using Hive database
- **Manual export/import** - Export your data as JSON
- **Share functionality** - Share your workout data easily
- No cloud dependency - you own your data

---

## 📸 Screenshots

<!-- TODO: Add actual screenshots of the app -->

<p align="center">
  <img src="docs/screenshots/workout_screen.png" alt="Workout Screen" width="200"/>
  <img src="docs/screenshots/calendar_view.png" alt="Calendar View" width="200"/>
  <img src="docs/screenshots/exercise_card.png" alt="Exercise Card" width="200"/>
</p>

<p align="center">
  <em>Workout logging screen • Calendar navigation • Exercise details</em>
</p>

<p align="center">
  <img src="docs/screenshots/training_cycles.png" alt="Training Cycles" width="200"/>
  <img src="docs/screenshots/exercise_library.png" alt="Exercise Library" width="200"/>
  <img src="docs/screenshots/templates.png" alt="Templates" width="200"/>
</p>

<p align="center">
  <em>Training cycles • Exercise library • Workout templates</em>
</p>

---

## 🛠 Technology Stack

| Category         | Technology         |
| ---------------- | ------------------ |
| Framework        | Flutter            |
| Database         | Hive               |
| State Management | Riverpod           |
| Routing          | go_router          |
| Analytics        | Firebase Analytics |
| Error Tracking   | Sentry             |

---

## 📦 Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- Dart SDK (included with Flutter)
- iOS: Xcode (for iOS development)
- Android: Android Studio (for Android development)

### Clone the Repository

```bash
git clone https://github.com/Fairfieldfred/yawa4u.git
cd yawa4u
```

### Install Dependencies

```bash
flutter pub get
```

### Generate Hive Adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d windows   # Windows
```

---

## 🚀 Getting Started

### Creating Your First Training Cycle

1. **Open the app** and navigate to the **Training Cycles** tab
2. Tap **+ NEW** to create a new training cycle
3. Configure your cycle:
   - Give it a name (e.g., "Summer Bulk")
   - Set the number of weeks (typically 4-8)
   - Set days per week (how often you train)
   - Select a deload week if desired
4. Choose to **Start from template** or **Create blank**
5. Start logging your workouts!

### Logging a Workout

1. Navigate to today's workout from the **Workout** tab
2. For each exercise:
   - Enter the **weight** used
   - Enter the **reps** performed (or RIR target like "2 RIR")
   - Tap the **checkbox** to log the set
3. Add **feedback** (optional) for joint pain, pump, and workload
4. Mark the workout as complete when finished

### Exporting Your Data

1. Go to the **More** tab
2. Tap **Export Data**
3. Choose to save or share your JSON backup file
4. Store safely for backup or transfer to another device

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Contributing Workout Templates

1. Create a new JSON file in `assets/templates/`
2. Follow the existing template format (see [template examples](assets/templates/))
3. Submit a pull request with your template

### Reporting Bugs

1. Check existing [issues](https://github.com/Fairfieldfred/yawa4u/issues)
2. Create a new issue with:
   - Device and OS version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Feature Requests

Open an issue with the "enhancement" label describing:

- The feature you'd like to see
- Why it would be useful
- Any implementation ideas

### Code Contributions

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities, constants, themes
│   ├── constants/            # Muscle groups, equipment types, enums
│   ├── theme/                # App theming (dark/light mode)
│   ├── utils/                # Helper functions
│   └── extensions/           # Dart extensions
├── data/                     # Data layer
│   ├── models/               # Hive data models
│   ├── repositories/         # Data repositories
│   ├── services/             # Database, export/import services
│   └── dto/                  # Data transfer objects
├── domain/                   # Business logic
│   ├── providers/            # Riverpod providers
│   └── use_cases/            # Application use cases
└── presentation/             # UI layer
    ├── screens/              # App screens
    ├── widgets/              # Reusable widgets
    └── routes/               # Navigation configuration
```

---

## 📋 Roadmap

- [x] Core workout logging functionality
- [x] Training cycle management
- [x] Exercise library with muscle groups
- [x] Template system
- [x] Export/Import functionality
- [ ] Apple Watch companion app (In Progress)
- [ ] Workout statistics and analytics
- [ ] Exercise progression recommendations
- [ ] Cloud sync (optional), maybe not

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- Thanks to all contributors who help make this app better
- Exercise database compiled from various fitness resources
- Built with love for the fitness community

---

<p align="center">
  <strong>Happy Training! 💪</strong>
</p>

<p align="center">
  <a href="https://github.com/Fairfieldfred/yawa4u/stargazers">⭐ Star this repo</a> if you find it useful!
</p>
