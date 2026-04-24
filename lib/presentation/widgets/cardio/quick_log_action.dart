import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/sports.dart';
import '../../screens/cardio/sport_picker_sheet.dart';

/// AppBar action button that opens the sport picker and routes to the
/// cardio session creation screen.
///
/// Designed for non-Workout tabs (Stats, Exercises, Calendar, Cycle
/// list) so users can start logging a cardio session from anywhere.
/// The Workout tab uses its own pinned SportGrid instead.
///
/// Shows only cardio sports (run, bike, swim) because strength
/// session creation requires a workout/cycle context that secondary
/// screens don't have.
///
/// The created session is ad-hoc (`trainingCycleId: null`).
class QuickLogAction extends StatelessWidget {
  const QuickLogAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      tooltip: 'Log session',
      onPressed: () => _pickAndRoute(context),
    );
  }

  Future<void> _pickAndRoute(BuildContext context) async {
    final sport = await SportPickerSheet.show(
      context,
      title: 'Log session',
      choices: Sports.cardio,
    );
    if (sport == null || !context.mounted) return;

    context.push('/cardio-session/new?sport=${sport.name}');
  }
}
