import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.expand = true,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool expand;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    final button = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              foregroundColor: foregroundColor ?? AppColors.ink,
              side: BorderSide(color: borderColor ?? AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: foregroundColor == null
                ? null
                : ElevatedButton.styleFrom(foregroundColor: foregroundColor),
            child: child,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
