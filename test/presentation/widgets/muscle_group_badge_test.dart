import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/l10n/app_localizations.dart';
import 'package:yawa4u/presentation/widgets/muscle_group_badge.dart';

void main() {
  group('MuscleGroupBadge', () {
    testWidgets('renders primary muscle group name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                MuscleGroupBadge(muscleGroup: MuscleGroup.chest),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CHEST'), findsOneWidget);
    });

    testWidgets('renders primary and secondary when both provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                MuscleGroupBadge(
                  muscleGroup: MuscleGroup.chest,
                  secondaryMuscleGroup: MuscleGroup.triceps,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CHEST / TRICEPS'), findsOneWidget);
    });

    testWidgets('renders without secondary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                MuscleGroupBadge(muscleGroup: MuscleGroup.back),
              ],
            ),
          ),
        ),
      );

      expect(find.text('BACK'), findsOneWidget);
      expect(find.textContaining('/'), findsNothing);
    });

    testWidgets('compact constructor renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                MuscleGroupBadge.compact(muscleGroup: MuscleGroup.quads),
              ],
            ),
          ),
        ),
      );

      expect(find.text('QUADS'), findsOneWidget);
    });
  });
}
