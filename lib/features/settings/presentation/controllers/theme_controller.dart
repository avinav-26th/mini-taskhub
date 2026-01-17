import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple State class for Theme
class AppThemeState {
  final bool isDarkMode;
  final Color seedColor;

  AppThemeState({required this.isDarkMode, required this.seedColor});

  AppThemeState copyWith({bool? isDarkMode, Color? seedColor}) {
    return AppThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeController, AppThemeState>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<AppThemeState> {
  // Default: Light Mode, Teal Color
  ThemeController() : super(AppThemeState(isDarkMode: false, seedColor: const Color(0xFF4ECDC4))) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final colorVal = prefs.getInt('seedColor') ?? 0xFF4ECDC4;

    state = AppThemeState(isDarkMode: isDark, seedColor: Color(colorVal));
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newVal);
    state = state.copyWith(isDarkMode: newVal);
  }

  Future<void> updateColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.toARGB32());
    state = state.copyWith(seedColor: color);
  }
}