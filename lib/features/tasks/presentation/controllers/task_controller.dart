// [1] VERSION: 1.0.0 - Task Controller
// UI segment: State Management
// BACKEND segment: Connects to TaskRepository
// API segment: n/a

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/task_repository.dart';
import '../../domain/task_model.dart';

// 1. The Provider for the Task List
final taskListProvider =
    StateNotifierProvider<TaskListController, AsyncValue<List<Task>>>((ref) {
      final repository = ref.read(taskRepositoryProvider);
      return TaskListController(repository);
    });

class TaskListController extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskListController(this._repository) : super(const AsyncValue.loading()) {
    // Load tasks immediately when this controller is first used
    loadTasks();
  }

  // 2. Load Tasks (Refresh)
  Future<void> loadTasks() async {
    try {
      // Don't set state to loading if we already have data (prevent flicker)
      if (!state.hasValue) {
        state = const AsyncValue.loading();
      }

      final tasks = await _repository.fetchTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 3. Add a new Task
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? categoryId,
  }) async {
    try {
      final newTask = await _repository.addTask(
        title: title,
        description: description,
        dueDate: dueDate,
        categoryId: categoryId,
      );

      // Update local state by appending the new task
      state.whenData((tasks) {
        state = AsyncValue.data([newTask, ...tasks]);
      });
    } catch (e) {
      log('Error adding task: $e');
      // Ideally show a snackbar here via a listener in the UI
    }
  }

  // 4. Toggle Completion (Optimistic Update)
  Future<void> toggleComplete(Task task) async {
    final previousState = state;

    // Optimistically update UI
    state.whenData((tasks) {
      final updatedTasks = tasks.map((t) {
        if (t.id == task.id) {
          return t.copyWith(
            isCompleted: !t.isCompleted,
            completedAt: !t.isCompleted ? DateTime.now() : null,
          );
        }
        return t;
      }).toList();
      state = AsyncValue.data(updatedTasks);
    });

    try {
      // Update DB
      await _repository.updateTask(
        task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        ),
      );
    } catch (e) {
      // Revert if failed
      state = previousState;
      log('Error toggling complete: $e');
    }
  }

  // 5. Toggle Star (Optimistic Update)
  Future<void> toggleStar(Task task) async {
    final previousState = state;

    state.whenData((tasks) {
      final updatedTasks = tasks.map((t) {
        if (t.id == task.id) return t.copyWith(isStarred: !t.isStarred);
        return t;
      }).toList();
      state = AsyncValue.data(updatedTasks);
    });

    try {
      await _repository.updateTask(task.copyWith(isStarred: !task.isStarred));
    } catch (e) {
      state = previousState;
    }
  }

  // 6. Soft Delete (Move to Trash)
  Future<void> deleteTask(Task task) async {
    final previousState = state;

    // Remove from UI immediately
    state.whenData((tasks) {
      state = AsyncValue.data(tasks.where((t) => t.id != task.id).toList());
    });

    try {
      await _repository.softDeleteTask(task.id);
    } catch (e) {
      state = previousState; // Revert if failed
    }
  }

  // 7. Generic Update (For Notes, Subtasks, Links, etc.)
  Future<void> updateTask(Task task) async {
    // 1. Optimistic Update (Update UI instantly)
    final previousState = state;
    state.whenData((tasks) {
      state = AsyncValue.data([
        for (final t in tasks)
          if (t.id == task.id) task else t,
      ]);
    });

    try {
      // 2. Sync with Supabase
      await _repository.updateTask(task);
    } catch (e) {
      // 3. Revert if DB fails
      state = previousState;
      log('Error updating task: $e');
    }
  }
}

// // [1] VERSION: 2.0.0 - Real-time Task Controller
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/task_repository.dart';
// import '../../domain/task_model.dart';
//
// // 1. Change Provider to StreamProvider
// final taskListProvider = StreamProvider<List<Task>>((ref) {
//   final repository = ref.read(taskRepositoryProvider);
//   return repository.watchTasks(); // Returns the live stream
// });
//
// // 2. We need a separate Controller for ACTIONS (Add/Edit/Delete)
// // because StreamProvider is read-only.
// final taskActionProvider = Provider((ref) {
//   return TaskActionController(ref.read(taskRepositoryProvider));
// });
//
// class TaskActionController {
//   final TaskRepository _repository;
//   TaskActionController(this._repository);
//
//   Future<void> addTask({required String title, DateTime? dueDate, int? categoryId}) async {
//     await _repository.addTask(title: title, dueDate: dueDate, categoryId: categoryId);
//   }
//
//   Future<void> updateTask(Task task) async {
//     await _repository.updateTask(task);
//   }
//
//   Future<void> toggleComplete(Task task) async {
//     await _repository.updateTask(task.copyWith(
//       isCompleted: !task.isCompleted,
//       completedAt: !task.isCompleted ? DateTime.now() : null,
//     ));
//   }
//
//   Future<void> toggleStar(Task task) async {
//     await _repository.updateTask(task.copyWith(isStarred: !task.isStarred));
//   }
//
//   Future<void> deleteTask(Task task) async {
//     await _repository.softDeleteTask(task.id);
//   }
// }
