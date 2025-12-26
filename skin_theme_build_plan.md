# YAWA4U Skin Theme System - Build Plan

## Overview

This document outlines the architecture and implementation plan for a customizable "Skin" system that allows users to personalize the app's visual appearance. This feature aims to improve user retention by giving users ownership over their experience.

---

## Table of Contents

1. [Current Theme Architecture](#1-current-theme-architecture)
2. [Skin System Architecture](#2-skin-system-architecture)
3. [UI Element Catalog](#3-ui-element-catalog)
4. [Skin Definition Schema](#4-skin-definition-schema)
5. [Implementation Phases](#5-implementation-phases)
6. [Developer Guide](#6-developer-guide)
7. [Built-in Skins](#7-built-in-skins)
8. [Future Considerations](#8-future-considerations)

---

## 1. Current Theme Architecture

### Existing Files

```
lib/core/theme/
├── app_theme.dart      # ThemeData for light/dark modes
├── colors.dart         # AppColors static color constants
└── text_styles.dart    # AppTextStyles typography definitions
```

### Current Capabilities

- Light/Dark mode toggle via `ThemeMode`
- Static color palette in `AppColors`
- Muscle group colors via `ThemeExtension<MuscleGroupColors>`
- Fixed typography in `AppTextStyles`

### Limitations

- Colors are compile-time constants
- No runtime customization
- Single theme per brightness mode

---

## 2. Skin System Architecture

### Proposed Structure

```
lib/core/theme/
├── app_theme.dart              # Updated to use SkinTheme
├── colors.dart                 # Keep as fallback defaults
├── text_styles.dart            # Keep as fallback defaults
└── skins/
    ├── skin_model.dart         # Skin data model
    ├── skin_provider.dart      # Riverpod provider for active skin
    ├── skin_repository.dart    # Load/save skins (Hive + JSON)
    ├── skin_builder.dart       # Convert Skin → ThemeData
    └── built_in_skins/
        ├── default_skin.dart
        ├── ocean_skin.dart
        ├── forest_skin.dart
        ├── sunset_skin.dart
        ├── neon_skin.dart
        └── minimal_skin.dart
```

### Data Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Skin JSON/    │────▶│   SkinModel     │────▶│   ThemeData     │
│   Map           │     │   (Dart class)  │     │   (Flutter)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │  SkinProvider   │
                        │  (Riverpod)     │
                        └─────────────────┘
```

---

## 3. UI Element Catalog

### 3.1 Core Colors

| Element       | Property       | Current Default    |
| ------------- | -------------- | ------------------ |
| Primary       | `primary`      | `#E53935` (Red)    |
| Primary Dark  | `primaryDark`  | `#D32F2F`          |
| Primary Light | `primaryLight` | `#EF5350`          |
| Secondary     | `secondary`    | `#42A5F5` (Blue)   |
| Success       | `success`      | `#4CAF50` (Green)  |
| Warning       | `warning`      | `#FFA726` (Orange) |
| Error         | `error`        | `#EF5350` (Red)    |
| Info          | `info`         | `#42A5F5` (Blue)   |

### 3.2 Background Colors

| Element             | Light Mode | Dark Mode |
| ------------------- | ---------- | --------- |
| Scaffold Background | `#F2F2F7`  | `#1C1C1E` |
| Card Background     | `#FFFFFF`  | `#2C2C2E` |
| Input Background    | `#F9F9F9`  | `#151516` |
| Divider             | `#E0E0E0`  | `#48484A` |

### 3.3 Text Colors

| Element        | Light Mode | Dark Mode |
| -------------- | ---------- | --------- |
| Primary Text   | `#212121`  | `#FFFFFF` |
| Secondary Text | `#757575`  | `#9E9E9E` |
| Disabled Text  | `#BDBDBD`  | `#616161` |

### 3.4 Muscle Group Colors

| Group                                     | Color  | Hex       |
| ----------------------------------------- | ------ | --------- |
| Upper Push (Chest, Triceps, Shoulders)    | Pink   | `#E91E63` |
| Upper Pull (Back, Biceps)                 | Cyan   | `#00BCD4` |
| Legs (Quads, Hamstrings, Glutes, Calves)  | Teal   | `#009688` |
| Core & Accessories (Traps, Forearms, Abs) | Purple | `#9C27B0` |

### 3.5 Workout Status Colors

| Status            | Color   | Usage                    |
| ----------------- | ------- | ------------------------ |
| Current Workout   | Primary | Active workout indicator |
| Completed Workout | Success | Finished workout badge   |
| Skipped Workout   | Grey    | Missed workout indicator |
| Deload Week       | Warning | Deload badge             |

### 3.6 Component Styles

| Component             | Customizable Properties                                   |
| --------------------- | --------------------------------------------------------- |
| **AppBar**            | backgroundColor, foregroundColor, elevation               |
| **Card**              | backgroundColor, elevation, borderRadius, shadowColor     |
| **Button (Elevated)** | backgroundColor, foregroundColor, elevation, borderRadius |
| **Button (Text)**     | foregroundColor                                           |
| **Input Field**       | fillColor, borderColor, focusBorderColor, borderRadius    |
| **Checkbox**          | checkedColor, uncheckedColor                              |
| **ProgressIndicator** | color, backgroundColor                                    |
| **BottomNavBar**      | backgroundColor, selectedColor, unselectedColor           |
| **FAB**               | backgroundColor, foregroundColor                          |
| **Dialog**            | backgroundColor, titleColor, borderRadius                 |
| **SnackBar**          | backgroundColor, textColor                                |
| **Chip/Badge**        | backgroundColor, textColor, borderRadius                  |

### 3.7 Custom Widgets to Update

| Widget             | File                        | Skinnable Properties                   |
| ------------------ | --------------------------- | -------------------------------------- |
| ExerciseCard       | `exercise_card_widget.dart` | card colors, text colors, badge colors |
| MuscleGroupBadge   | `muscle_group_badge.dart`   | muscle group colors                    |
| CalendarDropdown   | `calendar_dropdown.dart`    | selection colors, background           |
| CycleSummaryDialog | `cycle_summary_dialog.dart` | dialog styling                         |

### 3.8 Screens to Audit

- [ ] `home_screen.dart` - Bottom nav, FAB
- [ ] `workout_screen.dart` - Exercise cards, progress indicators
- [ ] `exercises_screen.dart` - List items, muscle badges
- [ ] `cycle_list_screen.dart` - Cycle cards, status badges
- [ ] `edit_workout_screen.dart` - Workout editing UI
- [ ] `more_screen.dart` - Settings list tiles
- [ ] `settings_screen.dart` - Form inputs, toggles
- [ ] `plan_a_cycle_screen.dart` - Form UI
- [ ] `cycle_create_screen.dart` - Stepper/form UI

---

## 4. Skin Definition Schema

### 4.1 JSON Structure

```json
{
  "id": "ocean_blue",
  "name": "Ocean Blue",
  "description": "A calm, ocean-inspired theme",
  "author": "YAWA4U",
  "version": "1.0.0",
  "isPremium": false,

  "colors": {
    "primary": "#0288D1",
    "primaryDark": "#01579B",
    "primaryLight": "#03A9F4",
    "secondary": "#00ACC1",
    "success": "#00C853",
    "warning": "#FFB300",
    "error": "#FF5252",
    "info": "#40C4FF"
  },

  "lightMode": {
    "scaffoldBackground": "#E3F2FD",
    "cardBackground": "#FFFFFF",
    "inputBackground": "#F5F5F5",
    "divider": "#BBDEFB",
    "textPrimary": "#0D47A1",
    "textSecondary": "#1976D2",
    "textDisabled": "#90CAF9"
  },

  "darkMode": {
    "scaffoldBackground": "#0D1B2A",
    "cardBackground": "#1B2838",
    "inputBackground": "#152238",
    "divider": "#1E3A5F",
    "textPrimary": "#E3F2FD",
    "textSecondary": "#90CAF9",
    "textDisabled": "#546E7A"
  },

  "muscleGroups": {
    "upperPush": "#E91E63",
    "upperPull": "#00BCD4",
    "legs": "#009688",
    "coreAndAccessories": "#9C27B0"
  },

  "workoutStatus": {
    "current": "#0288D1",
    "completed": "#00C853",
    "skipped": "#78909C",
    "deload": "#FFB300"
  },

  "components": {
    "cardBorderRadius": 12,
    "buttonBorderRadius": 8,
    "inputBorderRadius": 8,
    "cardElevation": 2,
    "buttonElevation": 2
  },

  "typography": {
    "fontFamily": "System",
    "headingWeight": "bold",
    "bodyWeight": "normal"
  }
}
```

### 4.2 Dart Model

```dart
// lib/core/theme/skins/skin_model.dart

@freezed
class SkinModel with _$SkinModel {
  const factory SkinModel({
    required String id,
    required String name,
    required String description,
    required String author,
    required String version,
    @Default(false) bool isPremium,
    required SkinColors colors,
    required SkinModeColors lightMode,
    required SkinModeColors darkMode,
    required SkinMuscleGroupColors muscleGroups,
    required SkinWorkoutStatusColors workoutStatus,
    required SkinComponents components,
    required SkinTypography typography,
  }) = _SkinModel;

  factory SkinModel.fromJson(Map<String, dynamic> json) =>
      _$SkinModelFromJson(json);
}

@freezed
class SkinColors with _$SkinColors {
  const factory SkinColors({
    required String primary,
    required String primaryDark,
    required String primaryLight,
    required String secondary,
    required String success,
    required String warning,
    required String error,
    required String info,
  }) = _SkinColors;
}

@freezed
class SkinModeColors with _$SkinModeColors {
  const factory SkinModeColors({
    required String scaffoldBackground,
    required String cardBackground,
    required String inputBackground,
    required String divider,
    required String textPrimary,
    required String textSecondary,
    required String textDisabled,
  }) = _SkinModeColors;
}

// ... additional freezed classes for other sections
```

---

## 5. Implementation Phases

### Phase 1: Foundation (Week 1) ✅ COMPLETE

- [x] Create `SkinModel` with json_serializable
- [x] Create `SkinRepository` for loading/saving skins
- [x] Create `SkinProvider` with Riverpod
- [x] Create `SkinBuilder` to convert SkinModel → ThemeData
- [x] Update `AppTheme` to use skin-based theme generation (via main.dart)
- [x] Implement "Default" skin matching current theme
- [x] Create 6 built-in skins (Default, Ocean, Forest, Sunset, Neon, Minimal)

### Phase 2: UI Integration (Week 2) ✅ COMPLETE

- [x] Update `main.dart` to use SkinProvider
- [x] Audit all screens for hardcoded colors (none found in presentation layer!)
- [x] Replace `AppColors.xxx` with `Theme.of(context).xxx` (already done)
- [x] Update custom widgets to use theme colors (already using theme)
- [ ] Test light/dark mode with new skin system

### Phase 3: Skin Selection UI (Week 3) ✅ COMPLETE

- [x] Create `SkinSelectionScreen`
- [x] Add skin preview cards with color swatches
- [x] Implement skin switching (instant via Riverpod)
- [x] Add to More/Settings screen navigation
- [x] Save selected skin preference (via Hive)

### Phase 4: Built-in Skins (Week 4) ✅ COMPLETE

- [x] Design and implement 6 built-in skins:
  - Default (current red theme)
  - Ocean Blue
  - Forest Green
  - Sunset Orange
  - Neon Purple
  - Minimal Monochrome
- [x] Create skin preview images/thumbnails (using dynamic `_ColorSwatchPreview` widget)

### Phase 5: Polish & Testing (Week 5) 🔄 IN PROGRESS

- [x] Create `SkinContext` extension for easy access to skin colors
- [x] Create `AppSnackBar` helper for themed snackbars
- [x] Update key screens to use theme colors:
  - [x] `edit_workout_screen.dart` - SnackBars, delete buttons, set type radio buttons
  - [x] `cycle_list_screen.dart` - SnackBars, delete buttons, warning containers
  - [x] `workout_screen.dart` - SnackBars, menu items, finish button
  - [x] `calendar_dropdown.dart` - SnackBars, day indicators
  - [x] `exercise_card_widget.dart` - Log checkbox, delete buttons, set type radio buttons
  - [x] `completed_cycle_workout_screen.dart` - Completed badge
  - [x] `plan_a_cycle_screen.dart` - Warning container
  - [x] `exercise_info_dialog.dart` - YouTube button colors
  - [x] `available_equipment_filter.dart` - Checkbox selected indicator
  - [x] `muscle_group_stats_dialog.dart` - Error text color
  - [x] `sentry_debug_screen.dart` - Test crash button
- [ ] Complete migration of remaining hardcoded colors:
  - [ ] `exercises_screen.dart`
  - [ ] `sync_screen.dart`
  - [ ] `settings_screen.dart`
  - [ ] `cycle_create_screen.dart`
  - [ ] `template_selection_screen.dart`
  - [ ] `template_share_screen.dart`
  - [ ] `onboarding/*.dart` screens
  - [ ] `app_router.dart` (error screen)
- [ ] Test all screens with all skins
- [ ] Test light/dark mode transitions
- [ ] Performance optimization
- [ ] Accessibility check (contrast ratios)
- [ ] Beta testing

### Future Phases

- [ ] Custom skin creation UI
- [ ] Skin import/export (share with friends)
- [ ] Premium skins (monetization)
- [ ] Seasonal/holiday skins
- [ ] Community skin marketplace

---

## 6. Developer Guide

### 6.1 Creating a New Skin

1. Create JSON file in `assets/skins/` or Dart file in `lib/core/theme/skins/built_in_skins/`
2. Follow the schema defined in Section 4
3. Test with both light and dark modes
4. Ensure contrast ratios meet WCAG AA standards (4.5:1 for text)

### 6.2 Accessing Skin Colors in Widgets

```dart
// Instead of:
color: AppColors.primary

// Use:
color: Theme.of(context).colorScheme.primary

// For custom colors (muscle groups, etc.):
final muscleColors = Theme.of(context).extension<MuscleGroupColors>()!;
color: muscleColors.upperPush
```

### 6.3 Adding New Skinnable Properties

1. Add property to `SkinModel`
2. Update JSON schema
3. Update `SkinBuilder` to apply property to ThemeData
4. Update all built-in skins with new property

### 6.4 Testing Skins

```dart
// In widget tests, wrap with skin:
testWidgets('MyWidget with Ocean skin', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        skinProvider.overrideWithValue(OceanSkin()),
      ],
      child: MyApp(),
    ),
  );
});
```

---

## 7. Built-in Skins

### 7.1 Default (Current Theme)

- Primary: Red `#E53935`
- Vibe: Energetic, motivational
- Target: Users who like the current look

### 7.2 Ocean Blue

- Primary: Blue `#0288D1`
- Vibe: Calm, focused
- Target: Users wanting a cooler palette

### 7.3 Forest Green

- Primary: Green `#388E3C`
- Vibe: Natural, grounded
- Target: Nature lovers, eco-conscious users

### 7.4 Sunset Orange

- Primary: Orange `#F57C00`
- Vibe: Warm, energetic
- Target: Users wanting warmth without red

### 7.5 Neon Purple

- Primary: Purple `#7C4DFF`
- Vibe: Bold, modern
- Target: Younger users, night owls

### 7.6 Minimal Monochrome

- Primary: Grey `#424242`
- Vibe: Clean, distraction-free
- Target: Minimalist users

---

## 8. Future Considerations

### 8.1 Custom Skin Editor

- In-app color picker
- Real-time preview
- Save custom skins locally
- Share skins via QR code or link

### 8.2 Premium Skins

- Unlock via in-app purchase
- Seasonal limited-edition skins
- Collaboration skins (fitness influencers)

### 8.3 Dynamic Skins

- Time-based themes (sunrise/sunset colors)
- Achievement-unlocked skins
- Streak milestone skins

### 8.4 Accessibility

- High contrast skin option
- Colorblind-friendly palettes
- Font size scaling integration

### 8.5 Performance

- Lazy load skin assets
- Cache computed ThemeData
- Efficient skin switching animation

---

## Appendix: Color Contrast Checker

Use these tools to verify accessibility:

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Coolors Contrast Checker](https://coolors.co/contrast-checker)

**Minimum Ratios (WCAG AA):**

- Normal text: 4.5:1
- Large text (18px+): 3:1
- UI components: 3:1

---

## Appendix: File Change Summary

### New Files to Create

```
lib/core/theme/skins/
├── skin_model.dart
├── skin_model.freezed.dart (generated)
├── skin_model.g.dart (generated)
├── skin_provider.dart
├── skin_repository.dart
├── skin_builder.dart
└── built_in_skins/
    ├── default_skin.dart
    ├── ocean_skin.dart
    ├── forest_skin.dart
    ├── sunset_skin.dart
    ├── neon_skin.dart
    └── minimal_skin.dart

lib/presentation/screens/
└── skin_selection_screen.dart

assets/skins/
├── default.json
├── ocean_blue.json
├── forest_green.json
├── sunset_orange.json
├── neon_purple.json
└── minimal_monochrome.json
```

### Files to Modify

```
lib/main.dart                    # Add SkinProvider
lib/core/theme/app_theme.dart    # Use SkinBuilder
lib/presentation/screens/*.dart  # Replace hardcoded colors
lib/presentation/widgets/*.dart  # Use theme colors
pubspec.yaml                     # Add skin assets
```

---

_Document Version: 1.0_
_Last Updated: December 25, 2025_
