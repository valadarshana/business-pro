import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/auth_user.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'orders_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  final AuthUser user;
  final Future<void> Function() onSignOut;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        userName: widget.user.name,
        onViewOrders: () => _selectTab(1),
        onSignOut: _signOut,
      ),
      OrdersScreen(onSignOut: _signOut),
      ExpensesScreen(onSignOut: _signOut),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
      ),
    );
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  Future<void> _signOut() async {
    try {
      await widget.onSignOut();
    } on FirebaseAuthException catch (error) {
      _showSignOutError(error.message ?? error.code);
    } on Exception catch (error) {
      _showSignOutError(error.toString());
    }
  }

  void _showSignOutError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not sign out: $message')));
  }
}
