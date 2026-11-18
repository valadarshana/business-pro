import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../providers/expense_providers.dart';
import '../providers/order_providers.dart';
import '../repositories/expense_repository.dart';
import '../repositories/order_repository.dart';
import '../services/auth_repository.dart';
import '../services/firebase_auth_repository.dart';
import '../services/firebase_initializer.dart';
import '../theme/app_theme.dart';
import '../ui/screens/main_navigation_screen.dart';
import '../ui/screens/splash_screen.dart';

class BusinessProApp extends StatefulWidget {
  const BusinessProApp({
    super.key,
    this.authRepository,
    this.orderRepository,
    this.expenseRepository,
  });

  final AuthRepository? authRepository;
  final OrderRepository? orderRepository;
  final ExpenseRepository? expenseRepository;

  @override
  State<BusinessProApp> createState() => _BusinessProAppState();
}

class _BusinessProAppState extends State<BusinessProApp> {
  late Future<FirebaseApp>? firebaseInitialization;

  @override
  void initState() {
    super.initState();
    firebaseInitialization = widget.authRepository == null
        ? FirebaseInitializer.initialize()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (widget.orderRepository != null)
          orderRepositoryProvider.overrideWithValue(widget.orderRepository!),
        if (widget.expenseRepository != null)
          expenseRepositoryProvider.overrideWithValue(
            widget.expenseRepository!,
          ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Business Pro',
        theme: AppTheme.light,
        home: widget.authRepository != null
            ? AuthGate(authRepository: widget.authRepository!)
            : FutureBuilder<FirebaseApp>(
                future: firebaseInitialization,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return FirebaseSetupScreen(
                      error: snapshot.error.toString(),
                      onRetry: () => setState(
                        () => firebaseInitialization =
                            FirebaseInitializer.initialize(),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return AuthGate(authRepository: FirebaseAuthRepository());
                },
              ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FirebaseSetupScreen(error: snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return SplashScreen(authRepository: authRepository);
        }
        return MainNavigationScreen(
          user: user,
          onSignOut: authRepository.signOut,
        );
      },
    );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key, required this.error, this.onRetry});

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'Firebase setup required',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add this app to your Firebase project, enable Google sign-in, '
                'and install the platform configuration before signing in.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SelectableText(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
