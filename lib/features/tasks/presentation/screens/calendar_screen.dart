// [1] VERSION: 2.0.0 - Calendar Screen (Fixed for Stream)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';
import 'task_details_screen.dart'; // Import for navigation

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
          final tasksForDay = allTasks.where((task) {
            if (task.dueDate == null) return false;
            return isSameDay(task.dueDate, _selectedDay);
          }).toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Color(0xFF4ECDC4), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Color(0xFF2D3436), shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  ),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month', // Hides the "2 weeks" toggle
                  },
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    return allTasks.where((task) {
                      if (task.dueDate == null) return false;
                      // Normalize both dates to UTC or just Year/Month/Day
                      return isSameDay(task.dueDate, day);
                    }).toList();
                  },
                ),
              ),

              Expanded(
                child: tasksForDay.isEmpty
                    ? Center(child: Text("No tasks for ${_selectedDay?.day}/${_selectedDay?.month}", style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasksForDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForDay[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TaskDetailsScreen(initialTask: task))
                        );
                      },
                      child: TaskTile(
                        task: task,
                        // FIX: Use taskActionProvider
                        onToggleComplete: () => ref.read(taskListProvider.notifier).toggleComplete(task),
                        onToggleStar: () => ref.read(taskListProvider.notifier).toggleStar(task),
                        onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task),
                      ),
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