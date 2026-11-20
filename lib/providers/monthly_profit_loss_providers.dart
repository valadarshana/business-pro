import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monthly_profit_loss.dart';
import 'expense_providers.dart';
import 'order_providers.dart';

final monthlyProfitLossProvider = Provider<AsyncValue<List<MonthlyProfitLoss>>>(
  (ref) {
    final orders = ref.watch(ordersProvider);
    final expenses = ref.watch(expensesProvider);

    return orders.when(
      data: (orderItems) => expenses.when(
        data: (expenseItems) => AsyncData(
          MonthlyProfitLoss.calculate(
            orders: orderItems,
            expenses: expenseItems,
            currentDate: DateTime.now(),
          ),
        ),
        error: (error, stackTrace) => AsyncError(error, stackTrace),
        loading: () => const AsyncLoading(),
      ),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      loading: () => const AsyncLoading(),
    );
  },
);
