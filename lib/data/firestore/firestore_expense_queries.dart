import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/business_models.dart';

class FirestoreExpenseQueries {
  FirestoreExpenseQueries(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expenses(String uid) =>
      _firestore.collection('users').doc(uid).collection('expenses');

  Stream<List<BusinessExpense>> watchExpenses(String uid) => _expenses(uid)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  BusinessExpense.fromMap(document.id, document.data()),
            )
            .toList(growable: false),
      );

  Future<String> createExpense(String uid, BusinessExpense expense) async {
    final document = _expenses(uid).doc();
    await document.set({
      ..._expenseData(expense),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  Future<void> updateExpense(String uid, String id, BusinessExpense expense) =>
      _expenses(uid).doc(id).update({
        ..._expenseData(expense),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteExpense(String uid, String id) =>
      _expenses(uid).doc(id).delete();

  Map<String, Object?> _expenseData(BusinessExpense expense) => {
    'title': expense.title.trim(),
    'category': expense.category,
    'amount': expense.amount,
    'description': expense.description.trim(),
    'paymentMethod': expense.paymentMethod,
    'date': Timestamp.fromDate(expense.date),
  };
}
