// [1] VERSION: 1.0.0 - Task Repository
// UI segment: n/a
// BACKEND segment: Supabase CRUD Operations
// API segment: n/a

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/task_model.dart';

// 1. Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return TaskRepository(supabaseService.client);
});

class TaskRepository {
  final SupabaseClient _client;

  TaskRepository(this._client);

  // 2. Fetch Tasks (Real-time stream is optional, using Future for simplicity first)
  Future<List<Task>> fetchTasks() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Fetch rows where is_deleted is false (Active tasks)
      final data = await _client
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .eq('is_deleted', false) // Only active tasks
          .order('created_at', ascending: false);

      return (data as List).map((e) => Task.fromMap(e)).toList();
    } catch (e) {
      log('Error fetching tasks: $e');
      rethrow;
    }
  }

  // 2.1 Fetch Deleted Tasks (For Trash Bin)
  Future<List<Task>> fetchDeletedTasks() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw 'User not logged in';

      final data = await _client
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .eq('is_deleted', true) // Only deleted tasks
          .order('created_at', ascending: false);

      return (data as List).map((e) => Task.fromMap(e)).toList();
    } catch (e) {
      log('Error fetching trash: $e');
      rethrow;
    }
  }

  // 3. Add Task
  Future<Task> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? categoryId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw 'User not logged in';

    final response = await _client
        .from('tasks')
        .insert({
          'user_id': user.id,
          'title': title,
          'description': description,
          'due_date': dueDate?.toIso8601String(),
          'category_id': categoryId,
        })
        .select()
        .single();

    return Task.fromMap(response);
  }

  // 4. Update Task (Toggle complete, star, etc.)
  Future<void> updateTask(Task task) async {
    await _client.from('tasks').update(task.toMap()).eq('id', task.id);
  }

  // 5. Soft Delete (Move to Trash)
  Future<void> softDeleteTask(int taskId) async {
    await _client.from('tasks').update({'is_deleted': true}).eq('id', taskId);
  }

  // 6. Restore Task (From Trash)
  Future<void> restoreTask(int taskId) async {
    await _client.from('tasks').update({'is_deleted': false}).eq('id', taskId);
  }

  // 7. Permanent Delete
  Future<void> permanentlyDeleteTask(int taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  // Real-time Stream of Tasks
  Stream<List<Task>> watchTasks() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _client
        .from('tasks')
        .stream(primaryKey: ['id']) // Listen to changes
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Task.fromMap(e)).toList());
  }
}
