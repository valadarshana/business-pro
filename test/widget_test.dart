// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:business_pro/main.dart';
import 'package:business_pro/models/business_models.dart';
import 'package:business_pro/state/business_state.dart';

void main() {
  testWidgets('App opens on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BusinessProApp());

    expect(find.text('Business Pro'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Get Started opens login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BusinessProApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login opens the dashboard and bottom navigation switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BusinessProApp());
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

  testWidgets('Adding an order updates the orders list', (
    WidgetTester tester,
  ) async {
    await _loginAndOpenApp(tester);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'New Widget Customer',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product A').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '700');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Order'));
    await tester.pumpAndSettle();

    expect(find.text('New Widget Customer'), findsOneWidget);
    expect(find.text('₹ 700'), findsOneWidget);
  });

  testWidgets('Adding an expense updates the expenses list', (
    WidgetTester tester,
  ) async {
    await _loginAndOpenApp(tester);
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
  });

  test('Business state updates records and dashboard totals', () {
    final state = BusinessState();
    final oldIncome = state.totalIncome;
    final oldExpenseTotal = state.totalExpenses;

    state.addOrder(
      customerName: 'New Customer',
      phoneNumber: '1234567890',
      productName: 'Product A',
      quantity: 2,
      total: 1400,
      date: DateTime(2026, 11, 18),
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.paid,
    );
    state.addExpense(
      title: 'Packaging',
      category: 'Other',
      amount: 250,
      description: 'Boxes',
      paymentMethod: 'Cash',
      date: DateTime(2026, 11, 18),
    );

    expect(state.orders.first.customerName, 'New Customer');
    expect(state.expenses.first.title, 'Packaging');
    expect(state.totalIncome, oldIncome + 1400);
    expect(state.totalExpenses, oldExpenseTotal + 250);
    expect(state.pendingOrderCount, 3);

    state.setOrderFilter('Completed');
    expect(
      state.filteredOrders.every(
        (order) => order.status == OrderStatus.completed,
      ),
      isTrue,
    );
    state.dispose();
  });
}

Future<void> _loginAndOpenApp(WidgetTester tester) async {
  await tester.pumpWidget(const BusinessProApp());
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'owner@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}
