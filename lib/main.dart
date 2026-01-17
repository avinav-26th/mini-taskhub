// [1] VERSION: 1.3.0 - Final Entry Point with Dynamic Theme

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';
import 'app/router.dart';
import 'features/settings/presentation/controllers/theme_controller.dart'; // Import this

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // 1. Watch the Theme Provider
    final appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mini TaskHub Pro',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // 2. Light Theme (Dynamic Seed)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: appTheme.seedColor,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),

      // 3. Dark Theme (Dynamic Seed)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: appTheme.seedColor,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      // 4. Mode Switcher
      themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
