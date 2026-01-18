// [1] VERSION: 2.0.0 - Master Settings
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../tasks/presentation/screens/task_details_screen.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    // final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // 1. General Section
          _SectionHeader(title: "General"),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: const Text("Starred Tasks"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to a simple filtered view (or show dialog)
              _showStarredDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.widgets, color: Colors.blue),
            title: const Text("Home Widget"),
            subtitle: const Text("Coming soon"),
            onTap: () {},
          ),

          // 2. Appearance Section
          _SectionHeader(title: "Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeState.isDarkMode,
            onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          ListTile(
            title: const Text("Language"),
            leading: const Icon(Icons.language),
            trailing: const Text("English", style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),

          // 3. Support Section
          _SectionHeader(title: "Support"),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("FAQ"),
            onTap: () => _launchURL("https://example.com/faq"),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text("Send Feedback"),
            onTap: () => _launchURL("mailto:support@taskhub.com"),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            onTap: () => _launchURL("https://example.com/privacy"),
          ),

          // 4. Community Section
          _SectionHeader(title: "Community"),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text("Donate"),
            onTap: () => _launchURL("https://buymeacoffee.com"),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text("Rate Us"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Follow Us"),
            onTap: () {},
          ),

          const Divider(),
          // 5. Account
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),

          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("Version 1.0.0 (Beta)", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    // Requires url_launcher package. For now, we mock.
    // if (await canLaunchUrlString(url)) await launchUrlString(url);
  }

  void _showStarredDialog(BuildContext context, WidgetRef ref) {
    // Quick Hack: Show starred tasks in a popup list
    final tasks = ref.read(taskListProvider).value ?? [];
    final starred = tasks.where((t) => t.isStarred).toList();

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Starred Tasks"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: starred.isEmpty
                ? const Center(child: Text("No starred tasks"))
                : ListView.builder(
              itemCount: starred.length,
              itemBuilder: (c, i) => ListTile(
                title: Text(starred[i].title),
                leading: const Icon(Icons.star, color: Colors.orange, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailsScreen(initialTask: starred[i])));
                },
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
        )
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4ECDC4), letterSpacing: 1.2),
      ),
    );
  }
}