import 'package:flutter/material.dart';

import '../state/business_state.dart';
import '../theme/app_theme.dart';
import '../ui/screens/splash_screen.dart';

class BusinessProApp extends StatefulWidget {
  const BusinessProApp({super.key});

  @override
  State<BusinessProApp> createState() => _BusinessProAppState();
}

class _BusinessProAppState extends State<BusinessProApp> {
  late final BusinessState state;

  @override
  void initState() {
    super.initState();
    state = BusinessState();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BusinessStateScope(
      notifier: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Business Pro',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
