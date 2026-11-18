import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_models.dart';
import '../../providers/order_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_choice_row.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quantity_stepper.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key, this.order});

  final BusinessOrder? order;

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _quantity = 1;
  DateTime _deliveryDate = DateTime.now();
  OrderStatus _status = OrderStatus.pending;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    if (order == null) return;
    _customerController.text = order.customerName;
    _phoneController.text = order.phoneNumber;
    _productController.text = order.productName;
    _priceController.text = order.unitPrice.toString();
    _descriptionController.text = order.description;
    _quantity = order.quantity;
    _deliveryDate = order.deliveryDate ?? DateTime.now();
    _status = order.status;
  }

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _productController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text.trim());
    final total = price * _quantity;
    final amountPaid = widget.order?.amountPaid ?? 0;
    final paymentStatus = amountPaid <= 0
        ? PaymentStatus.unpaid
        : amountPaid >= total
        ? PaymentStatus.paid
        : PaymentStatus.partial;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final order = BusinessOrder(
      id: widget.order?.id ?? '',
      customerName: _customerController.text,
      phoneNumber: _phoneController.text,
      productName: _productController.text,
      quantity: _quantity,
      price: price,
      total: total,
      amountPaid: amountPaid,
      pendingAmount: (total - amountPaid).clamp(0, total).toDouble(),
      date: widget.order?.date ?? DateTime.now(),
      deliveryDate: _deliveryDate,
      description: _descriptionController.text,
      status: _status,
      paymentStatus: paymentStatus,
    );
    try {
      final repository = ref.read(orderRepositoryProvider);
      if (widget.order == null) {
        await repository.createOrder(order);
      } else {
        await repository.updateOrder(widget.order!.id, order);
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage =
              error.message ?? 'Please sign in again before saving an order.',
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
            title: widget.order == null ? 'Add Order' : 'Edit Order',
            showBack: true,
          ),
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
                  AppTextField(
                    controller: _productController,
                    label: 'Product Name *',
                    hint: 'Enter product name',
                    icon: Icons.inventory_2_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: _required,
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
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Optional order notes',
                    icon: Icons.description_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  AppDateField(
                    value: _deliveryDate,
                    label: 'Delivery Date',
                    onChanged: (date) => setState(() => _deliveryDate = date),
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
                        : widget.order == null
                        ? 'Save Order'
                        : 'Update Order',
                    onPressed: _isSaving ? null : _saveOrder,
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
    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        !(amount * _quantity).isFinite) {
      return 'Enter a valid price';
    }
    return null;
  }

  String _orderStatusLabel(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.completed => 'Completed',
    OrderStatus.cancelled => 'Cancelled',
  };
}
