// [1] VERSION: 1.0.0 - AI Service (Groq / Llama 3)
// UI segment: n/a
// BACKEND segment: Groq API Call

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../app/constants.dart';

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // 1. Split Task Logic
  static Future<List<String>> splitTask(String taskTitle) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant", // The fast, instant model
          "messages": [
            {
              "role": "system",
              "content": "You are a task manager. Split the given task into 3-5 distinct, actionable subtasks. Return ONLY a raw JSON array of strings. Example: [\"Step 1\", \"Step 2\"]. Do not add markdown formatting or extra text."
            },
            {"role": "user", "content": "Task: ${taskTitle.replaceAll('"', "'")}"}
          ],
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        log("AI Raw Response: $content");

        // Clean up any potential markdown (Llama sometimes adds ```json)
        final cleanContent = content.replaceAll('```json', '').replaceAll('```', '').trim();
        return List<String>.from(jsonDecode(cleanContent));
      } else {
        throw 'Groq Error: ${response.statusCode}';
      }
    } catch (e) {
      log("AI Split Error: $e");
      return ["Plan the steps manually", "Research best practices", "Execute first step"]; // Fallback
    }
  }

  // 2. Motivation Logic
  static Future<String> getMotivation(String taskTitle) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content": "You are a motivational coach. Give a short (2 sentences max), punchy advice on how to start the given task. Use an emoji. Do not be too wordy."
            },
            {"role": "user", "content": "Give motivation for: $taskTitle"}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      return "You got this! Just start.";
    } catch (e) {
      return "Focus on the first step. You can do it! 🚀";
    }
  }
}