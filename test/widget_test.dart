// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:business_pro/main.dart';
import 'package:business_pro/models/auth_user.dart';
import 'package:business_pro/models/business_models.dart';
import 'package:business_pro/repositories/expense_repository.dart';
import 'package:business_pro/repositories/order_repository.dart';
import 'package:business_pro/services/auth_repository.dart';
import 'package:business_pro/ui/widgets/metric_card.dart';

void main() {
  testWidgets('App opens on splash screen', (WidgetTester tester) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business Pro'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Get Started opens login screen', (WidgetTester tester) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Registration creates an account and opens the app', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Taylor Owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'Taylor Studio');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'taylor@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'secure123');
    await tester.enterText(find.byType(TextFormField).at(4), 'secure123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(auth.registrationCount, 1);
    expect(auth.registeredBusinessName, 'Taylor Studio');
    expect(find.text('Taylor Owner 👋'), findsOneWidget);
    expect(find.text('Recent Orders'), findsOneWidget);
  });

  testWidgets('Registration validates matching passwords', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Taylor Owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'Taylor Studio');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'taylor@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'secure123');
    await tester.enterText(find.byType(TextFormField).at(4), 'different123');
    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create account',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(auth.registrationCount, 0);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Login opens the dashboard and bottom navigation switches tabs', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Recent Orders'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Riya Sharma'), findsOneWidget);
  });

  testWidgets('Orders filter reacts to the live order stream', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Riya Sharma'), findsOneWidget);
    expect(find.text('Amit Patel'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Amit Patel'), findsOneWidget);
    expect(find.text('Riya Sharma'), findsNothing);
  });

  testWidgets('Dashboard metrics and recent orders follow Firestore updates', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await _loginAndOpenApp(tester, orders: orders, expenses: expenses);

    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Total Income'),
        matching: find.text('₹ 1,800'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Pending Orders'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Total Expenses'),
        matching: find.text('₹ 1,200'),
      ),
      findsOneWidget,
    );

    await orders.createOrder(
      BusinessOrder(
        id: '',
        customerName: 'Recent Completed Customer',
        phoneNumber: '',
        productName: 'Candle',
        quantity: 1,
        price: 600,
        total: 600,
        amountPaid: 600,
        pendingAmount: 0,
        date: DateTime.now(),
        status: OrderStatus.completed,
        paymentStatus: PaymentStatus.paid,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Total Income'),
        matching: find.text('₹ 2,400'),
      ),
      findsOneWidget,
    );
    expect(find.text('Recent Completed Customer'), findsOneWidget);

    await expenses.createExpense(
      BusinessExpense(
        id: '',
        title: 'Packaging',
        category: 'Other',
        amount: 250,
        description: '',
        paymentMethod: 'Cash',
        date: DateTime(2026, 11, 18),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Total Expenses'),
        matching: find.text('₹ 1,450'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(MetricCard, 'Net Profit'),
        matching: find.text('₹ 950'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Google sign-in opens the authenticated app', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(auth.googleSignInCount, 1);
    expect(find.text('New Google User 👋'), findsOneWidget);
    expect(find.text('Recent Orders'), findsOneWidget);
  });

  testWidgets('Signing out returns to the splash screen', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(auth.dispose);
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await tester.pumpWidget(
      BusinessProApp(
        authRepository: auth,
        orderRepository: orders,
        expenseRepository: expenses,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(auth.signOutCount, 1);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Adding an order updates the orders list', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    addTearDown(orders.dispose);
    await _loginAndOpenApp(tester, orders: orders);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Amount paid (₹)'), findsNothing);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'New Widget Customer',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Handmade Ceramic Mug',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '700');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Order'));
    await tester.pumpAndSettle();

    expect(find.text('New Widget Customer'), findsOneWidget);
    expect(find.text('₹ 700'), findsOneWidget);
    expect(orders.savedOrders.single.total, 700);
    expect(orders.savedOrders.single.productName, 'Handmade Ceramic Mug');
    expect(orders.savedOrders.single.amountPaid, 0);
    expect(orders.savedOrders.single.pendingAmount, 700);
  });

  testWidgets('An order can be edited and the live list refreshes', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    addTearDown(orders.dispose);
    await _loginAndOpenApp(tester, orders: orders);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actions for Riya Sharma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Order'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(2))
          .controller
          ?.text,
      'Candle',
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Updated Customer',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Personalized Candle Set',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '1300');
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Order'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Customer'), findsOneWidget);
    expect(find.text('Riya Sharma'), findsNothing);
    expect(orders.updatedOrders.single.id, 'order-1');
    expect(orders.updatedOrders.single.productName, 'Personalized Candle Set');
    expect(orders.updatedOrders.single.total, 2600);
  });

  testWidgets('Deleting an order requires confirmation and updates the list', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    addTearDown(orders.dispose);
    await _loginAndOpenApp(tester, orders: orders);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actions for Riya Sharma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete order?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Riya Sharma'), findsNothing);
    expect(find.text('Amit Patel'), findsOneWidget);
    expect(orders.deletedOrderIds, ['order-1']);
  });

  testWidgets('Adding an expense updates the expenses list', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await _loginAndOpenApp(tester, orders: orders, expenses: expenses);
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'New Expense');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '125');
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.text('New Expense'), findsOneWidget);
    expect(find.text('₹ 125'), findsOneWidget);
    expect(expenses.savedExpenses.single.amount, 125);
  });

  testWidgets('An expense can be edited and the live list refreshes', (
    WidgetTester tester,
  ) async {
    final orders = FakeOrderRepository();
    final expenses = FakeExpenseRepository();
    addTearDown(orders.dispose);
    addTearDown(expenses.dispose);
    await _loginAndOpenApp(tester, orders: orders, expenses: expenses);
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actions for Raw Material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Expense'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Updated Material',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '950');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Material'), findsOneWidget);
    expect(find.text('₹ 950'), findsOneWidget);
    expect(expenses.updatedExpenses.single.id, 'expense-1');
    expect(expenses.updatedExpenses.single.amount, 950);
  });

  testWidgets(
    'Deleting an expense requires confirmation and updates the list',
    (WidgetTester tester) async {
      final orders = FakeOrderRepository();
      final expenses = FakeExpenseRepository();
      addTearDown(orders.dispose);
      addTearDown(expenses.dispose);
      await _loginAndOpenApp(tester, orders: orders, expenses: expenses);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Actions for Raw Material'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete expense?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Raw Material'), findsNothing);
      expect(expenses.deletedExpenseIds, ['expense-1']);
    },
  );
}

Future<void> _loginAndOpenApp(
  WidgetTester tester, {
  FakeOrderRepository? orders,
  FakeExpenseRepository? expenses,
}) async {
  final auth = FakeAuthRepository();
  final orderRepository = orders ?? FakeOrderRepository();
  final expenseRepository = expenses ?? FakeExpenseRepository();
  addTearDown(auth.dispose);
  if (orders == null) addTearDown(orderRepository.dispose);
  if (expenses == null) addTearDown(expenseRepository.dispose);
  await tester.pumpWidget(
    BusinessProApp(
      authRepository: auth,
      orderRepository: orderRepository,
      expenseRepository: expenseRepository,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'owner@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository()
    : _orders = [
        BusinessOrder(
          id: 'order-1',
          customerName: 'Riya Sharma',
          phoneNumber: '',
          productName: 'Candle',
          quantity: 2,
          total: 2500,
          date: DateTime(2024, 11, 18),
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.unpaid,
        ),
        BusinessOrder(
          id: 'order-2',
          customerName: 'Amit Patel',
          phoneNumber: '',
          productName: 'Candle',
          quantity: 1,
          total: 1800,
          date: DateTime(2024, 11, 17),
          status: OrderStatus.completed,
          paymentStatus: PaymentStatus.paid,
        ),
      ];

  final List<BusinessOrder> _orders;
  final _changes = StreamController<List<BusinessOrder>>.broadcast(sync: true);
  final List<BusinessOrder> savedOrders = [];
  final List<BusinessOrder> updatedOrders = [];
  final List<String> deletedOrderIds = [];

  @override
  Stream<List<BusinessOrder>> watchOrders() async* {
    yield List.unmodifiable(_orders);
    yield* _changes.stream;
  }

  @override
  Future<String> createOrder(BusinessOrder order) async {
    final saved = _copyOrder(order, id: 'new-${savedOrders.length + 1}');
    savedOrders.add(saved);
    _orders.insert(0, saved);
    _changes.add(List.unmodifiable(_orders));
    return saved.id;
  }

  @override
  Future<void> updateOrder(String id, BusinessOrder order) async {
    final index = _orders.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Order $id was not found.');
    final updated = _copyOrder(order, id: id);
    _orders[index] = updated;
    updatedOrders.add(updated);
    _changes.add(List.unmodifiable(_orders));
  }

  @override
  Future<void> deleteOrder(String id) async {
    final index = _orders.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Order $id was not found.');
    _orders.removeAt(index);
    deletedOrderIds.add(id);
    _changes.add(List.unmodifiable(_orders));
  }

  BusinessOrder _copyOrder(BusinessOrder order, {required String id}) =>
      BusinessOrder(
        id: id,
        customerName: order.customerName,
        phoneNumber: order.phoneNumber,
        productName: order.productName,
        quantity: order.quantity,
        price: order.price,
        total: order.total,
        amountPaid: order.amountPaid,
        pendingAmount: order.pendingAmount,
        date: order.date,
        deliveryDate: order.deliveryDate,
        description: order.description,
        status: order.status,
        paymentStatus: order.paymentStatus,
      );

  void dispose() => _changes.close();
}

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository()
    : _expenses = [
        BusinessExpense(
          id: 'expense-1',
          title: 'Raw Material',
          category: 'Material',
          amount: 1200,
          description: 'Supplies',
          paymentMethod: 'Cash',
          date: DateTime(2026, 11, 18),
        ),
      ];

  final List<BusinessExpense> _expenses;
  final _changes = StreamController<List<BusinessExpense>>.broadcast(
    sync: true,
  );
  final List<BusinessExpense> savedExpenses = [];
  final List<BusinessExpense> updatedExpenses = [];
  final List<String> deletedExpenseIds = [];

  @override
  Stream<List<BusinessExpense>> watchExpenses() async* {
    yield List.unmodifiable(_expenses);
    yield* _changes.stream;
  }

  @override
  Future<String> createExpense(BusinessExpense expense) async {
    final saved = _copyExpense(expense, id: 'new-${savedExpenses.length + 1}');
    savedExpenses.add(saved);
    _expenses.insert(0, saved);
    _changes.add(List.unmodifiable(_expenses));
    return saved.id;
  }

  @override
  Future<void> updateExpense(String id, BusinessExpense expense) async {
    final index = _expenses.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Expense $id was not found.');
    final updated = _copyExpense(expense, id: id);
    _expenses[index] = updated;
    updatedExpenses.add(updated);
    _changes.add(List.unmodifiable(_expenses));
  }

  @override
  Future<void> deleteExpense(String id) async {
    final index = _expenses.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Expense $id was not found.');
    _expenses.removeAt(index);
    deletedExpenseIds.add(id);
    _changes.add(List.unmodifiable(_expenses));
  }

  BusinessExpense _copyExpense(BusinessExpense expense, {required String id}) =>
      BusinessExpense(
        id: id,
        title: expense.title,
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
        paymentMethod: expense.paymentMethod,
        date: expense.date,
      );

  void dispose() => _changes.close();
}

class FakeAuthRepository implements AuthRepository {
  final _authChanges = StreamController<AuthUser?>.broadcast(sync: true);
  AuthUser? _user;
  int googleSignInCount = 0;
  int signOutCount = 0;
  int registrationCount = 0;
  String? registeredBusinessName;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield _user;
    yield* _authChanges.stream;
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _setUser(
      AuthUser(id: 'test-user', email: email, name: email.split('@').first),
    );
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String businessName,
    required String email,
    required String password,
  }) async {
    registrationCount++;
    registeredBusinessName = businessName;
    return _setUser(AuthUser(id: 'test-user', email: email, name: name));
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    googleSignInCount++;
    return _setUser(
      const AuthUser(
        id: 'google-test-user',
        email: 'google@example.com',
        name: 'New Google User',
      ),
    );
  }

  AuthUser _setUser(AuthUser user) {
    _user = user;
    _authChanges.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
    _user = null;
    _authChanges.add(null);
  }

  void dispose() => _authChanges.close();
}
