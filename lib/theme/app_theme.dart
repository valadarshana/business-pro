import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF5143D9);
  static const primaryDark = Color(0xFF4531C9);
  static const splashTop = Color(0xFF6254DF);
  static const primaryLight = Color(0xFFEAEFFF);
  static const ink = Color(0xFF20243A);
  static const muted = Color(0xFF8D93A6);
  static const border = Color(0xFFE8EAF2);
  static const background = Color(0xFFF7F8FC);
  static const fieldBackground = Color(0xFFF8F9FC);
  static const success = Color(0xFF21A66A);
  static const warning = Color(0xFFFFA100);
  static const danger = Color(0xFFEF6670);
  static const blue = Color(0xFF3D81E8);
  static const leaf = Color(0xFF2DCB92);
  static const gold = Color(0xFFFFC83D);
  static const goldLight = Color(0xFFFFE073);
  static const incomeTint = Color(0xFFE8F7F1);
  static const expenseTint = Color(0xFFFDECEB);
  static const profitTint = Color(0xFFEAF3FF);
  static const pendingTint = Color(0xFFFFF2D8);
  static const white = Colors.white;
}

abstract final class AppTheme {
  static const pagePadding = 16.0;
  static const cardRadius = 12.0;
  static const fieldRadius = 9.0;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 13),
      bodySmall: TextStyle(color: AppColors.muted, fontSize: 11),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFFADB2BE), fontSize: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
