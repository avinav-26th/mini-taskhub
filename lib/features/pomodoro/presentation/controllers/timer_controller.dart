// [1] VERSION: 2.0.0 - Timer Controller with Editable Duration
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

// State Class
class TimerState {
  final int timeLeft; // in seconds
  final bool isRunning;
  final int initialDuration; // We need to track this to reset correctly

  TimerState({
    required this.timeLeft,
    required this.isRunning,
    required this.initialDuration
  });
}

// Provider
final timerProvider = StateNotifierProvider.autoDispose<TimerController, TimerState>((ref) {
  return TimerController();
});

class TimerController extends StateNotifier<TimerState> {
  Timer? _timer;

  // Default: 25 minutes
  TimerController() : super(TimerState(timeLeft: 1500, isRunning: false, initialDuration: 1500));

  void setDuration(int minutes) {
    _timer?.cancel();
    final seconds = minutes * 60;
    state = TimerState(timeLeft: seconds, isRunning: false, initialDuration: seconds);
  }

  void startTimer({Function? onFinished}) {
    if (state.isRunning) return;

    state = TimerState(timeLeft: state.timeLeft, isRunning: true, initialDuration: state.initialDuration);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = TimerState(
            timeLeft: state.timeLeft - 1,
            isRunning: true,
            initialDuration: state.initialDuration
        );
      } else {
        stopTimer();
        if (onFinished != null) onFinished();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = TimerState(timeLeft: state.timeLeft, isRunning: false, initialDuration: state.initialDuration);
  }

  void stopTimer() {
    _timer?.cancel();
    state = TimerState(timeLeft: 0, isRunning: false, initialDuration: state.initialDuration);
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
}