import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../widgets/app_icon_widget.dart';
import 'calendar_screen.dart';
import 'cycle_list_screen.dart';
import 'exercises_screen.dart';
import 'more_screen.dart';
import 'workout_screen.dart';

/// Main home screen with bottom navigation (mobile/tablet)
/// or NavigationRail sidebar (desktop >= 1200dp).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Tracks which tabs have been visited so we can lazily build them.
  final Set<int> _visitedTabs = {0}; // Workout tab starts visited

  static const _screenBuilders = [
    WorkoutHomeScreen.new,
    CycleListScreen.new,
    ExercisesHomeScreen.new,
    CalendarScreen.new,
    MoreScreen.new,
  ];

  void _onItemTapped(int index) {
    setState(() => _visitedTabs.add(index));
    ref.read(homeTabIndexProvider.notifier).setTab(index);
  }

  Widget _buildScreenStack(int selectedIndex) {
    return IndexedStack(
      index: selectedIndex,
      children: List.generate(_screenBuilders.length, (i) {
        if (_visitedTabs.contains(i)) {
          return _screenBuilders[i]();
        }
        return const SizedBox.shrink();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(homeTabIndexProvider);
    final cycleTermPlural = ref.watch(trainingCycleTermPluralProvider);
    final isDesktop = context.isDesktop;

    // Global keyboard shortcuts for tab switching (Ctrl+1..5)
    final body = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true):
            () => _onItemTapped(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true):
            () => _onItemTapped(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true):
            () => _onItemTapped(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true):
            () => _onItemTapped(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true):
            () => _onItemTapped(4),
      },
      child: Focus(
        autofocus: true,
        child: _buildLayout(
          isDesktop: isDesktop,
          selectedIndex: selectedIndex,
          cycleTermPlural: cycleTermPlural,
        ),
      ),
    );

    return body;
  }

  Widget _buildLayout({
    required bool isDesktop,
    required int selectedIndex,
    required String cycleTermPlural,
  }) {
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: AppIconWidget(),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.play_circle_fill),
                  label: Text('Workout'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.analytics),
                  label: Text(cycleTermPlural),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.fitness_center),
                  label: Text('Exercises'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  label: Text('Calendar'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.more_horiz),
                  label: Text('More'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _buildScreenStack(selectedIndex)),
          ],
        ),
      );
    }

    return Scaffold(
      body: _buildScreenStack(selectedIndex),
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
