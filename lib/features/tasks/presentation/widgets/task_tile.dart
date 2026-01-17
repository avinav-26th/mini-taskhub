import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import this
import 'package:intl/intl.dart';
import '../../domain/task_model.dart';
import '../screens/task_details_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleStar;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onToggleStar,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = task.dueDate != null
        ? DateFormat('MMM dd, hh:mm a').format(task.dueDate!)
        : '';

    // Color logic based on priority or category (placeholder for now)
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task))
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Slidable(
          key: ValueKey(task.id),
      
          // Swipe Left Actions (Delete, Edit)
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Delete',
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
      
          // Swipe Right Actions (Star/Prioritize)
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onToggleStar(),
                backgroundColor: const Color(0xFFFFE66D),
                foregroundColor: Colors.black87,
                icon: task.isStarred ? Icons.star_border : Icons.star,
                label: task.isStarred ? 'Unstar' : 'Star',
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
      
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: task.isStarred
                  ? Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                // 1. Custom Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? const Color(0xFF4ECDC4) : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? const Color(0xFF4ECDC4) : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
      
                // 2. Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted ? Colors.grey.shade400 : Colors.black87,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (dateStr.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 12,
                                  color: isOverdue ? Colors.red : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isOverdue ? Colors.red : Colors.grey,
                                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
      
                // 3. Star Indicator (Visual Only)
                if (task.isStarred)
                  const Icon(Icons.star, color: Colors.orange, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}