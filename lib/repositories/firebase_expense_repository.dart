import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/firestore/firestore_expense_queries.dart';
import '../models/business_models.dart';
import 'expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  FirebaseExpenseRepository({
    FirebaseAuth? auth,
    FirestoreExpenseQueries? queries,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _queries =
           queries ?? FirestoreExpenseQueries(FirebaseFirestore.instance);

  final FirebaseAuth _auth;
  final FirestoreExpenseQueries _queries;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in before reading or saving expenses.',
      );
    }
    return uid;
  }

  @override
  Stream<List<BusinessExpense>> watchExpenses() => _queries.watchExpenses(_uid);

  @override
  Future<String> createExpense(BusinessExpense expense) {
    _validateExpense(expense);
    return _queries.createExpense(_uid, expense);
  }

  @override
  Future<void> updateExpense(String id, BusinessExpense expense) {
    _validateId(id);
    _validateExpense(expense);
    return _queries.updateExpense(_uid, id, expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    _validateId(id);
    return _queries.deleteExpense(_uid, id);
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
  }

  void _validateExpense(BusinessExpense expense) {
    if (expense.title.trim().isEmpty ||
        expense.category.trim().isEmpty ||
        expense.paymentMethod.trim().isEmpty ||
        !expense.amount.isFinite ||
        expense.amount <= 0) {
      throw ArgumentError(
        'Expense details must include a title, category, payment method, '
        'and a valid amount.',
      );
    }
  }
}
