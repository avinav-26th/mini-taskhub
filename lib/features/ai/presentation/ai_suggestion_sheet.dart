import 'package:flutter/material.dart';
import '../data/ai_service.dart';

class AiSuggestionSheet extends StatefulWidget {
  final String taskTitle;
  const AiSuggestionSheet({super.key, required this.taskTitle});

  @override
  State<AiSuggestionSheet> createState() => _AiSuggestionSheetState();
}

class _AiSuggestionSheetState extends State<AiSuggestionSheet> {
  bool isLoading = true;
  String? motivation;
  List<String>? steps;

  @override
  void initState() {
    super.initState();
    _loadAi();
  }

  void _loadAi() async {
    // Parallel execution for speed
    final results = await Future.wait([
      AIService.getMotivation(widget.taskTitle),
      AIService.splitTask(widget.taskTitle),
    ]);

    if (mounted) {
      setState(() {
        motivation = results[0] as String;
        steps = results[1] as List<String>;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("AI Assistant", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Motivation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(motivation ?? "", style: const TextStyle(color: Colors.deepOrange)),
            ),
            const SizedBox(height: 20),
            const Text("Suggested Steps", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (steps != null)
              ...steps!.map((s) => ListTile(
                leading: const Icon(Icons.subdirectory_arrow_right, size: 16),
                title: Text(s),
                dense: true,
              )),
          ]
        ],
      ),
    );
  }
}