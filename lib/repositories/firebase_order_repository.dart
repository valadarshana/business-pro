import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/firestore/firestore_order_queries.dart';
import '../models/business_models.dart';
import 'order_repository.dart';

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository({FirebaseAuth? auth, FirestoreOrderQueries? queries})
    : _auth = auth ?? FirebaseAuth.instance,
      _queries = queries ?? FirestoreOrderQueries(FirebaseFirestore.instance);

  final FirebaseAuth _auth;
  final FirestoreOrderQueries _queries;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Sign in before reading or saving orders.',
      );
    }
    return uid;
  }

  @override
  Stream<List<BusinessOrder>> watchOrders() => _queries.watchOrders(_uid);

  @override
  Future<String> createOrder(BusinessOrder order) {
    _validateOrder(order);
    return _queries.createOrder(_uid, order);
  }

  @override
  Future<void> updateOrder(String id, BusinessOrder order) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
    _validateOrder(order);
    return _queries.updateOrder(_uid, id, order);
  }

  @override
  Future<void> deleteOrder(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
    return _queries.deleteOrder(_uid, id);
  }

  void _validateOrder(BusinessOrder order) {
    if (order.quantity <= 0 ||
        !order.total.isFinite ||
        order.total <= 0 ||
        !order.unitPrice.isFinite ||
        order.unitPrice <= 0 ||
        order.customerName.trim().isEmpty ||
        order.productName.trim().isEmpty) {
      throw ArgumentError(
        'Order details must contain a customer, product, valid quantity, '
        'and price.',
      );
    }
  }
}
