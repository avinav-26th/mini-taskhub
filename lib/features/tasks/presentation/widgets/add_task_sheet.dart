// [1] VERSION: 1.0.0 - Add Task Sheet with Categories & Date
// UI segment: Bottom Sheet
// BACKEND segment: Connects to Task & Category Controllers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../controllers/task_controller.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedCategoryId;

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    ref.read(taskListProvider.notifier).addTask(
      title: _titleController.text.trim(),
      dueDate: _selectedDate,
      categoryId: _selectedCategoryId,
    );
    Navigator.pop(context);
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryListProvider);

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 24, left: 20, right: 20
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("New Task", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Input
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: "What needs to be done?",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Selectors Row (Date & Category)
          Row(
            children: [
              // Date Button
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedDate != null ? const Color(0xFF4ECDC4).withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16,
                          color: _selectedDate != null ? const Color(0xFF4ECDC4) : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate == null ? "No Date" : DateFormat('MMM d').format(_selectedDate!),
                        style: TextStyle(
                            color: _selectedDate != null ? const Color(0xFF4ECDC4) : Colors.grey,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Category Selector (Horizontal Scroll)
              Expanded(
                child: categoryState.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          // Parse hex string to Color
                          final color = Color(int.parse('0xFF${cat.colorHex.replaceAll('#', '')}'));

                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryId = cat.id),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.transparent,
                                border: Border.all(color: color.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. Submit Button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3436),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Create Task"),
          ),
        ],
      ),
    );
  }
}