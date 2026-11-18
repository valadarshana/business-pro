import 'package:flutter/material.dart';

import '../../models/business_models.dart';
import '../../state/business_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/order_list_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onViewOrders});

  final VoidCallback onViewOrders;

  @override
  Widget build(BuildContext context) {
    final state = BusinessStateScope.of(context);
    final metrics = [
      (
        icon: Icons.currency_rupee,
        title: 'Total Income',
        value: formatCurrency(state.totalIncome),
        tint: AppColors.incomeTint,
        accent: AppColors.success,
      ),
      (
        icon: Icons.outbound_outlined,
        title: 'Total Expenses',
        value: formatCurrency(state.totalExpenses),
        tint: AppColors.expenseTint,
        accent: AppColors.danger,
      ),
      (
        icon: Icons.bar_chart_rounded,
        title: 'Net Profit',
        value: formatCurrency(state.netProfit),
        tint: AppColors.profitTint,
        accent: AppColors.blue,
      ),
      (
        icon: Icons.pending_actions_outlined,
        title: 'Pending Orders',
        value: '${state.pendingOrderCount}',
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
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(color: AppColors.white, fontSize: 11),
                      ),
                      Text(
                        'Darshana Vala 👋',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Welcome back!',
                        style: TextStyle(color: AppColors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppColors.white,
                  ),
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
                  ...state.recentOrders.map(
                    (order) => OrderListTile(order: order),
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
