import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_taskhub_pro/features/settings/presentation/controllers/theme_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  final List<Color> _colors = const [
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFE66D), // Yellow
    Color(0xFF1A535C), // Dark Blue
    Color(0xFF9B59B6), // Purple
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Appearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeState.isDarkMode,
            onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
            secondary: Icon(themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const SizedBox(height: 20),
          const Text("Accent Color", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: _colors.map((color) {
              final isSelected = themeState.seedColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).updateColor(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
          const Divider(height: 40),
          const Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}