import 'package:flutter/material.dart';

import '../../state/business_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _category;
  String? _paymentMethod;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    BusinessStateScope.of(context).addExpense(
      title: _titleController.text,
      category: _category!,
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text,
      paymentMethod: _paymentMethod!,
      date: _date,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Add Expense', showBack: true),
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
                    items: const [
                      DropdownMenuItem(
                        value: 'Material',
                        child: Text('Material'),
                      ),
                      DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                      DropdownMenuItem(
                        value: 'Utilities',
                        child: Text('Utilities'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
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
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                      DropdownMenuItem(
                        value: 'Bank transfer',
                        child: Text('Bank transfer'),
                      ),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    ],
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
                  AppButton(label: 'Save Expense', onPressed: _saveExpense),
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
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }
}
