// [1] VERSION: 1.0.0 - Pomodoro Controller
// UI segment: Timer State

import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// State Class
class TimerState {
  final int timeLeft; // in seconds
  final bool isRunning;
  final int initialDuration;

  TimerState({required this.timeLeft, required this.isRunning, required this.initialDuration});
}

// Provider
final timerProvider = StateNotifierProvider.autoDispose<TimerController, TimerState>((ref) {
  return TimerController();
});

class TimerController extends StateNotifier<TimerState> {
  Timer? _timer;

  // Default 25 minutes (1500 seconds)
  TimerController() : super(TimerState(timeLeft: 1500, isRunning: false, initialDuration: 1500));

  void startTimer({Function? onFinished}) {
    if (state.isRunning) return;

    state = TimerState(timeLeft: state.timeLeft, isRunning: true, initialDuration: state.initialDuration);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = TimerState(timeLeft: state.timeLeft - 1, isRunning: true, initialDuration: state.initialDuration);
      } else {
        // Timer Finished
        stopTimer();

        if (onFinished != null) onFinished();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = TimerState(timeLeft: state.timeLeft, isRunning: false, initialDuration: state.initialDuration);
  }

  void resetTimer() {
    _timer?.cancel();
    state = TimerState(timeLeft: state.initialDuration, isRunning: false, initialDuration: state.initialDuration);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void stopTimer() {
    _timer?.cancel();
    // Set state to 0 and not running
    state = TimerState(
        timeLeft: 0,
        isRunning: false,
        initialDuration: state.initialDuration
    );
  }
}