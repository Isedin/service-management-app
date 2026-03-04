import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/order_model.dart';

class OrdersService {
  OrdersService(this._client);
  final SupabaseClient _client;

  Future<List<OrderModel>> fetchOrders({
    String? search,
    int page = 0,
    int pageSize = 50,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    const selectCols =
        'id, customer_name, customer_phone, total_amount, created_at, status, '
        'planned_carpet_count, planned_stair_count, planned_blanket_small_count, planned_blanket_large_count, '
        'measured_carpet_count';

    dynamic data;

    // ✅ SEARCH
    if (search != null && search.trim().isNotEmpty) {
      final s = '%${search.trim()}%';

      data = await _client
          .from('orders')
          .select(selectCols)
          // ✅ Dart: or() postoji na filter builderu, ovdje radi jer tip ostaje filter builder
          .or('customer_name.ilike.$s,customer_phone.ilike.$s')
          .order('created_at', ascending: false)
          .range(from, to);
    } else {
      // ✅ NO SEARCH
      data = await _client
          .from('orders')
          .select(selectCols)
          .order('created_at', ascending: false)
          .range(from, to);
    }

    return (data as List)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();
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

  /// Polja koja ti koristi OrderDetailScreen (line_total, length_m, width_m, created_at...)
  Future<List<Map<String, dynamic>>> fetchOrderItems(String orderId) async {
    final data = await _client
        .from('order_items')
        .select('id, type, length_m, width_m, line_total, created_at')
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

  Future<void> markReadyForPickup(String orderId) async {
    await _client.rpc(
      'mark_order_ready_for_pickup',
      params: {'p_order_id': orderId},
    );
  }

  Future<Map<String, dynamic>> fetchOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select(
          'id, customer_name, customer_phone, total_amount, created_at, status, '
          'planned_carpet_count, planned_stair_count, planned_blanket_small_count, planned_blanket_large_count, '
          'measured_carpet_count',
        )
        .eq('id', orderId)
        .single();

    return (data as Map).cast<String, dynamic>();
  }
}
