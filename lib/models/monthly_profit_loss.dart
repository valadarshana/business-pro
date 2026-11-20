import 'business_models.dart';

class MonthlyProfitLoss {
  const MonthlyProfitLoss({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final DateTime month;
  final double income;
  final double expenses;

  double get net => income - expenses;

  String get label {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  static List<MonthlyProfitLoss> calculate({
    required List<BusinessOrder> orders,
    required List<BusinessExpense> expenses,
    required DateTime currentDate,
  }) {
    final totals = <DateTime, ({double income, double expenses})>{};

    void addIncome(DateTime date, double amount) {
      final month = DateTime(date.year, date.month);
      final current = totals[month] ?? (income: 0.0, expenses: 0.0);
      totals[month] = (
        income: current.income + amount,
        expenses: current.expenses,
      );
    }

    void addExpense(DateTime date, double amount) {
      final month = DateTime(date.year, date.month);
      final current = totals[month] ?? (income: 0.0, expenses: 0.0);
      totals[month] = (
        income: current.income,
        expenses: current.expenses + amount,
      );
    }

    for (final order in orders) {
      if (order.status == OrderStatus.completed) {
        addIncome(order.date, order.total);
      }
    }
    for (final expense in expenses) {
      addExpense(expense.date, expense.amount);
    }

    final currentMonth = DateTime(currentDate.year, currentDate.month);
    totals.putIfAbsent(currentMonth, () => (income: 0.0, expenses: 0.0));

    final months =
        totals.keys.where((month) => !month.isAfter(currentMonth)).toList()
          ..sort((a, b) => b.compareTo(a));
    return months
        .map(
          (month) => MonthlyProfitLoss(
            month: month,
            income: totals[month]!.income,
            expenses: totals[month]!.expenses,
          ),
        )
        .toList(growable: false);
  }
}
