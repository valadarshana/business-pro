import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_error_message.dart';
import '../../services/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.registerWithEmail(
        name: _nameController.text,
        businessName: _businessNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = authErrorMessage(error.code));
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message ?? error.code);
      }
    } on Exception catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Start managing your business',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to continue.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: 'Full name',
                hint: 'Enter your name',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: _required,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _businessNameController,
                label: 'Business name',
                hint: 'Enter your business name',
                icon: Icons.storefront_outlined,
                textCapitalization: TextCapitalization.words,
                validator: _required,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'At least 6 characters',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Use at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                hint: 'Re-enter your password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmation,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirmation = !_obscureConfirmation,
                  ),
                  icon: Icon(
                    _obscureConfirmation
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                label: 'Create account',
                onPressed: _isRegistering ? null : _register,
              ),
              if (_isRegistering) ...[
                const SizedBox(height: 14),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isRegistering ? null : () => Navigator.pop(context),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    if (!value.contains('@')) return 'Enter a valid email address';
    return null;
  }
}
