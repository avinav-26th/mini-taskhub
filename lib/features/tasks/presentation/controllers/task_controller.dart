// [1] VERSION: 3.0.0 - STABLE StateNotifier Controller
// UI segment: State Management
// BACKEND segment: Connects to TaskRepository

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/task_repository.dart';
import '../../domain/task_model.dart';

// 1. The Single Provider for everything (Data + Actions)
final taskListProvider = StateNotifierProvider<TaskListController, AsyncValue<List<Task>>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskListController(repository);
});

class TaskListController extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskListController(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  // 2. Load Tasks (Future based)
  Future<void> loadTasks() async {
    try {
      final tasks = await _repository.fetchTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 3. Add Task
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? categoryId,
  }) async {
    try {
      // 1. Send to DB
      final newTask = await _repository.addTask(
        title: title,
        description: description,
        dueDate: dueDate,
        categoryId: categoryId,
      );

      // 2. Update Local State (Prepend to list)
      state.whenData((tasks) {
        state = AsyncValue.data([newTask, ...tasks]);
      });
    } catch (e) {
      log('Error adding task: $e');
    }
  }

  // 4. Generic Update (The "Magic" Method for Edits, Stars, etc.)
  Future<void> updateTask(Task updatedTask) async {
    // 1. Optimistic Update: Update UI *immediately*
    final previousState = state;

    state.whenData((tasks) {
      final newTasks = tasks.map((t) {
        return t.id == updatedTask.id ? updatedTask : t;
      }).toList();
      state = AsyncValue.data(newTasks);
    });

    try {
      // 2. Sync to DB in background
      await _repository.updateTask(updatedTask);
    } catch (e) {
      // 3. Revert if DB fails (Safety net)
      state = previousState;
      log('Error updating task: $e');
    }
  }

  // 5. Toggle Complete (Wrapper around updateTask)
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await updateTask(updated);
  }

  // 6. Toggle Star (Wrapper around updateTask)
  Future<void> toggleStar(Task task) async {
    final updated = task.copyWith(isStarred: !task.isStarred);
    await updateTask(updated);
  }

  // 7. Delete (Optimistic Removal)
  Future<void> deleteTask(Task task) async {
    final previousState = state;

    // Remove from UI immediately
    state.whenData((tasks) {
      state = AsyncValue.data(tasks.where((t) => t.id != task.id).toList());
    });

    try {
      await _repository.softDeleteTask(task.id);
    } catch (e) {
      state = previousState;
    }
  }
}