import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/providers/navigation_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/app_icon_widget.dart';
import '../calendar/calendar_screen.dart';
import '../training_cycles/cycle_list_screen.dart';
import '../exercises/exercises_screen.dart';
import '../more/more_screen.dart';
import '../workout/workout_screen.dart';

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

  /// Cached screen instances — created once per tab, reused on rebuilds.
  final Map<int, Widget> _builtScreens = {};

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
          return _builtScreens[i] ??= _screenBuilders[i]();
        }
        return const SizedBox.shrink();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(homeTabIndexProvider);
    _visitedTabs.add(selectedIndex);
    final cycleTermPlural = ref.watch(trainingCycleTermPluralProvider);
    final isDesktop = context.isDesktop;

    // Global keyboard shortcuts for tab switching (Ctrl+1..5)
    final body = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () => _onItemTapped(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () => _onItemTapped(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () => _onItemTapped(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () => _onItemTapped(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () => _onItemTapped(4),
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
    final l10n = AppLocalizations.of(context)!;

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
                NavigationRailDestination(
                  icon: const Icon(Icons.play_circle_fill),
                  label: Text(l10n.navSession),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.analytics),
                  label: Text(cycleTermPlural),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.fitness_center),
                  label: Text(l10n.navExercises),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(l10n.navCalendar),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.more_horiz),
                  label: Text(l10n.navMore),
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
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_circle_fill),
            label: l10n.navSession,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: cycleTermPlural,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: l10n.navExercises,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
