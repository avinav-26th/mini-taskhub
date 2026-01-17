// [1] VERSION: 1.0.0 - Side Menu (Drawer)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../settings/presentation/controllers/theme_controller.dart';
import '../screens/trash_screen.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    final email = user?.email ?? "User";
    final username = user?.userMetadata?['username'] ?? "TaskHub Pro";

    return Drawer(
      child: Column(
        children: [
          // 1. User Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username[0].toUpperCase(),
                style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor),
              ),
            ),
          ),

          // 2. Menu Items
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text("Manage Categories"),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text("Trash Bin"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen()));
            },
          ),

          const Divider(),

          // 3. Theme Toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeState.isDarkMode,
            onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
          ),

          const Spacer(),

          // 4. Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}