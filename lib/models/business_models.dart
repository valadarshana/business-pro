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

  String get initials {
    final names = customerName.trim().split(RegExp(r'\s+'));
    return names.take(2).map((name) => name[0].toUpperCase()).join();
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
