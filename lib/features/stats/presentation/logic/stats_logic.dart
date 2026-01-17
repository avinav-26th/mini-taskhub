
import '../../../tasks/domain/task_model.dart';

class StatsLogic {
  static Map<String, dynamic> calculateSummary(List<Task> tasks) {
    if (tasks.isEmpty) {
      return {'total': 0, 'completed': 0, 'pending': 0, 'rate': 0};
    }

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final rate = (completed / total * 100).toInt();

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'rate': rate,
    };
  }

  static Map<int, int> calculateCategoryCounts(List<Task> tasks) {
    final Map<int, int> counts = {};
    for (var t in tasks) {
      if (t.categoryId != null) {
        counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1;
      }
    }
    return counts;
  }
}