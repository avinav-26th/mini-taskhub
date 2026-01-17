// [1] VERSION: 1.0.0 - Auth Repository
// UI segment: n/a
// BACKEND segment: Supabase Auth Calls
// API segment: n/a

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

// 1. Provider to access this Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Get the Supabase client from our core service
  final supabaseService = ref.read(supabaseServiceProvider);
  return AuthRepository(supabaseService.client);
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // 2. Stream to listen for Auth Changes (Login/Logout events)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // 3. Get Current User immediately
  User? get currentUser => _client.auth.currentUser;

  // 4. Sign Up Function
  Future<void> signUp({
    required String email,
    required String password,
    required String username
  }) async {
    try {
      log('Action 7: Attempting Sign Up for $email');

      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username}, // Storing username in meta_data
      );

      if (res.user == null) {
        throw 'Sign up failed: User is null';
      }
      log('Action 8: Sign Up Successful. User ID: ${res.user!.id}');
    } catch (e) {
      log('Action 9: [ERROR] Sign Up Failed: $e');
      rethrow;
    }
  }

  // 5. Sign In Function
  Future<void> signIn({required String email, required String password}) async {
    try {
      log('Action 10: Attempting Sign In for $email');

      final AuthResponse res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw 'Login failed: User is null';
      }
      log('Action 11: Sign In Successful');
    } catch (e) {
      log('Action 12: [ERROR] Sign In Failed: $e');
      rethrow;
    }
  }

  // 6. Sign Out Function
  Future<void> signOut() async {
    try {
      log('Action 13: Signing out...');
      await _client.auth.signOut();
      log('Action 14: Sign Out Successful');
    } catch (e) {
      log('Action 15: [ERROR] Sign Out Failed: $e');
      rethrow;
    }
  }
}