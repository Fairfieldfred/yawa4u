import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/presentation/widgets/cardio/sport_badge.dart';

import '../../../helpers/test_widget_wrapper.dart';

void main() {
  group('SportBadge', () {
    testWidgets('renders sport icon', (tester) async {
      await tester.pumpWidget(
        wrapForTest(SportBadge(sport: Sport.run)),
      );

      expect(find.byIcon(Sport.run.icon), findsOneWidget);
    });

    testWidgets('shows label by default', (tester) async {
      await tester.pumpWidget(
        wrapForTest(SportBadge(sport: Sport.bike)),
      );

      expect(find.text('Bike'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        wrapForTest(SportBadge(sport: Sport.bike, showLabel: false)),
      );

      expect(find.text('Bike'), findsNothing);
      expect(find.byIcon(Sport.bike.icon), findsOneWidget);
    });

    testWidgets('renders for all sport values', (tester) async {
      for (final sport in Sport.values) {
        await tester.pumpWidget(
          wrapForTest(SportBadge(sport: sport)),
        );

        expect(find.byIcon(sport.icon), findsOneWidget);
        expect(find.text(sport.displayName), findsOneWidget);
      }
    });
  });
}
