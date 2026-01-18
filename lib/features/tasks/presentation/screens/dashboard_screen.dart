// [1] VERSION: 3.1.0 - Dashboard with Filtering (Stable)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../features/home/presentation/widgets/side_menu.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';
import 'task_details_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Filter State: 'all', 'pending', 'done'
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE STATE
    final taskState = ref.watch(taskListProvider);
    final todayStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

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
            // 2. CALCULATE COUNTS (Always based on ALL tasks)
            final pendingCount = tasks.where((t) => !t.isCompleted).length;
            final completedCount = tasks.where((t) => t.isCompleted).length;

            // 3. APPLY FILTER (For the List view only)
            final displayedTasks = tasks.where((t) {
              if (_filter == 'pending') return !t.isCompleted;
              if (_filter == 'done') return t.isCompleted;
              return true; // 'all'
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0, // Reduced height to remove the "huge gap"
                  collapsedHeight: 70.0, // Keeps bar tall enough so text doesn't overlap menu
                  floating: true,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,

                  // 1. Top Row: Menu | App Name | Refresh (Stays Pinned)
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: textColor),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Text(
                    "Mini TaskHub Pro",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      onPressed: () => ref.refresh(taskListProvider),
                    )
                  ],

                  // 2. Bottom Row: Shrinking Status (Stops just below top row)
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false, // Centers the shrinking text horizontally
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 12), // Keeps it at the bottom edge

                    title: InkWell(
                      onTap: () => setState(() => _filter = 'all'),
                      child: Text(
                        _filter == 'all' ? "My Tasks" : (_filter == 'pending' ? "Pending" : "Completed"),
                        style: TextStyle(
                          color: textColor, // Use theme color
                          fontWeight: FontWeight.w800,
                          fontSize: 15, // Smaller base size so it fits nicely when collapsed
                        ),
                      ),
                    ),

                    // Background Date (Visible when expanded, fades out when scrolled)
                    background: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.only(right: 20, bottom: 15, top:60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              todayStr,
                              style: TextStyle(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          if (_filter != 'all')
                            Text("Tap ${_filter == 'pending' ? "Pending" : "Completed"} to view all", style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. SUMMARY CARDS (Clickable)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        _SummaryCard(
                          label: "Pending",
                          count: pendingCount,
                          color: Theme.of(context).cardColor,
                          textColor: textColor ?? Colors.black,
                          isSelected: _filter == 'pending',
                          onTap: () => setState(() => _filter = 'pending'),
                        ),
                        const SizedBox(width: 12),
                        _SummaryCard(
                          label: "Completed",
                          count: completedCount,
                          color: const Color(0xFF4ECDC4),
                          textColor: Colors.white,
                          isSelected: _filter == 'done',
                          onTap: () => setState(() => _filter = 'done'),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. TASK LIST (Filtered)
                if (displayedTasks.isEmpty)
                  SliverFillRemaining(child: Center(child: Text("No ${_filter == 'all' ? '' : _filter} tasks found.")))
                else
                    SliverReorderableList(
                      itemBuilder: (context, index) {
                        final task = displayedTasks[index];
                        // Wrap in KeyedSubtree or Container with key for Reorderable logic
                        return Container(
                          key: ValueKey(task.id),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TaskDetailsScreen(initialTask: task))
                              );
                            },
                            // We pass a key to TaskTile to help flutter track it
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => ref.read(taskListProvider.notifier).toggleComplete(task),
                              onToggleStar: () => ref.read(taskListProvider.notifier).toggleStar(task),
                              onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task),
                            ),
                          ),
                        );
                      },
                      itemCount: displayedTasks.length,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                      },
                    ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
  final bool isSelected; // Added for border highlighting
  final VoidCallback onTap; // Added for interaction

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            // Orange border when selected
            border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
      ),
    );
  }
}