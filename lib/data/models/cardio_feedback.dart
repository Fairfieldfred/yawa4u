/// Post-session feedback for a cardio session.
///
/// Parallels [ExerciseFeedback] but with endurance-appropriate questions.
/// RPE uses the standard 1–10 scale; breathing and GI comfort use 1–5.
class CardioFeedback {
  final int? rpe; // 1..10
  final int? breathing; // 1..5 (1 = very laboured, 5 = barely winded)
  final int? giComfort; // 1..5 (1 = awful, 5 = perfect)
  final String? weather;
  final String? notes;
  final DateTime? timestamp;
  final String? creatorUuid;
  final String? ownerUuid;

  const CardioFeedback({
    this.rpe,
    this.breathing,
    this.giComfort,
    this.weather,
    this.notes,
    this.timestamp,
    this.creatorUuid,
    this.ownerUuid,
  });

  bool get hasAnyFeedback =>
      rpe != null ||
      breathing != null ||
      giComfort != null ||
      (weather != null && weather!.isNotEmpty) ||
      (notes != null && notes!.isNotEmpty);

  CardioFeedback copyWith({
    int? rpe,
    int? breathing,
    int? giComfort,
    String? weather,
    String? notes,
    DateTime? timestamp,
    String? creatorUuid,
    String? ownerUuid,
  }) {
    return CardioFeedback(
      rpe: rpe ?? this.rpe,
      breathing: breathing ?? this.breathing,
      giComfort: giComfort ?? this.giComfort,
      weather: weather ?? this.weather,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
    );
  }

  Map<String, dynamic> toJson() => {
    'rpe': rpe,
    'breathing': breathing,
    'giComfort': giComfort,
    'weather': weather,
    'notes': notes,
    'timestamp': timestamp?.toIso8601String(),
    'creatorUuid': creatorUuid,
    'ownerUuid': ownerUuid,
  };

  factory CardioFeedback.fromJson(Map<String, dynamic> json) =>
      CardioFeedback(
        rpe: json['rpe'] as int?,
        breathing: json['breathing'] as int?,
        giComfort: json['giComfort'] as int?,
        weather: json['weather'] as String?,
        notes: json['notes'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
        creatorUuid: json['creatorUuid'] as String?,
        ownerUuid: json['ownerUuid'] as String?,
      );
}
