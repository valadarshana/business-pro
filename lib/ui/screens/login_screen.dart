import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/app_strings.dart';
import '../../services/auth_repository.dart';
import '../../services/auth_error_message.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _runSignIn(
      () => widget.authRepository.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _loginWithGoogle() =>
      _runSignIn(widget.authRepository.signInWithGoogle);

  Future<void> _runSignIn(Future<Object?> Function() signIn) async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });
    try {
      await signIn();
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = authErrorMessage(error.code));
      }
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message ?? error.code);
    } on GoogleSignInException catch (error) {
      if (error.code != GoogleSignInExceptionCode.canceled && mounted) {
        setState(() => _errorMessage = error.description ?? error.code.name);
      }
    } on Exception catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 52),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to your account',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 36),
                AppTextField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email address';
                    }
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  hint: 'Password',
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
                ),
                const SizedBox(height: 22),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
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
                  const SizedBox(height: 12),
                ],
                AppButton(
                  label: 'Login',
                  onPressed: _isSigningIn ? null : _login,
                ),
                // const SizedBox(height: 22),
                // const Row(
                //   children: [
                //     Expanded(child: Divider()),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 10),
                //       child: Text(
                //         'or',
                //         style: TextStyle(color: AppColors.muted),
                //       ),
                //     ),
                //     Expanded(child: Divider()),
                //   ],
                // ),
                // const SizedBox(height: 18),
                // AppButton(
                //   label: 'Continue with Google',
                //   icon: Icons.g_mobiledata,
                //   onPressed: _isSigningIn ? null : _loginWithGoogle,
                //   outlined: true,
                // ),
                // if (_isSigningIn) ...[
                //   const SizedBox(height: 14),
                //   const CircularProgressIndicator(),
                // ],
                // const SizedBox(height: 24),
                // TextButton(
                //   onPressed: _isSigningIn
                //       ? null
                //       : () => Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (_) => RegisterScreen(
                //               authRepository: widget.authRepository,
                //             ),
                //           ),
                //         ),
                //   child: const Text.rich(
                //     TextSpan(
                //       text: "Don't have an account?  ",
                //       style: TextStyle(color: AppColors.muted, fontSize: 12),
                //       children: [
                //         TextSpan(
                //           text: 'Register',
                //           style: TextStyle(
                //             color: AppColors.primary,
                //             fontWeight: FontWeight.w700,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
