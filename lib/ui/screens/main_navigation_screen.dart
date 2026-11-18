import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'orders_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onViewOrders: () => _selectTab(1)),
      const OrdersScreen(),
      const ExpensesScreen(),
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
}
