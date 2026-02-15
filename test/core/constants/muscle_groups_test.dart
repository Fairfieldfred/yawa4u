import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';

void main() {
  group('MuscleGroups.parse', () {
    test('parses exact display names', () {
      expect(MuscleGroups.parse('Chest'), equals(MuscleGroup.chest));
      expect(MuscleGroups.parse('Back'), equals(MuscleGroup.back));
      expect(MuscleGroups.parse('Shoulders'), equals(MuscleGroup.shoulders));
      expect(MuscleGroups.parse('Biceps'), equals(MuscleGroup.biceps));
      expect(MuscleGroups.parse('Triceps'), equals(MuscleGroup.triceps));
      expect(MuscleGroups.parse('Quads'), equals(MuscleGroup.quads));
      expect(MuscleGroups.parse('Hamstrings'), equals(MuscleGroup.hamstrings));
      expect(MuscleGroups.parse('Glutes'), equals(MuscleGroup.glutes));
      expect(MuscleGroups.parse('Calves'), equals(MuscleGroup.calves));
      expect(MuscleGroups.parse('Traps'), equals(MuscleGroup.traps));
      expect(MuscleGroups.parse('Forearms'), equals(MuscleGroup.forearms));
      expect(MuscleGroups.parse('Abs'), equals(MuscleGroup.abs));
    });

    test('parses newer muscle groups', () {
      expect(MuscleGroups.parse('Full Body'), equals(MuscleGroup.fullBody));
      expect(MuscleGroups.parse('Adductors'), equals(MuscleGroup.adductors));
      expect(MuscleGroups.parse('Core'), equals(MuscleGroup.core));
      expect(MuscleGroups.parse('Grip'), equals(MuscleGroup.grip));
      expect(MuscleGroups.parse('Obliques'), equals(MuscleGroup.obliques));
      expect(MuscleGroups.parse('Legs'), equals(MuscleGroup.legs));
      expect(MuscleGroups.parse('Hips'), equals(MuscleGroup.hips));
    });

    test('is case insensitive', () {
      expect(MuscleGroups.parse('chest'), equals(MuscleGroup.chest));
      expect(MuscleGroups.parse('CHEST'), equals(MuscleGroup.chest));
      expect(MuscleGroups.parse('Chest'), equals(MuscleGroup.chest));
      expect(MuscleGroups.parse('full body'), equals(MuscleGroup.fullBody));
    });

    test('trims whitespace', () {
      expect(MuscleGroups.parse('  Chest  '), equals(MuscleGroup.chest));
      expect(
        MuscleGroups.parse('  Full Body  '),
        equals(MuscleGroup.fullBody),
      );
    });

    test('returns null for unknown groups', () {
      expect(MuscleGroups.parse('Unknown'), isNull);
      expect(MuscleGroups.parse(''), isNull);
      expect(MuscleGroups.parse('Neck'), isNull);
    });
  });

  group('MuscleGroup.displayName', () {
    test('returns human-readable names for all groups', () {
      for (final group in MuscleGroup.values) {
        expect(group.displayName, isNotEmpty);
      }
    });

    test('specific display names are correct', () {
      expect(MuscleGroup.chest.displayName, equals('Chest'));
      expect(MuscleGroup.fullBody.displayName, equals('Full Body'));
      expect(MuscleGroup.hamstrings.displayName, equals('Hamstrings'));
    });
  });

  group('MuscleGroup.color', () {
    test('returns a color for every muscle group', () {
      for (final group in MuscleGroup.values) {
        expect(group.color, isNotNull);
      }
    });

    test('push muscles share the same color', () {
      expect(MuscleGroup.chest.color, equals(MuscleGroup.triceps.color));
      expect(MuscleGroup.chest.color, equals(MuscleGroup.shoulders.color));
    });

    test('pull muscles share the same color', () {
      expect(MuscleGroup.back.color, equals(MuscleGroup.biceps.color));
    });

    test('leg muscles share the same color', () {
      expect(MuscleGroup.quads.color, equals(MuscleGroup.hamstrings.color));
      expect(MuscleGroup.quads.color, equals(MuscleGroup.glutes.color));
      expect(MuscleGroup.quads.color, equals(MuscleGroup.calves.color));
    });
  });

  group('MuscleGroups.sorted', () {
    test('returns all groups sorted alphabetically', () {
      final sorted = MuscleGroups.sorted;
      expect(sorted.length, equals(MuscleGroup.values.length));
      for (var i = 1; i < sorted.length; i++) {
        expect(
          sorted[i - 1].displayName.compareTo(sorted[i].displayName),
          lessThanOrEqualTo(0),
        );
      }
    });
  });
}
