import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../providers/expense_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_list_tile.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key, required this.onSignOut});

  final Future<void> Function() onSignOut;

  static const _filters = [
    ('All', ExpenseListFilter.all),
    ('Material', ExpenseListFilter.material),
    ('Rent', ExpenseListFilter.rent),
    ('Utilities', ExpenseListFilter.utilities),
    ('Other', ExpenseListFilter.other),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(expenseListFilterProvider);
    final expenses = ref.watch(visibleExpensesProvider);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(title: 'Expenses', onSignOut: onSignOut),
          Container(
            color: AppColors.white,
            alignment: Alignment.centerLeft,
            child: AppFilterChips(
              options: _filters.map((filter) => filter.$1).toList(),
              selected: _filterLabel(selectedFilter),
              onSelected: (label) {
                final selected = _filters
                    .firstWhere((filter) => filter.$1 == label)
                    .$2;
                ref.read(expenseListFilterProvider.notifier).select(selected);
              },
            ),
          ),
          Expanded(
            child: expenses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _ExpensesError(
                error: error,
                onRetry: () => ref.invalidate(expensesProvider),
              ),
              data: (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No expenses found',
                      message: 'Try another category or add a new expense.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.pagePadding,
                        vertical: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final expense = items[index];
                        return ExpenseListTile(
                          expense: expense,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddExpenseScreen(expense: expense),
                            ),
                          ),
                          onDelete: () => _deleteExpense(context, ref, expense),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-expense',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _filterLabel(ExpenseListFilter filter) =>
      _filters.firstWhere((item) => item.$2 == filter).$1;

  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
    BusinessExpense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Delete "${expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete expense: $error')),
        );
      }
    }
  }
}

class _ExpensesError extends StatelessWidget {
  const _ExpensesError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.danger,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text('Could not load expenses'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
