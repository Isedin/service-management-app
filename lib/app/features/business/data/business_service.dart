// create business, load business
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessService {
  BusinessService(this._client);
  final SupabaseClient _client;

  Future<void> createBusinessAndOwnerProfile({
    required String businessName,
    required String businessType, // carpet_cleaning | auto_repair
    String? fullName,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception("Not authenticated");
    debugPrint("UID = $uid");
    debugPrint("Session = ${_client.auth.currentSession != null}");

    // 1) create business
    try {
      final business = await _client
          .from('businesses')
          .insert({'name': businessName, 'type': businessType})
          .select()
          .single();

      final businessId = business['id'] as String;

      await _client.from('profiles').insert({
        'user_id': uid,
        'business_id': businessId,
        'full_name': fullName,
        'role': 'owner',
      });
    } catch (e) {
      debugPrint("Create business/profile error: $e");
      rethrow;
    }
  }
}
