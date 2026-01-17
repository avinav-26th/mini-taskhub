// [1] VERSION: 2.0.0 - Main with FIXED Dark Mode
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';
import 'app/router.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

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
    final appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mini TaskHub Pro',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // 1. Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: appTheme.seedColor,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light Grey
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          surfaceTintColor: Colors.transparent,
        ),
      ),

      // 2. Fixed Dark Theme (Clean Dark Grey, not Brown)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // We override the seed generation for background to ensure it's clean
        colorScheme: ColorScheme.fromSeed(
          seedColor: appTheme.seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E), // Card Color
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Almost Black
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          surfaceTintColor: Colors.transparent,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),

      themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}