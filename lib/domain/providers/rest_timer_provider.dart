import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';

/// State for the rest timer between sets.
class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;

  /// ID of the exercise that triggered this timer (for editing rest duration).
  final String? exerciseId;

  /// ID of the workout containing the exercise.
  final String? workoutId;

  const RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.exerciseId,
    this.workoutId,
  });

  double get progress => totalSeconds > 0 ? remainingSeconds / totalSeconds : 0;

  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isPaused,
    String? exerciseId,
    String? workoutId,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutId: workoutId ?? this.workoutId,
    );
  }
}

/// Default rest durations in seconds per set type.
int defaultRestSeconds(SetType setType) {
  return switch (setType) {
    SetType.regular => 60,
    SetType.myorep => 10,
    SetType.myorepMatch => 10,
    SetType.maxReps => 90,
    SetType.endWithPartials => 60,
    SetType.dropSet => 0,
  };
}

/// Manages the rest timer countdown between sets.
class RestTimerNotifier extends Notifier<RestTimerState> {
  Timer? _timer;

  @override
  RestTimerState build() => const RestTimerState();

  /// Start a countdown for the given set type.
  /// If [exerciseRestSeconds] is provided, it overrides the default.
  /// Optionally stores [exerciseId] and [workoutId] so the timer banner
  /// can open the rest-timer settings for the triggering exercise.
  void start(
    SetType setType, {
    int? exerciseRestSeconds,
    String? exerciseId,
    String? workoutId,
  }) {
    final seconds = exerciseRestSeconds ?? defaultRestSeconds(setType);
    if (seconds <= 0) return; // No rest for drop sets

    _timer?.cancel();
    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      exerciseId: exerciseId,
      workoutId: workoutId,
    );
    _startTicking();
  }

  /// Start with a custom duration in seconds.
  void startCustom(int seconds) {
    if (seconds <= 0) return;

    _timer?.cancel();
    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
    );
    _startTicking();
  }

  /// Pause the timer.
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  /// Resume a paused timer.
  void resume() {
    if (!state.isPaused || state.remainingSeconds <= 0) return;
    state = state.copyWith(isPaused: false);
    _startTicking();
  }

  /// Add 30 seconds to the current timer.
  void addTime() {
    final newRemaining = state.remainingSeconds + 30;
    final newTotal = state.totalSeconds + 30;
    state = state.copyWith(
      remainingSeconds: newRemaining,
      totalSeconds: newTotal,
    );
  }

  /// Cancel the timer and reset state.
  void cancel() {
    _timer?.cancel();
    state = const RestTimerState();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _timer?.cancel();
        state = const RestTimerState();
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }
}

/// Global rest timer provider.
final restTimerProvider = NotifierProvider<RestTimerNotifier, RestTimerState>(
  RestTimerNotifier.new,
);
