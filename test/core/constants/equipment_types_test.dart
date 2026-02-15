import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';

void main() {
  group('EquipmentTypes.parse', () {
    test('parses exact display names', () {
      expect(EquipmentTypes.parse('Barbell'), equals(EquipmentType.barbell));
      expect(EquipmentTypes.parse('Dumbbell'), equals(EquipmentType.dumbbell));
      expect(EquipmentTypes.parse('Cable'), equals(EquipmentType.cable));
      expect(EquipmentTypes.parse('Machine'), equals(EquipmentType.machine));
      expect(EquipmentTypes.parse('Kettlebell'), equals(EquipmentType.kettlebell));
      expect(EquipmentTypes.parse('Freemotion'), equals(EquipmentType.freemotion));
    });

    test('is case insensitive', () {
      expect(EquipmentTypes.parse('barbell'), equals(EquipmentType.barbell));
      expect(EquipmentTypes.parse('BARBELL'), equals(EquipmentType.barbell));
      expect(EquipmentTypes.parse('Barbell'), equals(EquipmentType.barbell));
    });

    test('handles compound names', () {
      expect(
        EquipmentTypes.parse('Bodyweight Only'),
        equals(EquipmentType.bodyweightOnly),
      );
      expect(
        EquipmentTypes.parse('Bodyweight Loadable'),
        equals(EquipmentType.bodyweightLoadable),
      );
      expect(
        EquipmentTypes.parse('Machine Assistance'),
        equals(EquipmentType.machineAssistance),
      );
      expect(
        EquipmentTypes.parse('Smith Machine'),
        equals(EquipmentType.smithMachine),
      );
      expect(
        EquipmentTypes.parse('Band Assistance'),
        equals(EquipmentType.bandAssistance),
      );
    });

    test('handles variation shorthands', () {
      expect(
        EquipmentTypes.parse('bodyweight'),
        equals(EquipmentType.bodyweightOnly),
      );
      expect(
        EquipmentTypes.parse('smith'),
        equals(EquipmentType.smithMachine),
      );
      expect(
        EquipmentTypes.parse('band'),
        equals(EquipmentType.bandAssistance),
      );
    });

    test('trims whitespace', () {
      expect(EquipmentTypes.parse('  Barbell  '), equals(EquipmentType.barbell));
      expect(
        EquipmentTypes.parse('  Smith Machine  '),
        equals(EquipmentType.smithMachine),
      );
    });

    test('returns null for unknown types', () {
      expect(EquipmentTypes.parse('Unknown'), isNull);
      expect(EquipmentTypes.parse(''), isNull);
      expect(EquipmentTypes.parse('yoga mat'), isNull);
    });
  });

  group('EquipmentType.displayName', () {
    test('returns human-readable names for all types', () {
      for (final type in EquipmentType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('specific display names are correct', () {
      expect(EquipmentType.barbell.displayName, equals('Barbell'));
      expect(EquipmentType.bodyweightOnly.displayName, equals('Bodyweight Only'));
      expect(EquipmentType.smithMachine.displayName, equals('Smith Machine'));
    });
  });

  group('EquipmentType.displayNameUppercase', () {
    test('returns uppercase display names', () {
      expect(EquipmentType.barbell.displayNameUppercase, equals('BARBELL'));
      expect(
        EquipmentType.bodyweightOnly.displayNameUppercase,
        equals('BODYWEIGHT ONLY'),
      );
    });
  });

  group('EquipmentType.isBodyweightLoadable', () {
    test('returns true only for bodyweightLoadable', () {
      expect(EquipmentType.bodyweightLoadable.isBodyweightLoadable, isTrue);
      expect(EquipmentType.barbell.isBodyweightLoadable, isFalse);
      expect(EquipmentType.bodyweightOnly.isBodyweightLoadable, isFalse);
    });
  });

  group('EquipmentTypes.sorted', () {
    test('returns all types sorted alphabetically', () {
      final sorted = EquipmentTypes.sorted;
      expect(sorted.length, equals(EquipmentType.values.length));
      for (var i = 1; i < sorted.length; i++) {
        expect(
          sorted[i - 1].displayName.compareTo(sorted[i].displayName),
          lessThanOrEqualTo(0),
        );
      }
    });
  });
}
