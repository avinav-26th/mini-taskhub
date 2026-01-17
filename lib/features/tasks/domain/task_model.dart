// [1] VERSION: 1.1.0 - Task Model (FIXED)
// UI segment: n/a
// BACKEND segment: Data Model

class Task {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isStarred;
  final bool isDeleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int? categoryId;
  final List<dynamic> subtasks; // Stored as JSONB in DB
  final int pomodoroSessions;
  final String? link; // <--- Added here

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isStarred = false,
    this.isDeleted = false,
    this.dueDate,
    this.completedAt,
    this.categoryId,
    this.subtasks = const [],
    this.pomodoroSessions = 0,
    this.link, // <--- Added here
  });

  // 1. Factory constructor to create a Task from Supabase JSON
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['is_completed'] ?? false,
      isStarred: map['is_starred'] ?? false,
      isDeleted: map['is_deleted'] ?? false,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']).toLocal() : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']).toLocal() : null,
      categoryId: map['category_id'] as int?,
      subtasks: map['subtasks'] as List<dynamic>? ?? [],
      pomodoroSessions: map['pomodoro_sessions'] ?? 0,
      link: map['link'] as String?, // <--- Added here
    );
  }

  // 2. Convert Task object back to JSON for sending to Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'is_starred': isStarred,
      'is_deleted': isDeleted,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'category_id': categoryId,
      'subtasks': subtasks,
      'pomodoro_sessions': pomodoroSessions,
      'link': link, // <--- Added here
    };
  }

  // 3. Create a copy of the task with modified fields (Immutability)
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isStarred,
    bool? isDeleted,
    DateTime? dueDate,
    DateTime? completedAt,
    int? categoryId,
    List<dynamic>? subtasks,
    int? pomodoroSessions,
    String? link, // <--- THIS WAS MISSING
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      categoryId: categoryId ?? this.categoryId,
      subtasks: subtasks ?? this.subtasks,
      pomodoroSessions: pomodoroSessions ?? this.pomodoroSessions,
      link: link ?? this.link, // <--- Ensure this is also added
    );
  }
}