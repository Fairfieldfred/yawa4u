import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/models/cardio_detail.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/presentation/widgets/cardio/cardio_session_card.dart';

/// Covers the render paths in [CardioSessionCard]:
///   * Planned (incomplete) — target metrics + "Log session" button.
///   * Completed user-logged — hero metrics + "Add feedback" button.
///   * Completed imported (external source) — adds a source pill.
///   * Skipped — muted "Skipped" footer.
///
/// Also covers the swim variant's pool-specific metrics and the
/// overflow menu items (notes, move, replace, skip, delete).
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  CardioSession plannedRun() => CardioSession(
    id: 'planned-1',
    trainingCycleId: 'cycle-1',
    source: SessionSource.userPlanned,
    status: WorkoutStatus.incomplete,
    sport: Sport.run,
    label: 'Tempo run',
    scheduledDate: DateTime(2026, 4, 22, 7),
    detail: const CardioDetail(
      plannedDistanceM: 5000,
      plannedDurationSec: 1800,
    ),
  );

  CardioSession completedRunFromStrava() => CardioSession(
    id: 'completed-1',
    trainingCycleId: null,
    source: SessionSource.strava,
    status: WorkoutStatus.completed,
    sport: Sport.run,
    label: 'Morning loop',
    completedDate: DateTime(2026, 4, 22, 7, 30),
    externalId: 'strava-12345',
    detail: const CardioDetail(
      actualDistanceM: 5200,
      actualDurationSec: 1874,
      averagePaceSecPerMeter: 0.36,
      averageHr: 155,
      maxHr: 172,
      elevationGainM: 45,
    ),
  );

  CardioSession completedSwimUserLogged() => CardioSession(
    id: 'swim-1',
    trainingCycleId: 'cycle-1',
    source: SessionSource.userLogged,
    status: WorkoutStatus.completed,
    sport: Sport.swim,
    label: 'Technique day',
    completedDate: DateTime(2026, 4, 22, 18),
    detail: const CardioDetail(
      actualDistanceM: 1200,
      actualDurationSec: 1710,
      swolf: 32,
      lapCount: 30,
      poolLengthM: 25,
      strokeType: StrokeType.freestyle,
    ),
  );

  CardioSession skippedRun() => CardioSession(
    id: 'skipped-1',
    trainingCycleId: 'cycle-1',
    source: SessionSource.userPlanned,
    status: WorkoutStatus.skipped,
    sport: Sport.run,
    label: 'Easy jog',
    scheduledDate: DateTime(2026, 4, 22, 7),
    detail: const CardioDetail(
      plannedDistanceM: 3000,
      plannedDurationSec: 1200,
    ),
  );

  // ---------------------------------------------------------------------------
  // Render paths
  // ---------------------------------------------------------------------------

  testWidgets('planned run renders target + Log session primary button', (tester) async {
    await tester.pumpWidget(wrap(CardioSessionCard(session: plannedRun())));
    await tester.pump();

    expect(find.text('Tempo run'), findsOneWidget);
    expect(find.text('RUN'), findsOneWidget);
    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('Log session'), findsOneWidget);
    // Run defaults to imperial per `OnboardingService._sportDefaults`, so
    // 5000 m renders as "3.11 mi" alongside the 30:00 duration in a single
    // "distance · duration" line.
    expect(find.textContaining('mi'), findsOneWidget);
    expect(find.textContaining('30:00'), findsOneWidget);
    // Planned → no "Completed" status.
    expect(find.text('Completed'), findsNothing);
  });

  testWidgets('completed Strava run shows source pill + completion status', (tester) async {
    await tester.pumpWidget(
      wrap(CardioSessionCard(session: completedRunFromStrava())),
    );
    await tester.pump();

    expect(find.text('Morning loop'), findsOneWidget);
    expect(find.text('Strava'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Distance'.toUpperCase()), findsOneWidget);
    expect(find.text('Duration'.toUpperCase()), findsOneWidget);
    // Hero row should show HR sub-metrics too.
    expect(find.textContaining('155'), findsOneWidget);
    expect(find.textContaining('172'), findsOneWidget);
    expect(find.textContaining('45'), findsOneWidget);
    // No "Log session" — this one is already done.
    expect(find.text('Log session'), findsNothing);
  });

  testWidgets('completed swim shows pool / SWOLF / stroke metrics', (tester) async {
    await tester.pumpWidget(
      wrap(CardioSessionCard(session: completedSwimUserLogged())),
    );
    await tester.pump();

    expect(find.text('Technique day'), findsOneWidget);
    expect(find.text('SWIM'), findsOneWidget);
    // SWOLF should appear as a hero metric.
    expect(find.text('SWOLF'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    // Lap count + pool length + stroke type in the sub-metrics row.
    expect(find.textContaining('30 laps'), findsOneWidget);
    expect(find.textContaining('Freestyle'), findsOneWidget);
    // Swim distance uses meters, not km.
    expect(find.textContaining('1200 m'), findsOneWidget);
    // User-logged → no source pill.
    expect(find.text('Logged'), findsNothing);
  });

  testWidgets('skipped session shows Skipped footer', (tester) async {
    await tester.pumpWidget(wrap(CardioSessionCard(session: skippedRun())));
    await tester.pump();

    expect(find.text('Easy jog'), findsOneWidget);
    expect(find.text('Session skipped'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    // No Log session or Completed text.
    expect(find.text('Log session'), findsNothing);
    expect(find.text('Completed'), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // Footer callback invocations
  // ---------------------------------------------------------------------------

  testWidgets('primary button invokes onPrimary with session id', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onPrimary: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Log session'));
    await tester.pump();
    expect(captured, 'planned-1');
  });

  testWidgets('Add feedback button invokes onAddFeedback with session id', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: completedRunFromStrava(),
          callbacks: CardioSessionCardCallbacks(
            onAddFeedback: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Add feedback'));
    await tester.pump();
    expect(captured, 'completed-1');
  });

  testWidgets('planned footer has no Notes button (moved to overflow)', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onAddNote: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Notes button should NOT appear in the footer.
    final footerNotes = find.widgetWithText(TextButton, 'Notes');
    expect(footerNotes, findsNothing);
  });

  // ---------------------------------------------------------------------------
  // Overflow menu visibility
  // ---------------------------------------------------------------------------

  testWidgets('overflow menu is hidden when no menu callbacks are provided', (tester) async {
    await tester.pumpWidget(wrap(CardioSessionCard(session: plannedRun())));
    await tester.pump();
    // With zero callbacks, the PopupMenuButton should not render.
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('overflow menu renders when at least one menu callback is set', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Overflow menu items
  // ---------------------------------------------------------------------------

  testWidgets('overflow menu shows all items for a planned session', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          isFirstInDayList: false,
          isLastInDayList: false,
          callbacks: CardioSessionCardCallbacks(
            onAddNote: (_) {},
            onMoveUp: (_) {},
            onMoveDown: (_) {},
            onReplace: (_) {},
            onSkip: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Open the menu.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('SESSION'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Move up'), findsOneWidget);
    expect(find.text('Move down'), findsOneWidget);
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Skip session'), findsOneWidget);
    expect(find.text('Delete session'), findsOneWidget);
  });

  testWidgets('move up disabled when isFirstInDayList', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          isFirstInDayList: true,
          isLastInDayList: false,
          callbacks: CardioSessionCardCallbacks(
            onMoveUp: (id) => captured = id,
            onMoveDown: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "Move up" — should be disabled (no callback invocation).
    await tester.tap(find.text('Move up'));
    await tester.pumpAndSettle();
    expect(captured, isNull);
  });

  testWidgets('move down disabled when isLastInDayList', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          isFirstInDayList: false,
          isLastInDayList: true,
          callbacks: CardioSessionCardCallbacks(
            onMoveUp: (_) {},
            onMoveDown: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "Move down" — should be disabled.
    await tester.tap(find.text('Move down'));
    await tester.pumpAndSettle();
    expect(captured, isNull);
  });

  testWidgets('skip and replace disabled for completed external session', (tester) async {
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: completedRunFromStrava(),
          callbacks: CardioSessionCardCallbacks(
            onReplace: (_) {},
            onSkip: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Both items should be present but disabled.
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Skip session'), findsOneWidget);

    // Verify they are disabled via the PopupMenuItem widget.
    final replaceItem = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Replace'),
    );
    expect(replaceItem.enabled, isFalse);

    final skipItem = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Skip session'),
    );
    expect(skipItem.enabled, isFalse);
  });

  testWidgets('delete callback invoked from overflow menu', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onDelete: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete session'));
    await tester.pumpAndSettle();
    expect(captured, 'planned-1');
  });

  testWidgets('notes callback invoked from overflow menu', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onAddNote: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(captured, 'planned-1');
  });

  testWidgets('skip callback invoked for planned session', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onSkip: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip session'));
    await tester.pumpAndSettle();
    expect(captured, 'planned-1');
  });

  testWidgets('replace callback invoked for planned session', (tester) async {
    String? captured;
    await tester.pumpWidget(
      wrap(
        CardioSessionCard(
          session: plannedRun(),
          callbacks: CardioSessionCardCallbacks(
            onReplace: (id) => captured = id,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(captured, 'planned-1');
  });
}
