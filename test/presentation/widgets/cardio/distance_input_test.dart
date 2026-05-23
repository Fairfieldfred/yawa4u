import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/presentation/widgets/cardio/distance_input.dart';

import '../../../helpers/test_widget_wrapper.dart';

void main() {
  group('DistanceInput', () {
    testWidgets('shows km suffix for metric run', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.metric,
            onChanged: (_) {},
            sport: Sport.run,
          ),
        ),
      );

      expect(find.text('km'), findsOneWidget);
    });

    testWidgets('shows mi suffix for imperial run', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.imperial,
            onChanged: (_) {},
            sport: Sport.run,
          ),
        ),
      );

      expect(find.text('mi'), findsOneWidget);
    });

    testWidgets('shows m suffix for metric swim', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.metric,
            onChanged: (_) {},
            sport: Sport.swim,
          ),
        ),
      );

      expect(find.text('m'), findsOneWidget);
    });

    testWidgets('shows yd suffix for imperial swim', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.imperial,
            onChanged: (_) {},
            sport: Sport.swim,
          ),
        ),
      );

      expect(find.text('yd'), findsOneWidget);
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.metric,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.straighten), findsOneWidget);
    });

    testWidgets('fires onChanged with meters on input', (tester) async {
      double? received;

      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: null,
            units: UnitSystem.metric,
            onChanged: (v) => received = v,
            sport: Sport.run,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '5');
      expect(received, isNotNull);
    });

    testWidgets('fires onChanged with null on empty input', (tester) async {
      double? received = 999;

      await tester.pumpWidget(
        wrapForTest(
          DistanceInput(
            initialMeters: 5000,
            units: UnitSystem.metric,
            onChanged: (v) => received = v,
            sport: Sport.run,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      expect(received, isNull);
    });
  });
}
