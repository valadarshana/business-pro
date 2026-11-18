import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.receipt_long_outlined, label: 'Orders'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Expenses'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primaryLight,
      height: 68,
      destinations: _items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.icon, color: AppColors.primary),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
