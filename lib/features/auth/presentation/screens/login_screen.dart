// [1] VERSION: 1.0.0 - Login Screen
// UI segment: Auth UI
// BACKEND segment: Connects to AuthController

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 1. Submit Logic
  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      // Trigger the controller
      await ref.read(authControllerProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Watch the state (Loading vs Error vs Data)
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // 3. Listen for Errors to show Snackbars
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Icon
                const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF4ECDC4)),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                AppTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                // Password Input
                AppTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) => val != null && val.length > 5 ? null : 'Password too short',
                ),
                const SizedBox(height: 30),

                // Login Button
                AppButton(
                  text: "Login",
                  isLoading: isLoading,
                  onPressed: _onLogin,
                ),

                const SizedBox(height: 20),

                // Switch to Sign Up
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}