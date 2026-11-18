import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../providers/expense_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.expense});

  final BusinessExpense? expense;
  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _category;
  String? _paymentMethod;
  DateTime _date = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  static const _categories = ['Material', 'Rent', 'Utilities', 'Other'];
  static const _paymentMethods = ['Cash', 'Card', 'Bank transfer', 'UPI'];

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense == null) return;
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description;
    _category = expense.category;
    _paymentMethod = expense.paymentMethod;
    _date = expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final expense = BusinessExpense(
      id: widget.expense?.id ?? '',
      title: _titleController.text.trim(),
      category: _category!,
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim(),
      paymentMethod: _paymentMethod!,
      date: _date,
    );
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(expenseRepositoryProvider);
      if (widget.expense == null) {
        await repository.createExpense(expense);
      } else {
        await repository.updateExpense(widget.expense!.id, expense);
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage =
              error.message ?? 'Please sign in again before saving an expense.',
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage =
              error.message ?? 'Firestore error (${error.code}).',
        );
      }
    } on ArgumentError catch (error) {
      if (mounted) setState(() => _errorMessage = error.message.toString());
    } on Exception catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: widget.expense == null ? 'Add Expense' : 'Edit Expense',
            showBack: true,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.pagePadding),
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Title *',
                    hint: 'Enter expense title',
                    icon: Icons.edit_note,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  AppDropdownField<String>(
                    value: _category,
                    label: 'Category *',
                    icon: Icons.category_outlined,
                    items: _dropdownItems(_categories, _category),
                    onChanged: (value) => setState(() => _category = value),
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _amountController,
                    label: 'Amount (₹) *',
                    hint: 'Enter amount',
                    icon: Icons.currency_rupee,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validAmount,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Add description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  AppDropdownField<String>(
                    value: _paymentMethod,
                    label: 'Payment Method *',
                    icon: Icons.account_balance_wallet_outlined,
                    items: _dropdownItems(_paymentMethods, _paymentMethod),
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value),
                    validator: (value) =>
                        value == null ? 'Select a payment method' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Bill / Receipt',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Receipt upload is not available yet',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppDateField(
                    value: _date,
                    label: 'Expense Date',
                    onChanged: (date) => setState(() => _date = date),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  AppButton(
                    label: _isSaving
                        ? 'Saving...'
                        : widget.expense == null
                        ? 'Save Expense'
                        : 'Update Expense',
                    onPressed: _isSaving ? null : _saveExpense,
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _validAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }

  List<DropdownMenuItem<String>> _dropdownItems(
    List<String> options,
    String? selected,
  ) {
    final values = [
      ...options,
      if (selected != null && !options.contains(selected)) selected,
    ];
    return values
        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
        .toList();
  }
}
