import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/presentation/widgets/cardio/sport_chip.dart';

import '../../../helpers/test_widget_wrapper.dart';

void main() {
  group('SportChip', () {
    testWidgets('renders icon for each sport', (tester) async {
      for (final sport in Sport.values) {
        await tester.pumpWidget(
          wrapForTest(
            SportChip(sport: sport, onTap: () {}),
          ),
        );

        expect(find.byIcon(sport.icon), findsOneWidget);
      }
    });

    testWidgets('shows tooltip with sport display name', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          SportChip(sport: Sport.run, onTap: () {}),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'Run',
        ),
        findsOneWidget,
      );
    });

    testWidgets('invokes onTap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapForTest(
          SportChip(sport: Sport.run, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(SportChip));
      expect(tapped, isTrue);
    });

    testWidgets('selected state changes appearance', (tester) async {
      // Unselected
      await tester.pumpWidget(
        wrapForTest(
          SportChip(sport: Sport.run, onTap: () {}),
        ),
      );
      final unselected = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // Selected
      await tester.pumpWidget(
        wrapForTest(
          SportChip(sport: Sport.run, selected: true, onTap: () {}),
        ),
      );
      final selected = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // They should have different decorations
      expect(
        (unselected.decoration as BoxDecoration).color,
        isNot(equals((selected.decoration as BoxDecoration).color)),
      );
    });
  });
}
