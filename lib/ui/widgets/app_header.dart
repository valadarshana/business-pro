import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: 8,
        right: 8,
      ),
      height: 74 + MediaQuery.paddingOf(context).top,
      child: Row(
        children: [
          IconButton(
            onPressed: showBack
                ? (onBack ?? () => Navigator.pop(context))
                : null,
            icon: Icon(
              showBack ? Icons.arrow_back : Icons.menu,
              color: AppColors.white,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: showBack ? TextAlign.left : TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          trailing ??
              IconButton(
                onPressed: () {},
                icon: Icon(
                  showBack ? Icons.more_horiz : Icons.notifications_none,
                  color: AppColors.white,
                ),
              ),
        ],
      ),
    );
  }
}
