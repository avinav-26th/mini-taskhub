// [1] VERSION: 1.1.0 - Dashboard Screen (Sliver Layout)
// UI segment: Main Task List
// BACKEND segment: Connects to TaskController

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskListProvider);
    final todayStr = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4ECDC4),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _showAddTaskSheet(context, ref),
      ),

      body: SafeArea(
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (tasks) {
            final pendingCount = tasks.where((t) => !t.isCompleted).length;
            final completedCount = tasks.where((t) => t.isCompleted).length;

            return CustomScrollView(
              slivers: [
                // 1. Large App Bar
                SliverAppBar(
                  expandedHeight: 140.0,
                  floating: true,
                  pinned: true,
                  backgroundColor: const Color(0xFFF5F7FA),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Text(
                      "My Tasks",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                    background: Container(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Good Day!", style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(todayStr, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          // Logout Icon
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.black54),
                            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Summary Cards (Pending / Completed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        _SummaryCard(
                            label: "Pending",
                            count: pendingCount,
                            color: const Color(0xFF4ECDC4),
                            textColor: Colors.white
                        ),
                        const SizedBox(width: 12),
                        _SummaryCard(
                            label: "Done",
                            count: completedCount,
                            color: Colors.white,
                            textColor: Colors.black87
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Task List
                if (tasks.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text("No tasks yet. Relax! ☕")),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            onToggleComplete: () => ref.read(taskListProvider.notifier).toggleComplete(task),
                            onToggleStar: () => ref.read(taskListProvider.notifier).toggleStar(task),
                            onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task),
                          );
                        },
                        childCount: tasks.length,
                      ),
                    ),
                  ),

                // Bottom spacer so FAB doesn't cover last item
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(), // Use the new widget we just made
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}