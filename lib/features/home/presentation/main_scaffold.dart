// [1] VERSION: 1.0.0 - Main Scaffold with Bottom Bar
// UI segment: Navigation Shell

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is the current tab (Dashboard, Calendar, or Profile)
      body: navigationShell,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(index),
          backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
          indicatorColor: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onSurface == Colors.white
                    ? Colors.white
                    : Color(0xFF2D3436),
              ),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.onSurface == Colors.white
                    ? Colors.white
                    : Color(0xFF2D3436),
              ),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSurface == Colors.white
                    ? Colors.white
                    : Color(0xFF2D3436),
              ),
              label: 'Mine',
            ),
          ],
        ),
      ),
    );
  }
}
