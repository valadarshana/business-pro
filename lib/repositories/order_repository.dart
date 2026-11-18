import '../models/business_models.dart';

abstract interface class OrderRepository {
  Stream<List<BusinessOrder>> watchOrders();

  Future<String> createOrder(BusinessOrder order);

  Future<void> updateOrder(String id, BusinessOrder order);

  Future<void> deleteOrder(String id);
}
