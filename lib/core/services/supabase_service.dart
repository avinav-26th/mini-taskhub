// [1] VERSION: 1.0.0 - Supabase Service
// UI segment: n/a
// BACKEND segment: Supabase Client Initialization
// API segment: n/a

import 'dart:developer'; // For debug logging
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/constants.dart';

// 1. Create a Provider to access this service anywhere in the app
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  // 2. Getter for the Supabase Client
  SupabaseClient get client => Supabase.instance.client;

  // 3. User Helper (Get current user)
  User? get currentUser => client.auth.currentUser;

  // 4. Initialization Logic
  static Future<void> initialize() async {
    try {
      log('Action 1: Initializing Supabase Client...');

      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );

      log('Action 2: Supabase initialized successfully.');
    } catch (e) {
      log('Action 3: [ERROR] Failed to initialize Supabase: $e');
      rethrow; // Stop the app if DB fails
    }
  }
}