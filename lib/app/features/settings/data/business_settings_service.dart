import 'package:service_manegement_app/app/features/settings/domain/business_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessSettingsService {
  BusinessSettingsService(this._client);
  final SupabaseClient _client;

  Future<BusinessSettings> fetchMySettings() async {
    final data = await _client
        .from('business_settings')
        .select(
          'business_id, carpet_price_per_m2, runner_price_per_m2, stair_price_per_piece, '
          'blanket_small_price, blanket_large_price, dropoff_discount_rate, '
          'contact_phone, sms_ready_template',
        )
        .maybeSingle();

    if (data == null) {
      throw Exception('Nema business_settings reda za ovaj business.');
    }

    return BusinessSettings.fromMap(data);
  }

  Future<void> updateMySettings(BusinessSettings s) async {
    await _client
        .from('business_settings')
        .update(s.toUpdateMap())
        .eq('business_id', s.businessId);
  }
}
