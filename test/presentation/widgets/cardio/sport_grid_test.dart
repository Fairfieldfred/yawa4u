import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/presentation/widgets/cardio/sport_grid.dart';

/// Covers [SportGrid]'s two variants + tap dispatch.
///
/// Compact variant: the pinned footer under the day's card list.
/// Expanded variant: the full-body empty-state on days with no
/// scheduled sessions.
void main() {
  Widget wrap(Widget child) {
    // SingleChildScrollView gives the expanded variant enough vertical
    // room — its intrinsic height (4 boxes @ childAspectRatio 1.15 +
    // header + subtitle ≈ 720 px) exceeds the default test viewport's
    // ~552 px body height. In production the expanded variant renders
    // as a full Scaffold body on empty-day screens and has the height
    // it needs.
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  testWidgets('compact variant renders ADD SESSION header + four boxes',
      (tester) async {
    await tester.pumpWidget(wrap(const SportGrid()));
    await tester.pump();

    expect(find.text('ADD SESSION'), findsOneWidget);
    expect(find.text('Lift'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Swim'), findsOneWidget);
  });

  testWidgets('expanded variant renders headline + subtitle + four boxes',
      (tester) async {
    await tester.pumpWidget(wrap(
      const SportGrid(variant: SportGridVariant.expanded),
    ));
    await tester.pump();

    expect(find.text('Ready to train?'), findsOneWidget);
    expect(
      find.text("Pick a sport to add today's session."),
      findsOneWidget,
    );
    // The compact "ADD SESSION" header is hidden in expanded mode.
    expect(find.text('ADD SESSION'), findsNothing);
    expect(find.text('Lift'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Swim'), findsOneWidget);
  });

  testWidgets('tapping Lift invokes both onTap(strength) and onLift',
      (tester) async {
    Sport? tappedSport;
    var liftCount = 0;

    await tester.pumpWidget(wrap(SportGrid(
      callbacks: SportGridCallbacks(
        onTap: (sport) => tappedSport = sport,
        onLift: () => liftCount++,
      ),
    )));
    await tester.pump();

    await tester.tap(find.text('Lift'));
    await tester.pump();

    expect(tappedSport, Sport.strength);
    expect(liftCount, 1);
  });

  testWidgets('tapping Run dispatches Sport.run to onTap and calls onRun',
      (tester) async {
    Sport? tappedSport;
    var runCount = 0;

    await tester.pumpWidget(wrap(SportGrid(
      callbacks: SportGridCallbacks(
        onTap: (sport) => tappedSport = sport,
        onRun: () => runCount++,
      ),
    )));
    await tester.pump();

    await tester.tap(find.text('Run'));
    await tester.pump();

    expect(tappedSport, Sport.run);
    expect(runCount, 1);
  });

  testWidgets('tapping Bike dispatches Sport.bike and calls onBike',
      (tester) async {
    Sport? tappedSport;
    var bikeCount = 0;

    await tester.pumpWidget(wrap(SportGrid(
      callbacks: SportGridCallbacks(
        onTap: (sport) => tappedSport = sport,
        onBike: () => bikeCount++,
      ),
    )));
    await tester.pump();

    await tester.tap(find.text('Bike'));
    await tester.pump();

    expect(tappedSport, Sport.bike);
    expect(bikeCount, 1);
  });

  testWidgets('tapping Swim dispatches Sport.swim and calls onSwim',
      (tester) async {
    Sport? tappedSport;
    var swimCount = 0;

    await tester.pumpWidget(wrap(SportGrid(
      callbacks: SportGridCallbacks(
        onTap: (sport) => tappedSport = sport,
        onSwim: () => swimCount++,
      ),
    )));
    await tester.pump();

    await tester.tap(find.text('Swim'));
    await tester.pump();

    expect(tappedSport, Sport.swim);
    expect(swimCount, 1);
  });

  testWidgets('null callbacks do not throw when a box is tapped',
      (tester) async {
    await tester.pumpWidget(wrap(const SportGrid()));
    await tester.pump();

    // No callbacks wired — tap should be a safe no-op.
    await tester.tap(find.text('Run'));
    await tester.pump();
    // Reaching this line without an exception is the assertion.
    expect(true, isTrue);
  });

  // Accessibility-label verification deferred to UX_REVIEW P2 #12
  // (touch targets + a11y pass). `Semantics(button: true, label: '...')`
  // is present on each box in the widget source, but
  // `find.bySemanticsLabel` interacts subtly with InkWell's built-in
  // tap semantics and warrants a dedicated testing approach.
}
