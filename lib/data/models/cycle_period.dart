import '../../core/constants/enums.dart';

/// One period of a training cycle.
///
/// Strength-only cycles typically leave [phase] null and rely on the
/// parent cycle's [TrainingCycle.recoveryPeriodType] for any special weeks.
/// Cardio / mixed cycles set one phase per period — base, build, peak,
/// taper, transition.
///
/// [creatorUuid] / [ownerUuid] are coach-mode hooks carried on every
/// user-owned row; see the multi-sport expansion plan.
class CyclePeriod {
  final String id;
  final String trainingCycleId;
  final int periodNumber; // 1-indexed
  final TrainingPhase? phase;
  final String? notes;
  final String? creatorUuid;
  final String? ownerUuid;

  const CyclePeriod({
    required this.id,
    required this.trainingCycleId,
    required this.periodNumber,
    this.phase,
    this.notes,
    this.creatorUuid,
    this.ownerUuid,
  });

  CyclePeriod copyWith({
    String? id,
    String? trainingCycleId,
    int? periodNumber,
    TrainingPhase? phase,
    bool clearPhase = false,
    String? notes,
    String? creatorUuid,
    String? ownerUuid,
  }) {
    return CyclePeriod(
      id: id ?? this.id,
      trainingCycleId: trainingCycleId ?? this.trainingCycleId,
      periodNumber: periodNumber ?? this.periodNumber,
      phase: clearPhase ? null : (phase ?? this.phase),
      notes: notes ?? this.notes,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainingCycleId': trainingCycleId,
    'periodNumber': periodNumber,
    'phase': phase?.name,
    'notes': notes,
    'creatorUuid': creatorUuid,
    'ownerUuid': ownerUuid,
  };

  factory CyclePeriod.fromJson(Map<String, dynamic> json) => CyclePeriod(
    id: json['id'] as String,
    trainingCycleId: json['trainingCycleId'] as String,
    periodNumber: json['periodNumber'] as int,
    phase: json['phase'] != null
        ? TrainingPhase.values.firstWhere(
            (e) => e.name == json['phase'],
            orElse: () => TrainingPhase.base,
          )
        : null,
    notes: json['notes'] as String?,
    creatorUuid: json['creatorUuid'] as String?,
    ownerUuid: json['ownerUuid'] as String?,
  );
}
