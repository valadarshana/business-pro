import 'package:flutter/material.dart';

import '../../state/business_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_list_tile.dart';
import 'add_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _filters = ['All', 'Pending', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final state = BusinessStateScope.of(context);
    final orders = state.filteredOrders;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Orders'),
          Container(
            color: AppColors.white,
            alignment: Alignment.centerLeft,
            child: AppFilterChips(
              options: _filters,
              selected: state.orderFilter,
              onSelected: state.setOrderFilter,
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders found',
                    message: 'Try another filter or add a new order.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pagePadding,
                      vertical: 10,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (_, index) =>
                        OrderListTile(order: orders[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-order',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddOrderScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
