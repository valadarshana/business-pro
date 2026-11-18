import '../models/business_models.dart';

abstract interface class ExpenseRepository {
  Stream<List<BusinessExpense>> watchExpenses();

  Future<String> createExpense(BusinessExpense expense);

  Future<void> updateExpense(String id, BusinessExpense expense);

  Future<void> deleteExpense(String id);
}
