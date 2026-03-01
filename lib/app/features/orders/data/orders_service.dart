import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/order_model.dart';

class OrdersService {
  OrdersService(this._client);
  final SupabaseClient _client;
  // final _uuid = const Uuid();

  Future<List<OrderModel>> fetchOrders({String? search}) async {
    final data = await _client
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    final list = (data as List)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();

    if (search == null || search.trim().isEmpty) return list;
    final s = search.trim().toLowerCase();

    return list.where((o) {
      return o.customerName.toLowerCase().contains(s) ||
          o.customerPhone.toLowerCase().contains(s);
    }).toList();
  }

  Future<void> createOrder({
    required String customerName,
    required String customerPhone,
    required String mode,
    required int carpetCount,
    required int stairCount,
    required int blanketSmallCount,
    required int blanketLargeCount,
  }) async {
    await _client.rpc(
      'create_order',
      params: {
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_mode': mode,
        'p_planned_carpet_count': carpetCount,
        'p_planned_stair_count': stairCount,
        'p_planned_blanket_small_count': blanketSmallCount,
        'p_planned_blanket_large_count': blanketLargeCount,
      },
    );
  }

  Future<void> addMeasuredCarpetCm({
    required String orderId,
    required double lengthCm,
    required double widthCm,
    required String itemId,
  }) async {
    await _client.rpc(
      'add_measured_carpet_cm',
      params: {
        'p_order_id': orderId,
        'p_length_cm': lengthCm,
        'p_width_cm': widthCm,
        'p_item_id': itemId,
      },
    );
  }

  Future<void> closeAndDeleteOrder(String orderId) async {
    await _client.rpc(
      'close_and_delete_order',
      params: {'p_order_id': orderId},
    );
  }

  Future<List<Map<String, dynamic>>> fetchOrderItems(String orderId) async {
    final data = await _client
        .from('order_items')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateCarpetItemCm({
    required String itemId,
    required double lengthCm,
    required double widthCm,
  }) async {
    await _client.rpc(
      'update_carpet_item_cm',
      params: {
        'p_item_id': itemId,
        'p_length_cm': lengthCm,
        'p_width_cm': widthCm,
      },
    );
  }
}
