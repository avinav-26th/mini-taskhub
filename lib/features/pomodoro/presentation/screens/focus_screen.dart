import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/timer_controller.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final minutes = (timerState.timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerState.timeLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Colors.white24),
            const SizedBox(height: 40),
            Text(
              "$minutes:$seconds",
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w100,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(
                  icon: timerState.isRunning ? Icons.pause : Icons.play_arrow,
                  onTap: timerState.isRunning
                      ? ref.read(timerProvider.notifier).pauseTimer
                      : () => ref.read(timerProvider.notifier).startTimer(),
                ),
                const SizedBox(width: 30),
                _CircleButton(
                  icon: Icons.stop,
                  color: Colors.redAccent,
                  onTap: ref.read(timerProvider.notifier).stopTimer,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (timerState.isRunning)
              const Text("Stay Focused", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleButton({required this.icon, required this.onTap, this.color = const Color(0xFF4ECDC4)});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}