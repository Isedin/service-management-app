import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersService {
  final SupabaseClient _client;
  CustomersService(this._client);

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final businessId = await _client.rpc('current_business_id');

    final data = await _client
        .from('customers')
        .select('id, full_name, phone')
        .eq('business_id', businessId)
        .or('full_name.ilike.%$q%,phone.ilike.%$q%')
        .order('last_order_at', ascending: false)
        .limit(10);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<String> upsertCustomer({
    required String fullName,
    required String phone,
  }) async {
    final businessId = await _client.rpc('current_business_id');

    final existing = await _client
        .from('customers')
        .select()
        .eq('business_id', businessId)
        .eq('phone', phone)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('customers')
          .update({
            'full_name': fullName,
            'last_order_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);

      return existing['id'];
    }

    final inserted = await _client
        .from('customers')
        .insert({
          'business_id': businessId,
          'full_name': fullName,
          'phone': phone,
          'last_order_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return inserted['id'];
  }
}
