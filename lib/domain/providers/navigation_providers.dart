import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab indices for HomeScreen
class HomeTab {
  static const int workout = 0;
  static const int trainingCycles = 1;
  static const int exercises = 2;
  static const int calendar = 3;
  static const int more = 4;
}

/// Notifier for managing the selected tab index in the HomeScreen
class HomeTabIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return HomeTab.workout; // Default to workout tab
  }

  void setTab(int index) {
    state = index;
  }
}

/// Provider for managing the selected tab index in the HomeScreen
final homeTabIndexProvider = NotifierProvider<HomeTabIndexNotifier, int>(() {
  return HomeTabIndexNotifier();
});
