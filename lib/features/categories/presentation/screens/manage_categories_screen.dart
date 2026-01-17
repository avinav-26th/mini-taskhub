import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/category_controller.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF4ECDC4);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            // Simple color picker mock
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Color(0xFF4ECDC4), Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF9B59B6)
                ].map((c) => GestureDetector(
                  onTap: () => selectedColor = c,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    width: 30, height: 30,
                    color: c,
                  ),
                )).toList(),
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Convert Color to Hex String
                String hex = '#${selectedColor.toARGB32().toRadixString(16).substring(2)}';
                ref.read(categoryListProvider.notifier).addCategory(controller.text, hex);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (categories) => ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final color = Color(int.parse('0xFF${cat.colorHex.replaceAll('#', '')}'));
            return ListTile(
              leading: CircleAvatar(backgroundColor: color, radius: 10),
              title: Text(cat.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // TODO: Implement Delete in Controller/Repo if needed
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete not implemented yet")));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}