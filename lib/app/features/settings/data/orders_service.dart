import 'package:supabase_flutter/supabase_flutter.dart';
import '../../settings/data/settings_service.dart';

double roundTo10Fening(double x) => (x * 10).round() / 10.0;

class OrdersService {
  final SupabaseClient _client;
  OrdersService(this._client);

  Future<String> createOrder({
    required String customerId,
    required String mode,
    required int carpetCount,
    required int stairCount,
    required int blanketSmallCount,
    required int blanketLargeCount,
  }) async {
    final businessId = await _client.rpc('current_business_id');

    final order = await _client
        .from('orders')
        .insert({
          'business_id': businessId,
          'customer_id': customerId,
          'mode': mode,
          'planned_carpet_count': carpetCount,
          'planned_stair_count': stairCount,
          'planned_blanket_small_count': blanketSmallCount,
          'planned_blanket_large_count': blanketLargeCount,
          'status': 'received',
        })
        .select()
        .single();

    final orderId = order['id'];

    await _createFixedItems(
      orderId,
      stairCount,
      blanketSmallCount,
      blanketLargeCount,
    );

    await recomputeTotal(orderId);

    return orderId;
  }

  Future<void> _createFixedItems(
    String orderId,
    int stairCount,
    int small,
    int large,
  ) async {
    final settings = await SettingsService(_client).getSettings();
    final businessId = await _client.rpc('current_business_id');

    if (stairCount > 0) {
      final total = roundTo10Fening(stairCount * settings.stairPrice);

      await _client.from('order_items').insert({
        'order_id': orderId,
        'business_id': businessId,
        'type': 'stair',
        'quantity': stairCount,
        'unit_price': settings.stairPrice,
        'line_total': total,
      });
    }

    if (small > 0) {
      final total = roundTo10Fening(small * settings.blanketSmall);

      await _client.from('order_items').insert({
        'order_id': orderId,
        'business_id': businessId,
        'type': 'blanket_small',
        'quantity': small,
        'unit_price': settings.blanketSmall,
        'line_total': total,
      });
    }

    if (large > 0) {
      final total = roundTo10Fening(large * settings.blanketLarge);

      await _client.from('order_items').insert({
        'order_id': orderId,
        'business_id': businessId,
        'type': 'blanket_large',
        'quantity': large,
        'unit_price': settings.blanketLarge,
        'line_total': total,
      });
    }
  }

  Future<void> addMeasuredCarpet({
    required String orderId,
    required double length,
    required double width,
  }) async {
    final settings = await SettingsService(_client).getSettings();
    final businessId = await _client.rpc('current_business_id');

    final area = length * width;
    final total = roundTo10Fening(area * settings.pricePerM2);

    await _client.from('order_items').insert({
      'order_id': orderId,
      'business_id': businessId,
      'type': 'carpet',
      'quantity': 1,
      'length_m': length,
      'width_m': width,
      'area_m2': area,
      'unit_price': settings.pricePerM2,
      'line_total': total,
    });

    await recomputeTotal(orderId);
  }

  Future<void> recomputeTotal(String orderId) async {
    final settings = await SettingsService(_client).getSettings();

    final items = await _client
        .from('order_items')
        .select()
        .eq('order_id', orderId);

    double subtotal = 0;
    for (final item in items) {
      subtotal += (item['line_total'] as num).toDouble();
    }

    subtotal = roundTo10Fening(subtotal);

    final order = await _client
        .from('orders')
        .select()
        .eq('id', orderId)
        .single();

    final isDropoff = order['mode'] == 'dropoff';

    double finalTotal = subtotal;

    if (isDropoff) {
      final discount = roundTo10Fening(subtotal * settings.discountRate);
      finalTotal = roundTo10Fening(subtotal - discount);
    }

    await _client
        .from('orders')
        .update({'total_amount': finalTotal})
        .eq('id', orderId);
  }

  Future<void> closeAndDeleteOrder(String orderId) async {
    await _client.from('orders').delete().eq('id', orderId);
  }
}
