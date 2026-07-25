import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/providers/cloud_backup_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/app_icon_widget.dart';

/// Main home shell with bottom navigation (mobile/tablet) or NavigationRail
/// sidebar (desktop >= 1200dp).
///
/// The five tabs are [StatefulShellRoute] branches ('/', '/cycles',
/// '/exercises', '/calendar', '/more'); [navigationShell] preserves each
/// branch's state and tab switches are ordinary router navigation, so every
/// tab is deep-linkable.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops that branch back to its root —
      // the conventional bottom-nav behavior.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kicks off the silent app-launch cloud backup check exactly once per
    // session (the provider body runs once per container).
    ref.watch(autoCloudBackupTriggerProvider);

    final selectedIndex = navigationShell.currentIndex;
    final cycleTermPlural = ref.watch(trainingCycleTermPluralProvider);
    final isDesktop = context.isDesktop;

    // Global keyboard shortcuts for tab switching (Ctrl+1..5)
    return CallbackShortcuts(
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
          context: context,
          isDesktop: isDesktop,
          selectedIndex: selectedIndex,
          cycleTermPlural: cycleTermPlural,
        ),
      ),
    );
  }

  Widget _buildLayout({
    required BuildContext context,
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
                  icon: const Icon(Icons.event_note),
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
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
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
            icon: const Icon(Icons.event_note),
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
