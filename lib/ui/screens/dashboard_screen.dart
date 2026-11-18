import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../providers/expense_providers.dart';
import '../../providers/order_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/order_list_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.userName,
    required this.onViewOrders,
    required this.onSignOut,
  });

  final String userName;
  final VoidCallback onViewOrders;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final totalExpenses = expensesAsync.whenOrNull(
      data: (expenses) =>
          expenses.fold<double>(0, (total, expense) => total + expense.amount),
    );
    final completedIncome = ordersAsync.whenOrNull(
      data: (orders) => orders
          .where((order) => order.status == OrderStatus.completed)
          .fold<double>(0, (total, order) => total + order.total),
    );
    final pendingCount = ordersAsync.whenOrNull(
      data: (orders) =>
          orders.where((order) => order.status == OrderStatus.pending).length,
    );
    final metrics = [
      (
        icon: Icons.currency_rupee,
        title: 'Total Income',
        value: completedIncome == null ? '—' : formatCurrency(completedIncome),
        tint: AppColors.incomeTint,
        accent: AppColors.success,
      ),
      (
        icon: Icons.outbound_outlined,
        title: 'Total Expenses',
        value: totalExpenses == null ? '—' : formatCurrency(totalExpenses),
        tint: AppColors.expenseTint,
        accent: AppColors.danger,
      ),
      (
        icon: Icons.bar_chart_rounded,
        title: 'Net Profit',
        value: completedIncome == null
            ? '—'
            : totalExpenses == null
            ? '—'
            : formatCurrency(completedIncome - totalExpenses),
        tint: AppColors.profitTint,
        accent: AppColors.blue,
      ),
      (
        icon: Icons.pending_actions_outlined,
        title: 'Pending Orders',
        value: pendingCount?.toString() ?? '—',
        tint: AppColors.pendingTint,
        accent: AppColors.warning,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 16,
              right: 12,
            ),
            height: 152 + MediaQuery.paddingOf(context).top,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: AppColors.white),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(color: AppColors.white, fontSize: 11),
                      ),
                      Text(
                        '$userName 👋',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(color: AppColors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSignOut,
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout, color: AppColors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: metrics.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.7,
                        ),
                    itemBuilder: (_, index) => MetricCard(
                      icon: metrics[index].icon,
                      title: metrics[index].title,
                      value: metrics[index].value,
                      tint: metrics[index].tint,
                      accent: metrics[index].accent,
                    ),
                  ),
                  if (expensesAsync.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Could not load expense totals: ${expensesAsync.error}',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Orders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: onViewOrders,
                        child: const Text('View All  →'),
                      ),
                    ],
                  ),
                  ordersAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => _DashboardOrdersError(
                      error: error,
                      onRetry: () => ref.invalidate(ordersProvider),
                    ),
                    data: (orders) {
                      final recentOrders = [...orders]
                        ..sort((a, b) => b.date.compareTo(a.date));
                      if (recentOrders.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No orders yet. Add an order to see it here.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: recentOrders
                            .take(3)
                            .map((order) => OrderListTile(order: order))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardOrdersError extends StatelessWidget {
  const _DashboardOrdersError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Could not load orders: $error',
        style: const TextStyle(color: AppColors.danger, fontSize: 11),
      ),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Try again'),
      ),
    ],
  );
}
