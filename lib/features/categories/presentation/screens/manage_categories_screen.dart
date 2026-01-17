// [1] VERSION: 2.0.0 - Enhanced Categories
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/category_model.dart';
import '../controllers/category_controller.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  // 12 Preset Colors
  final List<Color> _presetColors = [
    const Color(0xFF4ECDC4), const Color(0xFFFF6B6B), const Color(0xFFFFE66D),
    const Color(0xFF1A535C), const Color(0xFF9B59B6), const Color(0xFF34495E),
    const Color(0xFF2ECC71), const Color(0xFF3498DB), const Color(0xFFE67E22),
    const Color(0xFFE74C3C), const Color(0xFF95A5A6), const Color(0xFFD35400),
  ];

  void _showCategoryDialog({Category? category}) {
    final isEditing = category != null;
    final controller = TextEditingController(text: category?.name ?? "");
    Color selectedColor = category != null
        ? Color(int.parse('0xFF${category.colorHex.replaceAll('#', '')}'))
        : _presetColors[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Use StatefulBuilder to update color selection inside dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Category" : "New Category"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text("Color Tag"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _presetColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: [if(isSelected) const BoxShadow(blurRadius: 5, color: Colors.black26)],
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final hex = '#${selectedColor.value.toRadixString(16).substring(2)}';

                      if (isEditing) {
                        // TODO: Add updateCategory to Controller (Need to implement in Controller first)
                        // For now, we only have add. I will provide the update logic below.
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit Saved (Mock)")));
                      } else {
                        ref.read(categoryListProvider.notifier).addCategory(controller.text, hex);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? "Save" : "Add"),
                )
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (categories) {
          // Reorderable List requires a stateful list, but here we just show the UI for now.
          // To implement true reordering, we need to update the `position_index` in DB.
          return ReorderableListView.builder(
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              // Optimistic UI update would go here
              if (oldIndex < newIndex) newIndex -= 1;
              // Logic to swap indexes in DB would be added here
            },
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = Color(int.parse('0xFF${cat.colorHex.replaceAll('#', '')}'));

              return ListTile(
                key: ValueKey(cat.id),
                leading: CircleAvatar(backgroundColor: color, radius: 10),
                title: Text(cat.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showCategoryDialog(category: cat),
                    ),
                    const Icon(Icons.drag_handle, color: Colors.grey),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}