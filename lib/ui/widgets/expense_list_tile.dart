import 'package:flutter/material.dart';

import '../../models/business_models.dart';
import '../../theme/app_theme.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({super.key, required this.expense});

  final BusinessExpense expense;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (expense.category) {
      'Material' => (Icons.inventory_2_outlined, AppColors.warning),
      'Utilities' => (Icons.bolt_rounded, AppColors.blue),
      'Rent' => (Icons.home_outlined, AppColors.warning),
      _ => (Icons.build_rounded, AppColors.blue),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDate(expense.date)} • ${expense.category}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(expense.amount),
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
