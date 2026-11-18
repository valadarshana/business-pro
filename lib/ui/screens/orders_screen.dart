import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../providers/order_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_list_tile.dart';
import 'add_order_screen.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key, required this.onSignOut});

  final Future<void> Function() onSignOut;

  static const _filters = [
    ('All', OrderListFilter.all),
    ('Pending', OrderListFilter.pending),
    ('Completed', OrderListFilter.completed),
    ('Cancelled', OrderListFilter.cancelled),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(orderListFilterProvider);
    final orders = ref.watch(visibleOrdersProvider);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(title: 'Orders', onSignOut: onSignOut),
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
                ref.read(orderListFilterProvider.notifier).select(selected);
              },
            ),
          ),
          Expanded(
            child: orders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _OrdersError(
                error: error,
                onRetry: () => ref.invalidate(ordersProvider),
              ),
              data: (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders found',
                      message:
                          'There are no orders for this filter. Add an order to get started.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.pagePadding,
                        vertical: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final order = items[index];
                        return OrderListTile(
                          order: order,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddOrderScreen(order: order),
                            ),
                          ),
                          onDelete: () => _deleteOrder(context, ref, order),
                        );
                      },
                    ),
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

  String _filterLabel(OrderListFilter filter) => switch (filter) {
    OrderListFilter.all => 'All',
    OrderListFilter.pending => 'Pending',
    OrderListFilter.completed => 'Completed',
    OrderListFilter.cancelled => 'Cancelled',
  };

  Future<void> _deleteOrder(
    BuildContext context,
    WidgetRef ref,
    BusinessOrder order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete order?'),
        content: Text(
          'Delete the order for ${order.customerName}? This cannot be undone.',
        ),
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
      await ref.read(orderRepositoryProvider).deleteOrder(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order deleted')));
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete order: $error')),
        );
      }
    }
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const Text(
              'Could not load orders',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 12),
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
}
