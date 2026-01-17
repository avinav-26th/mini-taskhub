// [1] VERSION: 1.0.0 - Task Details Screen
// UI segment: Vertical Scroll Details
// BACKEND segment: Connects to AI, Pomodoro, and Task Repos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts is in pubspec
import '../../../ai/data/ai_service.dart';
import '../../../pomodoro/presentation/controllers/timer_controller.dart';
import '../../domain/task_model.dart';
import '../controllers/task_controller.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late TextEditingController _notesController;
  late TextEditingController _linkController;
  // late TextEditingController _titleController;
  late List<dynamic> _subtasks;
  bool _isAiLoading = false;
  String? _aiMotivation;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.task.description ?? "",
    );
    _linkController =
        TextEditingController(); // Assuming we had a link field, using blank for now
    _subtasks = List.from(widget.task.subtasks);
    // _titleController = TextEditingController(text: widget.task.title);
  }

  // --- Logic Helpers ---

  void _saveChanges() {
    // Update the task in the database
    final updatedTask = widget.task.copyWith(
      description: _notesController.text,
      subtasks: _subtasks,
    );
    ref.read(taskListProvider.notifier).updateTask(updatedTask);
  }

  void _addSubtask(String title) {
    setState(() {
      _subtasks.add({'title': title, 'done': false});
    });
    _saveChanges();
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index]['done'] = !_subtasks[index]['done'];
    });
    _saveChanges();
  }

  void _triggerAISplit() async {
    setState(() => _isAiLoading = true);

    // Call Groq
    final suggestions = await AIService.splitTask(widget.task.title);

    setState(() {
      for (var step in suggestions) {
        _subtasks.add({'title': step, 'done': false});
      }
      _isAiLoading = false;
    });
    _saveChanges();
  }

  void _triggerAIMotivation() async {
    // Show a loading snackbar or local state
    final motivation = await AIService.getMotivation(widget.task.title);
    setState(() => _aiMotivation = motivation);
  }

  void _onPomodoroFinished() {
    // Increment session count in DB
    final updatedTask = widget.task.copyWith(
      pomodoroSessions: widget.task.pomodoroSessions + 1,
    );
    ref.read(taskListProvider.notifier).updateTask(updatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🍅 Session Complete! Good job!")),
    );
  }

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final themeColor = const Color(0xFF4ECDC4);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.task.isStarred ? Icons.star : Icons.star_border,
              color: Colors.orange,
            ),
            onPressed: () {
              ref.read(taskListProvider.notifier).toggleStar(widget.task);
              setState(() {}); // Local refresh
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Title)
            Text(
              widget.task.title,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // // 1. Editable Header
            // TextField(
            //   controller: _titleController,
            //   style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
            //   decoration: const InputDecoration(
            //     border: InputBorder.none,
            //     hintText: "Task Title",
            //   ),
            //   onChanged: (val) {
            //     // Auto-save Title
            //     if (val.isNotEmpty) {
            //       ref.read(taskActionProvider).updateTask(widget.task.copyWith(title: val));
            //     }
            //   },
            // ),
            const SizedBox(height: 24),
            // Row(
            //   children: [
            //     const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            //     const SizedBox(width: 8),
            //     TextButton(
            //       onPressed: () async {
            //         final picked = await showDatePicker(
            //             context: context,
            //             initialDate: DateTime.now(),
            //             firstDate: DateTime(2020),
            //             lastDate: DateTime(2030)
            //         );
            //         if (picked != null) {
            //           ref.read(taskActionProvider).updateTask(widget.task.copyWith(dueDate: picked));
            //           setState(() {}); // refresh local view
            //         }
            //       },
            //       child: Text(
            //         widget.task.dueDate == null
            //             ? "Set Due Date"
            //             : DateFormat('MMM dd, yyyy').format(widget.task.dueDate!),
            //         style: const TextStyle(color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold),
            //       ),
            //     )
            //   ],
            // ),

            // 2. Pomodoro Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "FOCUS SESSION",
                    style: TextStyle(
                      color: Colors.white70,
                      letterSpacing: 1.5,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${(timerState.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(timerState.timeLeft % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.small(
                        heroTag: "timer_play",
                        backgroundColor: Colors.white,
                        onPressed: timerState.isRunning
                            ? ref.read(timerProvider.notifier).pauseTimer
                            : () => ref
                                  .read(timerProvider.notifier)
                                  .startTimer(onFinished: _onPomodoroFinished),
                        child: Icon(
                          timerState.isRunning ? Icons.pause : Icons.play_arrow,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.small(
                        heroTag: "timer_reset",
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        elevation: 0,
                        onPressed: ref.read(timerProvider.notifier).resetTimer,
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.task.pomodoroSessions} sessions completed",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. AI Assistant Section
            if (_aiMotivation != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEEBA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _aiMotivation!,
                        style: const TextStyle(color: Color(0xFF856404)),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAiLoading ? null : _triggerAISplit,
                    icon: _isAiLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: const Text("AI Split Task"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _triggerAIMotivation,
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text("AI Coach"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Subtasks List
            const Text(
              "Subtasks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ..._subtasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subtask = entry.value;
                    return CheckboxListTile(
                      value: subtask['done'],
                      title: Text(
                        subtask['title'],
                        style: TextStyle(
                          decoration: subtask['done']
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask['done'] ? Colors.grey : Colors.black87,
                        ),
                      ),
                      activeColor: themeColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => _toggleSubtask(index),
                      secondary: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _subtasks.removeAt(index));
                          _saveChanges();
                        },
                      ),
                    );
                  }),
                  // Add Subtask Button
                  InkWell(
                    onTap: () {
                      // Simple Dialog to add manual subtask
                      showDialog(
                        context: context,
                        builder: (c) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text("Add Subtask"),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "e.g. Buy milk",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    _addSubtask(controller.text);
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: themeColor),
                          const SizedBox(width: 12),
                          Text(
                            "Add a step",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Notes & Links
            const Text(
              "Notes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              // child: TextField(
              //   controller: _notesController,
              //   maxLines: 5,
              //   decoration: const InputDecoration(
              //     border: InputBorder.none,
              //     hintText: "Add details, links, or random thoughts...",
              //   ),
              //   onChanged: (_) => _saveChanges(), // Autosave on typing
              // ),
            ),
            const SizedBox(height: 40),

            // 6. Link Attachment
            const Text(
              "Link / Resource",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Paste a URL (e.g. Figma, Youtube)",
                      ),
                      onChanged: (val) {
                        // Auto-save logic
                        final updatedTask = widget.task.copyWith(link: val);
                        ref
                            .read(taskListProvider.notifier)
                            .updateTask(updatedTask);
                      },
                    ),
                  ),
                  if (_linkController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new,
                        color: Color(0xFF4ECDC4),
                      ),
                      onPressed: () {
                        // You would use url_launcher here
                        // launchUrl(Uri.parse(_linkController.text));
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
