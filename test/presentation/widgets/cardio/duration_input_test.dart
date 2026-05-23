import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/presentation/widgets/cardio/duration_input.dart';

import '../../../helpers/test_widget_wrapper.dart';

void main() {
  group('DurationInput', () {
    testWidgets('shows timer icon', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DurationInput(initialSeconds: null, onChanged: (_) {}),
        ),
      );

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DurationInput(initialSeconds: null, onChanged: (_) {}),
        ),
      );

      expect(find.text('00:30:00'), findsOneWidget);
    });

    testWidgets('displays custom label', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DurationInput(
            initialSeconds: null,
            onChanged: (_) {},
            label: 'Planned Duration',
          ),
        ),
      );

      expect(find.text('Planned Duration'), findsOneWidget);
    });

    testWidgets('fires onChanged with seconds for valid input', (tester) async {
      int? received;

      await tester.pumpWidget(
        wrapForTest(
          DurationInput(
            initialSeconds: null,
            onChanged: (v) => received = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '1:30');
      expect(received, equals(90));
    });

    testWidgets('fires onChanged with null on empty input', (tester) async {
      int? received = 999;

      await tester.pumpWidget(
        wrapForTest(
          DurationInput(
            initialSeconds: 60,
            onChanged: (v) => received = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      expect(received, isNull);
    });

    testWidgets('prefills from initialSeconds', (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          DurationInput(
            initialSeconds: 3661, // 1:01:01
            onChanged: (_) {},
          ),
        ),
      );

      // The controller should show the formatted time
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, contains('1:01:01'));
    });
  });
}
