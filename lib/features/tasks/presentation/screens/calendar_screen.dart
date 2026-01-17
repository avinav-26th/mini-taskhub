// [1] VERSION: 1.0.0 - Calendar Screen
// UI segment: Calendar Tab
// BACKEND segment: Connects to TaskListProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: taskState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (allTasks) {
          // 1. Filter tasks for the selected day
          final tasksForDay = allTasks.where((task) {
            if (task.dueDate == null) return false;
            return isSameDay(task.dueDate, _selectedDay);
          }).toList();

          return Column(
            children: [
              // 2. The Calendar Widget
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF4ECDC4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF2D3436),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Show dots for days with tasks
                  eventLoader: (day) {
                    return allTasks
                        .where((task) =>
                    task.dueDate != null && isSameDay(task.dueDate, day))
                        .toList();
                  },
                ),
              ),

              // 3. Task List for Selected Day
              Expanded(
                child: tasksForDay.isEmpty
                    ? Center(
                  child: Text(
                    "No tasks for ${_selectedDay?.day}/${_selectedDay?.month}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasksForDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForDay[index];
                    return TaskTile(
                      task: task,
                      onToggleComplete: () => ref.read(taskListProvider.notifier).toggleComplete(task),
                      onToggleStar: () => ref.read(taskListProvider.notifier).toggleStar(task),
                      onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}