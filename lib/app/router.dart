// [1] VERSION: 1.2.0 - Router with Bottom Navigation Shell
// UI segment: Navigation Logic

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_taskhub_pro/features/stats/presentation/screens/statistics_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/tasks/presentation/screens/dashboard_screen.dart';
import '../features/tasks/presentation/screens/calendar_screen.dart';
import '../features/home/presentation/main_scaffold.dart';

final authStateProvider = StreamProvider<void>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final authRepository = ref.read(authRepositoryProvider);

  // Define keys for the tabs to preserve state
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/tasks', // Default tab
    debugLogDiagnostics: true,

    routes: [
      // 1. Auth Routes (Public)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

      // 2. The Main Shell (Private)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Tab 2: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Tab 3: Mine (Profile/Stats)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mine',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authRepository.currentUser != null;
      final path = state.uri.toString();

      if (isLoading) return null;

      final isAuthRoute = path == '/login' || path == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/tasks'; // Redirect to main tab

      return null;
    },
  );
});