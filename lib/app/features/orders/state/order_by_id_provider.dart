import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order_model.dart';
import 'orders_provider.dart';

final orderByIdProvider = FutureProvider.family<OrderModel, String>((
  ref,
  orderId,
) async {
  final service = ref.read(ordersServiceProvider);

  final list = await service.fetchOrders();

  return list.firstWhere((o) => o.id == orderId);
});
