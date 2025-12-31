import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import 'calendar_screen.dart';
import 'cycle_list_screen.dart';
import 'exercises_screen.dart';
import 'more_screen.dart';
import 'workout_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<Widget> _screens = [
    WorkoutHomeScreen(),
    CycleListScreen(),
    ExercisesHomeScreen(),
    CalendarScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    ref.read(homeTabIndexProvider.notifier).setTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(homeTabIndexProvider);
    final cycleTermPlural = ref.watch(trainingCycleTermPluralProvider);

    return Scaffold(
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: cycleTermPlural,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
