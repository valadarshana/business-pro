import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, completed, cancelled }

enum PaymentStatus { paid, partial, unpaid }

class BusinessOrder {
  const BusinessOrder({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.productName,
    required this.quantity,
    required this.total,
    required this.date,
    required this.status,
    required this.paymentStatus,
    this.price,
    this.amountPaid = 0,
    this.pendingAmount,
    this.description = '',
    this.deliveryDate,
    this.createdAt,
  });

  final String id;
  final String customerName;
  final String phoneNumber;
  final String productName;
  final int quantity;
  final double total;
  final DateTime date;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double? price;
  final double amountPaid;
  final double? pendingAmount;
  final String description;
  final DateTime? deliveryDate;
  final DateTime? createdAt;

  double get unitPrice => price ?? total / quantity;
  double get outstandingAmount =>
      pendingAmount ?? (total - amountPaid).clamp(0, total).toDouble();

  String get initials {
    final names = customerName.trim().split(RegExp(r'\s+'));
    return names.take(2).map((name) => name[0].toUpperCase()).join();
  }

  factory BusinessOrder.fromMap(String id, Map<String, dynamic> data) {
    final quantity = _asInt(data['quantity'], fallback: 1);
    final total = _asDouble(data['totalAmount'] ?? data['total']);
    final orderDate =
        _asDate(data['orderDate'] ?? data['date']) ?? DateTime.now();
    return BusinessOrder(
      id: id,
      customerName: data['customerName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: quantity > 0 ? quantity : 1,
      total: total,
      date: orderDate,
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['orderStatus'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.name == data['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      price: data['price'] == null ? null : _asDouble(data['price']),
      amountPaid: _asDouble(data['amountPaid']),
      pendingAmount: data['pendingAmount'] == null
          ? null
          : _asDouble(data['pendingAmount']),
      description: data['description'] as String? ?? '',
      deliveryDate: _asDate(data['deliveryDate']),
      createdAt: _asDate(data['createdAt']),
    );
  }
}

class BusinessExpense {
  const BusinessExpense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.description,
    required this.paymentMethod,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final String description;
  final String paymentMethod;
  final DateTime date;

  factory BusinessExpense.fromMap(String id, Map<String, dynamic> data) =>
      BusinessExpense(
        id: id,
        title: data['title'] as String? ?? '',
        category: data['category'] as String? ?? 'Other',
        amount: _asDouble(data['amount']),
        description: data['description'] as String? ?? '',
        paymentMethod: data['paymentMethod'] as String? ?? '',
        date: _asDate(data['date'] ?? data['expenseDate']) ?? DateTime.now(),
      );
}

String formatCurrency(double amount) {
  final wholeAmount = amount.round().toString();
  final formatted = wholeAmount.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '₹ $formatted';
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String formatDateInput(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

double _asDouble(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text) ?? 0,
  _ => 0,
};

int _asInt(Object? value, {required int fallback}) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text) ?? fallback,
  _ => fallback,
};

DateTime? _asDate(Object? value) => switch (value) {
  DateTime date => date,
  Timestamp timestamp => timestamp.toDate(),
  _ => null,
};
