import 'package:flutter/material.dart';

import '../../state/business_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_list_tile.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  static const _filters = ['All', 'Material', 'Rent', 'Utilities', 'Other'];

  @override
  Widget build(BuildContext context) {
    final state = BusinessStateScope.of(context);
    final expenses = state.filteredExpenses;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Expenses'),
          Container(
            color: AppColors.white,
            alignment: Alignment.centerLeft,
            child: AppFilterChips(
              options: _filters,
              selected: state.expenseFilter,
              onSelected: state.setExpenseFilter,
            ),
          ),
          Expanded(
            child: expenses.isEmpty
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
                    itemCount: expenses.length,
                    itemBuilder: (_, index) =>
                        ExpenseListTile(expense: expenses[index]),
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
}
