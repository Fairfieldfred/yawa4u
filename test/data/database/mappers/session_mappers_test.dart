import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/database/mappers/session_mappers.dart';
import 'package:yawa4u/data/models/cardio_feedback.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('SessionMapper', () {
    group('toCompanion', () {
      test('converts StrengthSession to companion', () {
        final now = DateTime(2024, 6, 15, 10, 30);
        final session = TestFixtures.createStrengthSession(
          id: 'ss-1',
          trainingCycleId: 'cycle-1',
          source: SessionSource.userLogged,
          status: WorkoutStatus.completed,
          periodNumber: 2,
          dayNumber: 3,
          dayName: 'Push Day',
          label: 'Chest',
          scheduledDate: now,
          completedDate: now,
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          notes: 'Good session',
          externalId: 'ext-1',
        );

        final companion = SessionMapper.toCompanion(session);

        expect(companion.uuid.value, equals('ss-1'));
        expect(companion.trainingCycleUuid.value, equals('cycle-1'));
        expect(companion.sport.value, equals(Sport.strength.index));
        expect(companion.source.value, equals(SessionSource.userLogged.index));
        expect(
          companion.status.value,
          equals(WorkoutStatus.completed.index),
        );
        expect(companion.periodNumber.value, equals(2));
        expect(companion.dayNumber.value, equals(3));
        expect(companion.dayName.value, equals('Push Day'));
        expect(companion.label.value, equals('Chest'));
        expect(companion.scheduledDate.value, equals(now));
        expect(companion.completedDate.value, equals(now));
        expect(companion.startTime.value, equals(now));
        expect(
          companion.endTime.value,
          equals(now.add(const Duration(hours: 1))),
        );
        expect(companion.notes.value, equals('Good session'));
        expect(companion.externalId.value, equals('ext-1'));
      });

      test('converts CardioSession to companion', () {
        final session = TestFixtures.createCardioSession(
          id: 'cs-1',
          sport: Sport.bike,
          source: SessionSource.strava,
          status: WorkoutStatus.completed,
          externalId: 'strava-123',
        );

        final companion = SessionMapper.toCompanion(session);

        expect(companion.uuid.value, equals('cs-1'));
        expect(companion.sport.value, equals(Sport.bike.index));
        expect(companion.source.value, equals(SessionSource.strava.index));
        expect(companion.externalId.value, equals('strava-123'));
      });

      test('handles null optional fields', () {
        final session = TestFixtures.createStrengthSession(
          trainingCycleId: null,
          periodNumber: null,
          dayNumber: null,
          dayName: null,
          label: null,
          scheduledDate: null,
          completedDate: null,
          startTime: null,
          endTime: null,
          notes: null,
          externalId: null,
        );

        final companion = SessionMapper.toCompanion(session);

        expect(companion.trainingCycleUuid.value, isNull);
        expect(companion.periodNumber.value, isNull);
        expect(companion.dayNumber.value, isNull);
        expect(companion.dayName.value, isNull);
        expect(companion.label.value, isNull);
        expect(companion.scheduledDate.value, isNull);
        expect(companion.completedDate.value, isNull);
        expect(companion.startTime.value, isNull);
        expect(companion.endTime.value, isNull);
        expect(companion.notes.value, isNull);
        expect(companion.externalId.value, isNull);
      });

      test('maps all Sport enum values correctly', () {
        for (final sport in Sport.values) {
          if (sport == Sport.strength) {
            final s = TestFixtures.createStrengthSession();
            final c = SessionMapper.toCompanion(s);
            expect(c.sport.value, equals(sport.index));
          } else {
            final s = TestFixtures.createCardioSession(sport: sport);
            final c = SessionMapper.toCompanion(s);
            expect(c.sport.value, equals(sport.index));
          }
        }
      });

      test('maps all SessionSource enum values correctly', () {
        for (final source in SessionSource.values) {
          final s = TestFixtures.createStrengthSession(source: source);
          final c = SessionMapper.toCompanion(s);
          expect(c.source.value, equals(source.index));
        }
      });

      test('maps all WorkoutStatus enum values correctly', () {
        for (final status in WorkoutStatus.values) {
          final s = TestFixtures.createStrengthSession(status: status);
          final c = SessionMapper.toCompanion(s);
          expect(c.status.value, equals(status.index));
        }
      });
    });
  });

  group('CardioDetailMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final detail = TestFixtures.createCardioDetail(
          plannedDistanceM: 10000.0,
          actualDistanceM: 9800.0,
          plannedDurationSec: 3600,
          actualDurationSec: 3500,
          elevationGainM: 150.0,
          elevationLossM: 145.0,
          averageHr: 155,
          maxHr: 180,
          averageCadence: 85.0,
          averagePowerWatts: 200.0,
          normalizedPowerWatts: 210.0,
          averageSpeedMps: 2.8,
          averagePaceSecPerMeter: 0.357,
          poolLengthM: 25.0,
          strokeType: StrokeType.freestyle,
          lapCount: 40,
          swolf: 35,
          perceivedExertion: 7,
          notes: 'Hard swim',
        );

        final companion = CardioDetailMapper.toCompanion('cs-1', detail);

        expect(companion.sessionUuid.value, equals('cs-1'));
        expect(companion.plannedDistanceM.value, equals(10000.0));
        expect(companion.actualDistanceM.value, equals(9800.0));
        expect(companion.plannedDurationSec.value, equals(3600));
        expect(companion.actualDurationSec.value, equals(3500));
        expect(companion.elevationGainM.value, equals(150.0));
        expect(companion.elevationLossM.value, equals(145.0));
        expect(companion.averageHr.value, equals(155));
        expect(companion.maxHr.value, equals(180));
        expect(companion.averageCadence.value, equals(85.0));
        expect(companion.averagePowerWatts.value, equals(200.0));
        expect(companion.normalizedPowerWatts.value, equals(210.0));
        expect(companion.averageSpeedMps.value, equals(2.8));
        expect(companion.averagePaceSecPerMeter.value, equals(0.357));
        expect(companion.poolLengthM.value, equals(25.0));
        expect(
          companion.strokeType.value,
          equals(StrokeType.freestyle.index),
        );
        expect(companion.lapCount.value, equals(40));
        expect(companion.swolf.value, equals(35));
        expect(companion.perceivedExertion.value, equals(7));
        expect(companion.notes.value, equals('Hard swim'));
      });

      test('handles all null optional fields', () {
        final detail = TestFixtures.createCardioDetail(
          plannedDistanceM: null,
          actualDistanceM: null,
          plannedDurationSec: null,
          actualDurationSec: null,
          elevationGainM: null,
          elevationLossM: null,
          averageHr: null,
          maxHr: null,
          averageCadence: null,
          averagePowerWatts: null,
          normalizedPowerWatts: null,
          averageSpeedMps: null,
          averagePaceSecPerMeter: null,
          poolLengthM: null,
          strokeType: null,
          lapCount: null,
          swolf: null,
          perceivedExertion: null,
          notes: null,
        );

        final companion = CardioDetailMapper.toCompanion('cs-1', detail);

        expect(companion.plannedDistanceM.value, isNull);
        expect(companion.actualDistanceM.value, isNull);
        expect(companion.plannedDurationSec.value, isNull);
        expect(companion.actualDurationSec.value, isNull);
        expect(companion.elevationGainM.value, isNull);
        expect(companion.elevationLossM.value, isNull);
        expect(companion.averageHr.value, isNull);
        expect(companion.maxHr.value, isNull);
        expect(companion.averageCadence.value, isNull);
        expect(companion.averagePowerWatts.value, isNull);
        expect(companion.normalizedPowerWatts.value, isNull);
        expect(companion.averageSpeedMps.value, isNull);
        expect(companion.averagePaceSecPerMeter.value, isNull);
        expect(companion.poolLengthM.value, isNull);
        expect(companion.strokeType.value, isNull);
        expect(companion.lapCount.value, isNull);
        expect(companion.swolf.value, isNull);
        expect(companion.perceivedExertion.value, isNull);
        expect(companion.notes.value, isNull);
      });

      test('maps all StrokeType enum values correctly', () {
        for (final strokeType in StrokeType.values) {
          final detail = TestFixtures.createCardioDetail(
            strokeType: strokeType,
          );
          final c = CardioDetailMapper.toCompanion('cs-1', detail);
          expect(c.strokeType.value, equals(strokeType.index));
        }
      });
    });
  });

  group('SessionIntervalMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final interval = TestFixtures.createSessionInterval(
          id: 'iv-1',
          sessionId: 'cs-1',
          orderIndex: 2,
          intent: IntervalIntent.work,
          targetKind: IntervalTargetKind.distanceM,
          targetDurationSec: 600,
          targetDistanceM: 1000.0,
          targetHrZone: 3,
          targetPaceZone: 2,
          targetPowerZone: 4,
          targetValueMin: 130.0,
          targetValueMax: 150.0,
          targetFreeform: 'Steady pace',
          actualDurationSec: 580,
          actualDistanceM: 1020.0,
          actualAverageHr: 142,
          actualAveragePaceSecPerMeter: 0.34,
          actualAveragePowerWatts: 195.0,
          repeatCount: 5,
          parentIntervalId: 'parent-1',
          notes: 'Interval notes',
        );

        final companion = SessionIntervalMapper.toCompanion(interval);

        expect(companion.uuid.value, equals('iv-1'));
        expect(companion.sessionUuid.value, equals('cs-1'));
        expect(companion.orderIndex.value, equals(2));
        expect(
          companion.intentType.value,
          equals(IntervalIntent.work.index),
        );
        expect(
          companion.targetKind.value,
          equals(IntervalTargetKind.distanceM.index),
        );
        expect(companion.targetDurationSec.value, equals(600));
        expect(companion.targetDistanceM.value, equals(1000.0));
        expect(companion.targetHrZone.value, equals(3));
        expect(companion.targetPaceZone.value, equals(2));
        expect(companion.targetPowerZone.value, equals(4));
        expect(companion.targetValueMin.value, equals(130.0));
        expect(companion.targetValueMax.value, equals(150.0));
        expect(companion.targetFreeform.value, equals('Steady pace'));
        expect(companion.actualDurationSec.value, equals(580));
        expect(companion.actualDistanceM.value, equals(1020.0));
        expect(companion.actualAverageHr.value, equals(142));
        expect(
          companion.actualAveragePaceSecPerMeter.value,
          equals(0.34),
        );
        expect(companion.actualAveragePowerWatts.value, equals(195.0));
        expect(companion.repeatCount.value, equals(5));
        expect(companion.parentIntervalUuid.value, equals('parent-1'));
        expect(companion.notes.value, equals('Interval notes'));
      });

      test('handles null optional fields', () {
        final interval = TestFixtures.createSessionInterval(
          targetDurationSec: null,
          targetDistanceM: null,
          targetHrZone: null,
          targetPaceZone: null,
          targetPowerZone: null,
          targetValueMin: null,
          targetValueMax: null,
          targetFreeform: null,
          actualDurationSec: null,
          actualDistanceM: null,
          actualAverageHr: null,
          actualAveragePaceSecPerMeter: null,
          actualAveragePowerWatts: null,
          repeatCount: null,
          parentIntervalId: null,
          notes: null,
        );

        final companion = SessionIntervalMapper.toCompanion(interval);

        expect(companion.targetDurationSec.value, isNull);
        expect(companion.targetDistanceM.value, isNull);
        expect(companion.targetHrZone.value, isNull);
        expect(companion.targetPaceZone.value, isNull);
        expect(companion.targetPowerZone.value, isNull);
        expect(companion.targetValueMin.value, isNull);
        expect(companion.targetValueMax.value, isNull);
        expect(companion.targetFreeform.value, isNull);
        expect(companion.actualDurationSec.value, isNull);
        expect(companion.actualDistanceM.value, isNull);
        expect(companion.actualAverageHr.value, isNull);
        expect(companion.actualAveragePaceSecPerMeter.value, isNull);
        expect(companion.actualAveragePowerWatts.value, isNull);
        expect(companion.repeatCount.value, isNull);
        expect(companion.parentIntervalUuid.value, isNull);
        expect(companion.notes.value, isNull);
      });

      test('maps all IntervalIntent enum values correctly', () {
        for (final intent in IntervalIntent.values) {
          final interval = TestFixtures.createSessionInterval(intent: intent);
          final c = SessionIntervalMapper.toCompanion(interval);
          expect(c.intentType.value, equals(intent.index));
        }
      });

      test('maps all IntervalTargetKind enum values correctly', () {
        for (final kind in IntervalTargetKind.values) {
          final interval = TestFixtures.createSessionInterval(
            targetKind: kind,
          );
          final c = SessionIntervalMapper.toCompanion(interval);
          expect(c.targetKind.value, equals(kind.index));
        }
      });
    });
  });

  group('SessionSampleMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final sample = TestFixtures.createSessionSample(
          sessionId: 'cs-1',
          offsetSec: 120,
          lat: 37.7749,
          lng: -122.4194,
          altitudeM: 15.5,
          hr: 155,
          cadence: 90.0,
          powerW: 220.0,
          speedMps: 3.5,
          strokeRate: 28.0,
        );

        final companion = SessionSampleMapper.toCompanion(sample);

        expect(companion.sessionUuid.value, equals('cs-1'));
        expect(companion.offsetSec.value, equals(120));
        expect(companion.lat.value, equals(37.7749));
        expect(companion.lng.value, equals(-122.4194));
        expect(companion.altitudeM.value, equals(15.5));
        expect(companion.hr.value, equals(155));
        expect(companion.cadence.value, equals(90.0));
        expect(companion.powerW.value, equals(220.0));
        expect(companion.speedMps.value, equals(3.5));
        expect(companion.strokeRate.value, equals(28.0));
      });

      test('handles null optional fields', () {
        final sample = TestFixtures.createSessionSample(
          lat: null,
          lng: null,
          altitudeM: null,
          hr: null,
          cadence: null,
          powerW: null,
          speedMps: null,
          strokeRate: null,
        );

        final companion = SessionSampleMapper.toCompanion(sample);

        expect(companion.lat.value, isNull);
        expect(companion.lng.value, isNull);
        expect(companion.altitudeM.value, isNull);
        expect(companion.hr.value, isNull);
        expect(companion.cadence.value, isNull);
        expect(companion.powerW.value, isNull);
        expect(companion.speedMps.value, isNull);
        expect(companion.strokeRate.value, isNull);
      });
    });
  });

  group('SportZoneMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final now = DateTime(2024, 6, 15);
        final zone = TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.bike,
          zoneNumber: 3,
          minValue: 150.0,
          maxValue: 170.0,
          unit: 'watts',
          ownerUuid: 'owner-1',
          createdAt: now,
        );

        final companion = SportZoneMapper.toCompanion(zone);

        expect(companion.uuid.value, equals('z1'));
        expect(companion.sport.value, equals(Sport.bike.index));
        expect(companion.zoneNumber.value, equals(3));
        expect(companion.minValue.value, equals(150.0));
        expect(companion.maxValue.value, equals(170.0));
        expect(companion.unit.value, equals('watts'));
        expect(companion.ownerUuid.value, equals('owner-1'));
        expect(companion.createdAt.value, equals(now));
      });

      test('handles null ownerUuid', () {
        final zone = TestFixtures.createSportZone(ownerUuid: null);
        final companion = SportZoneMapper.toCompanion(zone);
        expect(companion.ownerUuid.value, isNull);
      });

      test('maps all Sport enum values correctly', () {
        for (final sport in Sport.values) {
          final zone = TestFixtures.createSportZone(sport: sport);
          final c = SportZoneMapper.toCompanion(zone);
          expect(c.sport.value, equals(sport.index));
        }
      });
    });
  });

  group('CardioFeedbackMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final now = DateTime(2024, 6, 15);
        final feedback = TestFixtures.createCardioFeedback(
          rpe: 8,
          breathing: 2,
          giComfort: 4,
          weather: 'Rainy',
          notes: 'Tough run in rain',
          timestamp: now,
          creatorUuid: 'creator-1',
          ownerUuid: 'owner-1',
        );

        final companion = CardioFeedbackMapper.toCompanion('cs-1', feedback);

        expect(companion.sessionUuid.value, equals('cs-1'));
        expect(companion.rpe.value, equals(8));
        expect(companion.breathing.value, equals(2));
        expect(companion.giComfort.value, equals(4));
        expect(companion.weather.value, equals('Rainy'));
        expect(companion.notes.value, equals('Tough run in rain'));
        expect(companion.timestamp.value, equals(now));
        expect(companion.creatorUuid.value, equals('creator-1'));
        expect(companion.ownerUuid.value, equals('owner-1'));
      });

      test('handles all null optional fields', () {
        // Construct directly to avoid fixture's DateTime.now() default
        const feedback = CardioFeedback();

        final companion = CardioFeedbackMapper.toCompanion('cs-1', feedback);

        expect(companion.rpe.value, isNull);
        expect(companion.breathing.value, isNull);
        expect(companion.giComfort.value, isNull);
        expect(companion.weather.value, isNull);
        expect(companion.notes.value, isNull);
        expect(companion.timestamp.value, isNull);
        expect(companion.creatorUuid.value, isNull);
        expect(companion.ownerUuid.value, isNull);
      });
    });
  });

  group('CyclePeriodMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final period = TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: 'cycle-1',
          periodNumber: 3,
          phase: TrainingPhase.build,
          notes: 'Build phase',
          creatorUuid: 'creator-1',
          ownerUuid: 'owner-1',
        );

        final companion = CyclePeriodMapper.toCompanion(period);

        expect(companion.uuid.value, equals('p1'));
        expect(companion.trainingCycleUuid.value, equals('cycle-1'));
        expect(companion.periodNumber.value, equals(3));
        expect(companion.phase.value, equals(TrainingPhase.build.index));
        expect(companion.notes.value, equals('Build phase'));
        expect(companion.creatorUuid.value, equals('creator-1'));
        expect(companion.ownerUuid.value, equals('owner-1'));
      });

      test('handles null phase for strength cycles', () {
        final period = TestFixtures.createCyclePeriod(phase: null);
        final companion = CyclePeriodMapper.toCompanion(period);
        expect(companion.phase.value, isNull);
      });

      test('handles null optional fields', () {
        final period = TestFixtures.createCyclePeriod(
          notes: null,
          creatorUuid: null,
          ownerUuid: null,
        );

        final companion = CyclePeriodMapper.toCompanion(period);

        expect(companion.notes.value, isNull);
        expect(companion.creatorUuid.value, isNull);
        expect(companion.ownerUuid.value, isNull);
      });

      test('maps all TrainingPhase enum values correctly', () {
        for (final phase in TrainingPhase.values) {
          final period = TestFixtures.createCyclePeriod(phase: phase);
          final c = CyclePeriodMapper.toCompanion(period);
          expect(c.phase.value, equals(phase.index));
        }
      });
    });
  });

  group('Enum index round-trip consistency', () {
    test('all Sport indices are valid', () {
      for (var i = 0; i < Sport.values.length; i++) {
        expect(Sport.values[i].index, equals(i));
      }
    });

    test('all SessionSource indices are valid', () {
      for (var i = 0; i < SessionSource.values.length; i++) {
        expect(SessionSource.values[i].index, equals(i));
      }
    });

    test('all StrokeType indices are valid', () {
      for (var i = 0; i < StrokeType.values.length; i++) {
        expect(StrokeType.values[i].index, equals(i));
      }
    });

    test('all IntervalIntent indices are valid', () {
      for (var i = 0; i < IntervalIntent.values.length; i++) {
        expect(IntervalIntent.values[i].index, equals(i));
      }
    });

    test('all IntervalTargetKind indices are valid', () {
      for (var i = 0; i < IntervalTargetKind.values.length; i++) {
        expect(IntervalTargetKind.values[i].index, equals(i));
      }
    });

    test('all TrainingPhase indices are valid', () {
      for (var i = 0; i < TrainingPhase.values.length; i++) {
        expect(TrainingPhase.values[i].index, equals(i));
      }
    });
  });
}
