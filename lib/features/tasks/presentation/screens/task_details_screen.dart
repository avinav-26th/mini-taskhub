// [1] VERSION: 3.0.0 - Stable Details Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../ai/data/ai_service.dart';
import '../../../pomodoro/presentation/controllers/timer_controller.dart';
import '../../domain/task_model.dart';
import '../controllers/task_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../categories/domain/category_model.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final Task initialTask;

  const TaskDetailsScreen({super.key, required this.initialTask});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late TextEditingController _notesController;
  late TextEditingController _linkController;
  late TextEditingController _titleController;

  bool _isAiLoading = false;
  String? _aiMotivation;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialTask.description ?? "");
    _linkController = TextEditingController(text: widget.initialTask.link ?? "");
    _titleController = TextEditingController(text: widget.initialTask.title);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _linkController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _updateTask(Task updatedTask) {
    // FIX: Use notifier
    ref.read(taskListProvider.notifier).updateTask(updatedTask);
  }

  void _showAddSubtaskDialog(Task liveTask) {
    final subController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Subtask"),
        content: TextField(
          controller: subController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g. Buy milk"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subController.text.isNotEmpty) {
                final newSubtasks = List.from(liveTask.subtasks);
                newSubtasks.add({'title': subController.text, 'done': false});

                _updateTask(liveTask.copyWith(subtasks: newSubtasks));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _triggerAISplit(Task liveTask) async {
    setState(() => _isAiLoading = true);

    try {
      final suggestions = await AIService.splitTask(liveTask.title);
      final currentSubtasks = List<Map<String, dynamic>>.from(
          liveTask.subtasks.map((e) => Map<String, dynamic>.from(e))
      );

      for (var step in suggestions) {
        currentSubtasks.add({'title': step, 'done': false});
      }

      _updateTask(liveTask.copyWith(subtasks: currentSubtasks));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Failed: $e")));
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  void _triggerAIMotivation(Task liveTask) async {
    final motivation = await AIService.getMotivation(liveTask.title);
    setState(() => _aiMotivation = motivation);
  }

  void _onPomodoroFinished(Task liveTask) {
    _updateTask(liveTask.copyWith(
        pomodoroSessions: liveTask.pomodoroSessions + 1
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🍅 Session Complete! Count updated.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE LIST (Not a stream anymore, but StateNotifier)
    final asyncTasks = ref.watch(taskListProvider);

    return asyncTasks.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
        data: (tasks) {
          // 2. FIND THE SPECIFIC TASK LIVE
          Task? liveTask;
          try {
            liveTask = tasks.firstWhere((t) => t.id == widget.initialTask.id);
          } catch (_) {
            return Scaffold(appBar: AppBar(), body: const Center(child: Text("Task deleted")));
          }

          final timerState = ref.watch(timerProvider);
          final categoriesAsync = ref.watch(categoryListProvider);
          const themeColor = Color(0xFF4ECDC4);
          final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                      liveTask!.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 28
                  ),
                  onPressed: () => ref.read(taskListProvider.notifier).toggleStar(liveTask!),
                )
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // 1. EDITABLE TITLE
                  TextField(
                    controller: _titleController..text = liveTask!.title,
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Task Title",
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) _updateTask(liveTask!.copyWith(title: val));
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. DATE & CATEGORY ROW
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: liveTask!.dueDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030)
                          );
                          if (picked != null) {
                            _updateTask(liveTask!.copyWith(dueDate: picked));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                liveTask!.dueDate == null
                                    ? "Set Date"
                                    : DateFormat('MMM dd').format(liveTask.dueDate!),
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: categoriesAsync.when(
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                            data: (categories) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300)
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                      value: liveTask!.categoryId,
                                      hint: const Text("No Category"),
                                      isExpanded: true,
                                      dropdownColor: Theme.of(context).cardColor,
                                      items: [
                                        const DropdownMenuItem<int>(
                                          value: null,
                                          child: Text("None"),
                                        ),
                                        ...categories.map((cat) {
                                          final color = Color(int.parse('0xFF${cat.colorHex.replaceAll('#', '')}'));
                                          return DropdownMenuItem<int>(
                                            value: cat.id,
                                            child: Row(
                                              children: [
                                                CircleAvatar(backgroundColor: color, radius: 6),
                                                const SizedBox(width: 8),
                                                Text(cat.name, style: TextStyle(color: textColor)),
                                              ],
                                            ),
                                          );
                                        })
                                      ],
                                      onChanged: (newCatId) {
                                        _updateTask(liveTask!.copyWith(categoryId: newCatId));
                                      }
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. POMODORO TIMER (Editable Version)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [themeColor, themeColor.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("FOCUS SESSION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            // EDIT DURATION BUTTON
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (c) => Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Set Timer Duration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [15, 25, 45, 60].map((min) => ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: themeColor,
                                              foregroundColor: Colors.white,
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(20),
                                            ),
                                            onPressed: () {
                                              ref.read(timerProvider.notifier).setDuration(min);
                                              Navigator.pop(c);
                                            },
                                            child: Text("$min"),
                                          )).toList(),
                                        ),
                                        const SizedBox(height: 10),
                                        Text("minutes", style: TextStyle(color: textColor)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${(timerState.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(timerState.timeLeft % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                              onPressed: timerState.isRunning
                                  ? ref.read(timerProvider.notifier).pauseTimer
                                  : () => ref.read(timerProvider.notifier).startTimer(onFinished: () => _onPomodoroFinished(liveTask!)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
                              onPressed: ref.read(timerProvider.notifier).resetTimer,
                            ),
                          ],
                        ),
                        Text("${liveTask!.pomodoroSessions} sessions done", style: const TextStyle(color: Colors.white70))
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. AI ASSISTANT
                  if (_aiMotivation != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_aiMotivation!, style: const TextStyle(color: Color(0xFF856404)))),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAiLoading ? null : () => _triggerAISplit(liveTask!),
                          icon: _isAiLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: const Text("AI Split"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _triggerAIMotivation(liveTask!),
                          icon: const Icon(Icons.psychology, size: 18),
                          label: const Text("AI Coach"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. SUBTASKS
                  Text("Subtasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  ...liveTask!.subtasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sub = entry.value;
                    return CheckboxListTile(
                      title: Text(sub['title'], style: TextStyle(
                          decoration: sub['done'] ? TextDecoration.lineThrough : null,
                          color: sub['done'] ? Colors.grey : textColor
                      )),
                      value: sub['done'],
                      activeColor: themeColor,
                      onChanged: (val) {
                        final newSubs = List.from(liveTask!.subtasks);
                        newSubs[index]['done'] = val;
                        _updateTask(liveTask!.copyWith(subtasks: newSubs));
                      },
                      secondary: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          final newSubs = List.from(liveTask!.subtasks);
                          newSubs.removeAt(index);
                          _updateTask(liveTask!.copyWith(subtasks: newSubs));
                        },
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => _showAddSubtaskDialog(liveTask!),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Subtask"),
                  ),

                  const SizedBox(height: 24),

                  // 6. NOTES
                  Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "Add details..."),
                      onChanged: (val) {
                        _updateTask(liveTask!.copyWith(description: val));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7. LINKS
                  Text("Link / Resource", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _linkController,
                            style: TextStyle(color: textColor),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: "Paste URL"),
                            onChanged: (val) {
                              _updateTask(liveTask!.copyWith(link: val));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
    );
  }
}