import 'package:flutter/widgets.dart';

import '../models/business_models.dart';

class BusinessState extends ChangeNotifier {
  final List<BusinessOrder> _orders = [
    BusinessOrder(
      id: 'order-1',
      customerName: 'Riya Sharma',
      phoneNumber: '',
      productName: 'Products',
      quantity: 2,
      total: 2500,
      date: DateTime(2024, 11, 18),
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.partial,
    ),
    BusinessOrder(
      id: 'order-2',
      customerName: 'Amit Patel',
      phoneNumber: '',
      productName: 'Products',
      quantity: 1,
      total: 1800,
      date: DateTime(2024, 11, 17),
      status: OrderStatus.completed,
      paymentStatus: PaymentStatus.paid,
    ),
    BusinessOrder(
      id: 'order-3',
      customerName: 'Sneha Desai',
      phoneNumber: '',
      productName: 'Products',
      quantity: 3,
      total: 3200,
      date: DateTime(2024, 11, 16),
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.unpaid,
    ),
    BusinessOrder(
      id: 'order-4',
      customerName: 'Rohit Kumar',
      phoneNumber: '',
      productName: 'Products',
      quantity: 1,
      total: 950,
      date: DateTime(2024, 11, 15),
      status: OrderStatus.completed,
      paymentStatus: PaymentStatus.paid,
    ),
    BusinessOrder(
      id: 'order-5',
      customerName: 'Pooja Verma',
      phoneNumber: '',
      productName: 'Products',
      quantity: 4,
      total: 4500,
      date: DateTime(2024, 11, 14),
      status: OrderStatus.cancelled,
      paymentStatus: PaymentStatus.unpaid,
    ),
  ];

  final List<BusinessExpense> _expenses = [
    BusinessExpense(
      id: 'expense-1',
      title: 'Raw Material',
      category: 'Material',
      amount: 800,
      description: '',
      paymentMethod: 'Cash',
      date: DateTime(2024, 11, 18),
    ),
    BusinessExpense(
      id: 'expense-2',
      title: 'Electricity Bill',
      category: 'Utilities',
      amount: 1200,
      description: '',
      paymentMethod: 'Bank transfer',
      date: DateTime(2024, 11, 15),
    ),
    BusinessExpense(
      id: 'expense-3',
      title: 'Rent',
      category: 'Rent',
      amount: 5000,
      description: '',
      paymentMethod: 'Bank transfer',
      date: DateTime(2024, 11, 1),
    ),
    BusinessExpense(
      id: 'expense-4',
      title: 'Maintenance',
      category: 'Other',
      amount: 750,
      description: '',
      paymentMethod: 'Cash',
      date: DateTime(2024, 10, 28),
    ),
  ];

  String _orderFilter = 'All';
  String _expenseFilter = 'All';

  List<BusinessOrder> get orders => List.unmodifiable(_orders);
  List<BusinessExpense> get expenses => List.unmodifiable(_expenses);
  String get orderFilter => _orderFilter;
  String get expenseFilter => _expenseFilter;

  List<BusinessOrder> get filteredOrders => _orderFilter == 'All'
      ? orders
      : _orders
            .where((order) => _orderStatusLabel(order.status) == _orderFilter)
            .toList(growable: false);

  List<BusinessExpense> get filteredExpenses => _expenseFilter == 'All'
      ? expenses
      : _expenses
            .where((expense) => expense.category == _expenseFilter)
            .toList(growable: false);

  double get totalIncome => _orders
      .where((order) => order.status != OrderStatus.cancelled)
      .fold(0, (total, order) => total + order.total);

  double get totalExpenses =>
      _expenses.fold(0, (total, expense) => total + expense.amount);

  double get netProfit => totalIncome - totalExpenses;

  int get pendingOrderCount =>
      _orders.where((order) => order.status == OrderStatus.pending).length;

  List<BusinessOrder> get recentOrders {
    final sorted = [..._orders]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList(growable: false);
  }

  void setOrderFilter(String filter) {
    if (_orderFilter == filter) return;
    _orderFilter = filter;
    notifyListeners();
  }

  void setExpenseFilter(String filter) {
    if (_expenseFilter == filter) return;
    _expenseFilter = filter;
    notifyListeners();
  }

  void addOrder({
    required String customerName,
    required String phoneNumber,
    required String productName,
    required int quantity,
    required double total,
    required DateTime date,
    required OrderStatus status,
    required PaymentStatus paymentStatus,
  }) {
    _orders.insert(
      0,
      BusinessOrder(
        id: 'order-${DateTime.now().microsecondsSinceEpoch}',
        customerName: customerName.trim(),
        phoneNumber: phoneNumber.trim(),
        productName: productName,
        quantity: quantity,
        total: total,
        date: date,
        status: status,
        paymentStatus: paymentStatus,
      ),
    );
    notifyListeners();
  }

  void addExpense({
    required String title,
    required String category,
    required double amount,
    required String description,
    required String paymentMethod,
    required DateTime date,
  }) {
    _expenses.insert(
      0,
      BusinessExpense(
        id: 'expense-${DateTime.now().microsecondsSinceEpoch}',
        title: title.trim(),
        category: category,
        amount: amount,
        description: description.trim(),
        paymentMethod: paymentMethod,
        date: date,
      ),
    );
    notifyListeners();
  }
}

String _orderStatusLabel(OrderStatus status) => switch (status) {
  OrderStatus.pending => 'Pending',
  OrderStatus.completed => 'Completed',
  OrderStatus.cancelled => 'Cancelled',
};

class BusinessStateScope extends InheritedNotifier<BusinessState> {
  const BusinessStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static BusinessState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BusinessStateScope>();
    assert(scope != null, 'BusinessStateScope is missing from this context.');
    return scope!.notifier!;
  }
}
