import 'package:flutter/material.dart';

import '../../models/business_models.dart';
import '../../state/business_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_choice_row.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quantity_stepper.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();

  int _quantity = 1;
  String? _product;
  DateTime _date = DateTime.now();
  OrderStatus _status = OrderStatus.pending;
  PaymentStatus _paymentStatus = PaymentStatus.paid;

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveOrder() {
    if (!_formKey.currentState!.validate()) return;
    final total = double.parse(_priceController.text.trim()) * _quantity;
    BusinessStateScope.of(context).addOrder(
      customerName: _customerController.text,
      phoneNumber: _phoneController.text,
      productName: _product!,
      quantity: _quantity,
      total: total,
      date: _date,
      status: _status,
      paymentStatus: _paymentStatus,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Add Order', showBack: true),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.pagePadding),
                children: [
                  AppTextField(
                    controller: _customerController,
                    label: 'Customer Name *',
                    hint: 'Enter customer name',
                    icon: Icons.person_outline,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  AppDropdownField<String>(
                    value: _product,
                    label: 'Product Name *',
                    icon: Icons.inventory_2_outlined,
                    items: const [
                      DropdownMenuItem(
                        value: 'Product A',
                        child: Text('Product A'),
                      ),
                      DropdownMenuItem(
                        value: 'Product B',
                        child: Text('Product B'),
                      ),
                      DropdownMenuItem(
                        value: 'Product C',
                        child: Text('Product C'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _product = value),
                    validator: (value) =>
                        value == null ? 'Select a product' : null,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Quantity *',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  QuantityStepper(
                    value: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _priceController,
                    label: 'Price per item *',
                    hint: 'Enter price',
                    icon: Icons.currency_rupee,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validAmount,
                  ),
                  const SizedBox(height: 10),
                  AppDateField(
                    value: _date,
                    label: 'Delivery Date',
                    onChanged: (date) => setState(() => _date = date),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppChoiceRow<OrderStatus>(
                    options: OrderStatus.values,
                    selected: _status,
                    labelBuilder: _orderStatusLabel,
                    onSelected: (status) => setState(() => _status = status),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payment Status',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppChoiceRow<PaymentStatus>(
                    options: PaymentStatus.values,
                    selected: _paymentStatus,
                    labelBuilder: _paymentStatusLabel,
                    onSelected: (status) =>
                        setState(() => _paymentStatus = status),
                  ),
                  const SizedBox(height: 18),
                  AppButton(label: 'Save Order', onPressed: _saveOrder),
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
    if (amount == null || amount <= 0) return 'Enter a valid price';
    return null;
  }

  String _orderStatusLabel(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.completed => 'Completed',
    OrderStatus.cancelled => 'Cancelled',
  };

  String _paymentStatusLabel(PaymentStatus status) => switch (status) {
    PaymentStatus.paid => 'Paid',
    PaymentStatus.partial => 'Partial',
    PaymentStatus.unpaid => 'Unpaid',
  };
}
