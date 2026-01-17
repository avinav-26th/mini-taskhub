// [1] VERSION: 3.0.0 - Stable Dashboard (StateNotifier)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../features/home/presentation/widgets/side_menu.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import 'task_details_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH THE STATE (AsyncValue<List<Task>>)
    final taskState = ref.watch(taskListProvider);
    final todayStr = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(), // Hamburger Menu
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4ECDC4),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _showAddTaskSheet(context),
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
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  // Menu Icon
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                    title: Text(
                      "My Tasks",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 24
                      ),
                    ),
                    background: Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(top: 10, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 40),
                          Text(todayStr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          const Text("Have a great day!", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    // Optional Logout button if you want it here too
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      onPressed: () => ref.refresh(taskListProvider), // Pull to refresh
                    )
                  ],
                ),

                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        _SummaryCard(label: "Pending", count: pendingCount, color: const Color(0xFF4ECDC4), textColor: Colors.white),
                        const SizedBox(width: 12),
                        _SummaryCard(label: "Done", count: completedCount, color: Theme.of(context).cardColor, textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                      ],
                    ),
                  ),
                ),

                // Task List
                if (tasks.isEmpty)
                  const SliverFillRemaining(child: Center(child: Text("No tasks yet. Relax! ☕")))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final task = tasks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TaskDetailsScreen(initialTask: task))
                              );
                            },
                            child: TaskTile(
                              task: task,
                              // FIX: Use notifier directly
                              onToggleComplete: () => ref.read(taskListProvider.notifier).toggleComplete(task),
                              onToggleStar: () => ref.read(taskListProvider.notifier).toggleStar(task),
                              onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task),
                            ),
                          );
                        },
                        childCount: tasks.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;

  const _SummaryCard({required this.label, required this.count, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}