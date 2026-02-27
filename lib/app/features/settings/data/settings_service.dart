import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessSettings {
  final double pricePerM2;
  final double stairPrice;
  final double blanketSmall;
  final double blanketLarge;
  final double discountRate;

  BusinessSettings({
    required this.pricePerM2,
    required this.stairPrice,
    required this.blanketSmall,
    required this.blanketLarge,
    required this.discountRate,
  });

  factory BusinessSettings.fromMap(Map<String, dynamic> map) {
    return BusinessSettings(
      pricePerM2: (map['price_per_m2'] as num).toDouble(),
      stairPrice: (map['stair_price_per_piece'] as num).toDouble(),
      blanketSmall: (map['blanket_small_price'] as num).toDouble(),
      blanketLarge: (map['blanket_large_price'] as num).toDouble(),
      discountRate: (map['dropoff_discount_rate'] as num).toDouble(),
    );
  }
}

class SettingsService {
  final SupabaseClient _client;
  SettingsService(this._client);

  Future<BusinessSettings> getSettings() async {
    final data = await _client.from('business_settings').select().single();

    return BusinessSettings.fromMap(data);
  }

  Future<void> upsertSettings({
    required double pricePerM2,
    required double stairPrice,
    required double blanketSmall,
    required double blanketLarge,
    required double discountRate,
  }) async {
    final businessId = (await _client.rpc('current_business_id'));

    await _client.from('business_settings').upsert({
      'business_id': businessId,
      'price_per_m2': pricePerM2,
      'stair_price_per_piece': stairPrice,
      'blanket_small_price': blanketSmall,
      'blanket_large_price': blanketLarge,
      'dropoff_discount_rate': discountRate,
    });
  }
}
