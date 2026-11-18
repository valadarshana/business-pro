import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_models.dart';
import '../repositories/firebase_order_repository.dart';
import '../repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => FirebaseOrderRepository(),
);

final ordersProvider = StreamProvider.autoDispose<List<BusinessOrder>>((ref) {
  return ref.watch(orderRepositoryProvider).watchOrders();
});

enum OrderListFilter { all, pending, completed, cancelled }

class OrderListFilterNotifier extends Notifier<OrderListFilter> {
  @override
  OrderListFilter build() => OrderListFilter.all;

  void select(OrderListFilter filter) => state = filter;
}

final orderListFilterProvider =
    NotifierProvider<OrderListFilterNotifier, OrderListFilter>(
      OrderListFilterNotifier.new,
    );

final visibleOrdersProvider = Provider<AsyncValue<List<BusinessOrder>>>((ref) {
  final orders = ref.watch(ordersProvider);
  final filter = ref.watch(orderListFilterProvider);
  return orders.whenData(
    (items) => filter == OrderListFilter.all
        ? items
        : items
              .where((order) => order.status.name == filter.name)
              .toList(growable: false),
  );
});
