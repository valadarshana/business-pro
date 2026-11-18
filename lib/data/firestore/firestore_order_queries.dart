import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/business_models.dart';

class FirestoreOrderQueries {
  FirestoreOrderQueries(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _orders(String uid) =>
      _firestore.collection('users').doc(uid).collection('orders');

  Stream<List<BusinessOrder>> watchOrders(String uid) => _orders(uid)
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) => BusinessOrder.fromMap(document.id, document.data()),
            )
            .toList(growable: false),
      );

  Future<String> createOrder(String uid, BusinessOrder order) async {
    final document = _orders(uid).doc();
    await document.set({
      ..._orderData(order),
      'productId': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  Future<void> updateOrder(String uid, String id, BusinessOrder order) async {
    await _orders(uid).doc(id).update({
      ..._orderData(order),
      if (order.deliveryDate == null) 'deliveryDate': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOrder(String uid, String id) =>
      _orders(uid).doc(id).delete();

  Map<String, Object?> _orderData(BusinessOrder order) => {
    'customerName': order.customerName.trim(),
    'phoneNumber': order.phoneNumber.trim(),
    'productName': order.productName.trim(),
    'quantity': order.quantity,
    'price': order.unitPrice,
    'totalAmount': order.total,
    'amountPaid': order.amountPaid,
    'pendingAmount': order.outstandingAmount,
    'orderStatus': order.status.name,
    'paymentStatus': order.paymentStatus.name,
    'orderDate': Timestamp.fromDate(order.date),
    if (order.deliveryDate != null)
      'deliveryDate': Timestamp.fromDate(order.deliveryDate!),
    'description': order.description.trim(),
  };
}
