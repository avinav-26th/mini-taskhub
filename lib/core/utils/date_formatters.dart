import 'package:intl/intl.dart';

class DateFormatters {
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(date.year, date.month, date.day);

    if (aDate == today) return 'Today';
    if (aDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (aDate == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return DateFormat('MMM d, y').format(date);
  }

  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}