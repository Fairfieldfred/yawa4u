import '../../core/constants/sports.dart';

/// In-memory model of a prebuilt cardio session loaded from
/// `assets/cardio_sessions/*.json`.
///
/// These are authoring-friendly starting points — users pick one, the
/// repository creates a fresh [CardioSession] based on the template, and
/// they tweak from there. The template itself is never persisted to the
/// DB.
///
/// Intentionally separate from [TrainingCycleTemplate] (which is a full
/// multi-period plan) — a cardio session template is a single session.
class CardioSessionTemplate {
  final String id;
  final String name;
  final Sport sport;
  final String description;
  final String category;
  final CardioSessionDifficulty difficulty;
  final int durationEstimateSec;
  final List<CardioIntervalTemplate> intervals;

  const CardioSessionTemplate({
    required this.id,
    required this.name,
    required this.sport,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationEstimateSec,
    required this.intervals,
  });

  factory CardioSessionTemplate.fromJson(Map<String, dynamic> json) {
    return CardioSessionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: Sports.parse(json['sport'] as String) ?? Sport.other,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      durationEstimateSec: json['durationEstimateSec'] as int? ?? 0,
      intervals:
          (json['intervals'] as List?)
              ?.map(
                (i) =>
                    CardioIntervalTemplate.fromJson(i as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  static CardioSessionDifficulty _parseDifficulty(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'beginner':
        return CardioSessionDifficulty.beginner;
      case 'advanced':
        return CardioSessionDifficulty.advanced;
      case 'intermediate':
      default:
        return CardioSessionDifficulty.intermediate;
    }
  }
}

enum CardioSessionDifficulty { beginner, intermediate, advanced }

extension CardioSessionDifficultyExt on CardioSessionDifficulty {
  String get displayName {
    switch (this) {
      case CardioSessionDifficulty.beginner:
        return 'Beginner';
      case CardioSessionDifficulty.intermediate:
        return 'Intermediate';
      case CardioSessionDifficulty.advanced:
        return 'Advanced';
    }
  }
}

/// Authoring-format interval — lifted directly from JSON, then converted
/// to a [SessionInterval] with a fresh UUID at instantiation time.
class CardioIntervalTemplate {
  final IntervalIntent intent;
  final IntervalTargetKind targetKind;
  final int? targetDurationSec;
  final double? targetDistanceM;
  final int? targetHrZone;
  final int? targetPaceZone;
  final int? targetPowerZone;
  final String? notes;

  const CardioIntervalTemplate({
    required this.intent,
    required this.targetKind,
    this.targetDurationSec,
    this.targetDistanceM,
    this.targetHrZone,
    this.targetPaceZone,
    this.targetPowerZone,
    this.notes,
  });

  factory CardioIntervalTemplate.fromJson(Map<String, dynamic> json) {
    return CardioIntervalTemplate(
      intent: _parseIntent(json['intent'] as String?),
      targetKind: _parseTargetKind(json['targetKind'] as String?),
      targetDurationSec: json['targetDurationSec'] as int?,
      targetDistanceM: (json['targetDistanceM'] as num?)?.toDouble(),
      targetHrZone: json['targetHrZone'] as int?,
      targetPaceZone: json['targetPaceZone'] as int?,
      targetPowerZone: json['targetPowerZone'] as int?,
      notes: json['notes'] as String?,
    );
  }

  static IntervalIntent _parseIntent(String? raw) {
    if (raw == null) return IntervalIntent.work;
    return IntervalIntent.values.firstWhere(
      (i) => i.name == raw,
      orElse: () => IntervalIntent.work,
    );
  }

  static IntervalTargetKind _parseTargetKind(String? raw) {
    if (raw == null) return IntervalTargetKind.durationSec;
    return IntervalTargetKind.values.firstWhere(
      (k) => k.name == raw,
      orElse: () => IntervalTargetKind.durationSec,
    );
  }
}
