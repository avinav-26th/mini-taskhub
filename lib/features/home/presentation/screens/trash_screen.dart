// [1] VERSION: 3.0.0 - Stable Trash Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/data/task_repository.dart';
import '../../../tasks/domain/task_model.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';

// Independent provider to fetch deleted items
final trashListProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  return repo.fetchDeletedTasks();
});

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashListProvider);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Trash Bin", style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: trashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text("Trash is empty", style: TextStyle(color: textColor?.withValues(alpha: 0.5))),
              ],
            ));
          }

          return ListView.builder(
            itemCount: tasks.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(task.title, style: TextStyle(decoration: TextDecoration.lineThrough, color: textColor)),
                  subtitle: const Text("Deleted"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Restore
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () async {
                          await ref.read(taskRepositoryProvider).restoreTask(task.id);
                          // Refresh Trash List
                          // ignore: unused_result
                          ref.refresh(trashListProvider);
                          // Refresh Main Dashboard
                          ref.read(taskListProvider.notifier).loadTasks();
                        },
                      ),
                      // Delete Forever
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () async {
                          await ref.read(taskRepositoryProvider).permanentlyDeleteTask(task.id);
                          // ignore: unused_result
                          ref.refresh(trashListProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}