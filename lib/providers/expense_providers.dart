import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_models.dart';
import '../repositories/expense_repository.dart';
import '../repositories/firebase_expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => FirebaseExpenseRepository(),
);

final expensesProvider = StreamProvider.autoDispose<List<BusinessExpense>>((
  ref,
) {
  return ref.watch(expenseRepositoryProvider).watchExpenses();
});

enum ExpenseListFilter { all, material, rent, utilities, other }

class ExpenseListFilterNotifier extends Notifier<ExpenseListFilter> {
  @override
  ExpenseListFilter build() => ExpenseListFilter.all;

  void select(ExpenseListFilter filter) => state = filter;
}

final expenseListFilterProvider =
    NotifierProvider<ExpenseListFilterNotifier, ExpenseListFilter>(
      ExpenseListFilterNotifier.new,
    );

final visibleExpensesProvider = Provider<AsyncValue<List<BusinessExpense>>>((
  ref,
) {
  final expenses = ref.watch(expensesProvider);
  final filter = ref.watch(expenseListFilterProvider);
  return expenses.whenData(
    (items) => filter == ExpenseListFilter.all
        ? items
        : items
              .where((expense) => expense.category.toLowerCase() == filter.name)
              .toList(growable: false),
  );
});
