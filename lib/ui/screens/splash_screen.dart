import 'package:flutter/material.dart';

import '../../services/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.splashTop, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 56,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Business Pro',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage Orders, Expenses\nand Grow Your Business',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 230,
                          height: 190,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(115),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 26,
                        left: 62,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 130,
                          color: AppColors.white,
                        ),
                      ),
                      const Positioned(
                        right: 44,
                        bottom: 48,
                        child: Icon(
                          Icons.eco_rounded,
                          color: AppColors.leaf,
                          size: 78,
                        ),
                      ),
                      const Positioned(
                        left: 28,
                        bottom: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.gold,
                            ),
                            SizedBox(width: 3),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.goldLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PageIndicator(active: true),
                    SizedBox(width: 7),
                    _PageIndicator(),
                    SizedBox(width: 7),
                    _PageIndicator(),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your Business, Our Priority',
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Get Started',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          LoginScreen(authRepository: authRepository),
                    ),
                  ),
                  outlined: true,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 14 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.white : AppColors.white.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
