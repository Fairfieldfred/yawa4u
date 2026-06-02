import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Top-level activity type for a training session.
///
/// Every [Session] has a [Sport]. Strength sessions wrap the existing
/// exercises / exercise_sets hierarchy; cardio sports (run/bike/swim) use the
/// separate cardio detail + intervals child rows.
enum Sport { strength, run, bike, swim, other }

extension SportExtension on Sport {
  /// User-facing name for this sport.
  String get displayName {
    switch (this) {
      case Sport.strength:
        return 'Strength';
      case Sport.run:
        return 'Run';
      case Sport.bike:
        return 'Bike';
      case Sport.swim:
        return 'Swim';
      case Sport.other:
        return 'Other';
    }
  }

  /// Localized user-facing name for this sport.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case Sport.strength:
        return l10n.sportStrength;
      case Sport.run:
        return l10n.sportRun;
      case Sport.bike:
        return l10n.sportBike;
      case Sport.swim:
        return l10n.sportSwim;
      case Sport.other:
        return l10n.sportOther;
    }
  }

  /// Material icon used in tabs, calendar dots, and session headers.
  IconData get icon {
    switch (this) {
      case Sport.strength:
        return Icons.fitness_center;
      case Sport.run:
        return Icons.directions_run;
      case Sport.bike:
        return Icons.directions_bike;
      case Sport.swim:
        return Icons.pool;
      case Sport.other:
        return Icons.more_horiz;
    }
  }

  /// Default accent color for this sport.
  ///
  /// Intentionally lives in constants (not theme) so it's stable regardless of
  /// the active skin. Themes can override via a future SportColors theme
  /// extension when needed.
  Color get color {
    switch (this) {
      case Sport.strength:
        return const Color(0xFFE53935); // red — matches default skin primary
      case Sport.run:
        return const Color(0xFF43A047); // green
      case Sport.bike:
        return const Color(0xFF1E88E5); // blue
      case Sport.swim:
        return const Color(0xFF00ACC1); // cyan
      case Sport.other:
        return const Color(0xFF757575); // grey
    }
  }

  /// True for every sport except strength — i.e. sessions that store their
  /// data in `session_cardio` / `session_intervals` rather than
  /// `exercises` / `exercise_sets`.
  bool get isCardio => this != Sport.strength;

  bool get isStrength => this == Sport.strength;
}

/// How a [Session] ended up in the database.
///
/// Used for read-only-ness (imported sessions are locked) and analytics.
/// Coach-mode will use this to distinguish coach-planned vs. athlete-logged.
enum SessionSource {
  userPlanned,
  userLogged,
  healthKit,
  healthConnect,
  peloton,
  strava,
  garmin,
  imported,
}

extension SessionSourceExtension on SessionSource {
  String get displayName {
    switch (this) {
      case SessionSource.userPlanned:
        return 'Planned';
      case SessionSource.userLogged:
        return 'Logged';
      case SessionSource.healthKit:
        return 'Apple Health';
      case SessionSource.healthConnect:
        return 'Health Connect';
      case SessionSource.peloton:
        return 'Peloton';
      case SessionSource.strava:
        return 'Strava';
      case SessionSource.garmin:
        return 'Garmin';
      case SessionSource.imported:
        return 'Imported';
    }
  }

  /// Localized user-facing name for this session source.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case SessionSource.userPlanned:
        return l10n.sessionSourcePlanned;
      case SessionSource.userLogged:
        return l10n.sessionSourceLogged;
      case SessionSource.healthKit:
        return l10n.sessionSourceAppleHealth;
      case SessionSource.healthConnect:
        return l10n.sessionSourceHealthConnect;
      case SessionSource.peloton:
        return l10n.sessionSourcePeloton;
      case SessionSource.strava:
        return l10n.sessionSourceStrava;
      case SessionSource.garmin:
        return l10n.sessionSourceGarmin;
      case SessionSource.imported:
        return l10n.sessionSourceImported;
    }
  }

  /// True if this session came from outside the app and should generally be
  /// treated as read-only (aggregates, samples) while still allowing notes /
  /// RPE / feedback edits.
  bool get isExternal {
    switch (this) {
      case SessionSource.userPlanned:
      case SessionSource.userLogged:
        return false;
      case SessionSource.healthKit:
      case SessionSource.healthConnect:
      case SessionSource.peloton:
      case SessionSource.strava:
      case SessionSource.garmin:
      case SessionSource.imported:
        return true;
    }
  }
}

/// Role of a step inside a structured cardio workout.
enum IntervalIntent {
  warmup,
  work,
  recovery,
  cooldown,
  rest,
  repeatGroup,
}

extension IntervalIntentExtension on IntervalIntent {
  String get displayName {
    switch (this) {
      case IntervalIntent.warmup:
        return 'Warm-up';
      case IntervalIntent.work:
        return 'Work';
      case IntervalIntent.recovery:
        return 'Recovery';
      case IntervalIntent.cooldown:
        return 'Cool-down';
      case IntervalIntent.rest:
        return 'Rest';
      case IntervalIntent.repeatGroup:
        return 'Repeat';
    }
  }

  /// Localized user-facing name for this interval intent.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case IntervalIntent.warmup:
        return l10n.intervalIntentWarmup;
      case IntervalIntent.work:
        return l10n.intervalIntentWork;
      case IntervalIntent.recovery:
        return l10n.intervalIntentRecovery;
      case IntervalIntent.cooldown:
        return l10n.intervalIntentCooldown;
      case IntervalIntent.rest:
        return l10n.intervalIntentRest;
      case IntervalIntent.repeatGroup:
        return l10n.intervalIntentRepeat;
    }
  }

  /// Intervals whose `repeatCount` is meaningful.
  bool get isRepeat => this == IntervalIntent.repeatGroup;
}

/// What a single interval is targeting.
///
/// Exactly one of the matching target fields on [SessionInterval] is populated
/// based on this value.
enum IntervalTargetKind {
  durationSec,
  distanceM,
  hrZone,
  paceZone,
  powerZone,
  freeform,
}

extension IntervalTargetKindExtension on IntervalTargetKind {
  String get displayName {
    switch (this) {
      case IntervalTargetKind.durationSec:
        return 'Duration';
      case IntervalTargetKind.distanceM:
        return 'Distance';
      case IntervalTargetKind.hrZone:
        return 'HR zone';
      case IntervalTargetKind.paceZone:
        return 'Pace zone';
      case IntervalTargetKind.powerZone:
        return 'Power zone';
      case IntervalTargetKind.freeform:
        return 'Freeform';
    }
  }

  /// Localized user-facing name for this target kind.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case IntervalTargetKind.durationSec:
        return l10n.intervalTargetDuration;
      case IntervalTargetKind.distanceM:
        return l10n.intervalTargetDistance;
      case IntervalTargetKind.hrZone:
        return l10n.intervalTargetHrZone;
      case IntervalTargetKind.paceZone:
        return l10n.intervalTargetPaceZone;
      case IntervalTargetKind.powerZone:
        return l10n.intervalTargetPowerZone;
      case IntervalTargetKind.freeform:
        return l10n.intervalTargetFreeform;
    }
  }
}

/// Swim stroke classification for pool swims.
enum StrokeType {
  freestyle,
  backstroke,
  breaststroke,
  butterfly,
  mixed,
  drill,
}

extension StrokeTypeExtension on StrokeType {
  String get displayName {
    switch (this) {
      case StrokeType.freestyle:
        return 'Freestyle';
      case StrokeType.backstroke:
        return 'Backstroke';
      case StrokeType.breaststroke:
        return 'Breaststroke';
      case StrokeType.butterfly:
        return 'Butterfly';
      case StrokeType.mixed:
        return 'Mixed';
      case StrokeType.drill:
        return 'Drill';
    }
  }

  /// Localized user-facing name for this stroke type.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case StrokeType.freestyle:
        return l10n.strokeTypeFreestyle;
      case StrokeType.backstroke:
        return l10n.strokeTypeBackstroke;
      case StrokeType.breaststroke:
        return l10n.strokeTypeBreaststroke;
      case StrokeType.butterfly:
        return l10n.strokeTypeButterfly;
      case StrokeType.mixed:
        return l10n.strokeTypeMixed;
      case StrokeType.drill:
        return l10n.strokeTypeDrill;
    }
  }
}

/// Lookup helpers mirroring the pattern used by [MuscleGroups] and
/// [EquipmentTypes].
class Sports {
  const Sports._();

  /// All [Sport] values in canonical order.
  static const List<Sport> all = Sport.values;

  /// All cardio [Sport] values (excludes strength).
  static List<Sport> get cardio => Sport.values.where((s) => s.isCardio).toList(growable: false);

  /// Case-insensitive parser that tolerates common aliases ("running" → run,
  /// "cycling" → bike, "swimming" → swim).
  static Sport? parse(String name) {
    final normalized = name.trim().toLowerCase();
    switch (normalized) {
      case 'strength':
      case 'lifting':
      case 'lift':
      case 'weights':
        return Sport.strength;
      case 'run':
      case 'running':
        return Sport.run;
      case 'bike':
      case 'cycling':
      case 'cycle':
      case 'ride':
        return Sport.bike;
      case 'swim':
      case 'swimming':
        return Sport.swim;
      case 'other':
        return Sport.other;
      default:
        return null;
    }
  }
}
