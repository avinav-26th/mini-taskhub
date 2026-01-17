// [1] VERSION: 1.0.0 - Auth Controller
// UI segment: State Management for Auth Screens
// BACKEND segment: Bridge to AuthRepository
// API segment: n/a

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/auth_repository.dart';

// 1. The Provider UI widgets will listen to
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.data(null));

  // 2. Handle Sign Up Logic
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required BuildContext context, // Passed to show Snackbars if needed
  }) async {
    // Set state to loading (UI shows spinner)
    state = const AsyncValue.loading();
    log('Action 16: Controller - Starting Sign Up Process');

    // Perform the operation
    state = await AsyncValue.guard(() async {
      await _authRepository.signUp(
        email: email,
        password: password,
        username: username,
      );
      log('Action 17: Controller - Sign Up Complete');
    });
  }

  // 3. Handle Login Logic
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = const AsyncValue.loading();
    log('Action 18: Controller - Starting Login Process');

    state = await AsyncValue.guard(() async {
      await _authRepository.signIn(
        email: email,
        password: password,
      );
      log('Action 19: Controller - Login Complete');
    });
  }

  // 4. Handle Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    log('Action 20: Controller - Starting Logout');

    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
      log('Action 21: Controller - Logout Complete');
    });
  }
}