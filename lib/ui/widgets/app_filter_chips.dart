import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = selected == option;
          return Center(
            child: ChoiceChip(
              label: Text(option),
              selected: active,
              onSelected: (_) => onSelected(option),
              showCheckmark: false,
              backgroundColor: AppColors.fieldBackground,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: active ? AppColors.white : AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          );
        },
      ),
    );
  }
}
