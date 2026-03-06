// lib/app/features/settings/data/settings_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Legacy DTO (koristi se samo ako negdje još imaš staru logiku).
/// Bitno: NE zove se BusinessSettings da ne kolizira sa domain modelom.
class LegacyBusinessSettings {
  final double carpetPricePerM2;
  final double stairPricePerPiece;
  final double blanketSmallPrice;
  final double blanketLargePrice;
  final double dropoffDiscountRate;

  LegacyBusinessSettings({
    required this.carpetPricePerM2,
    required this.stairPricePerPiece,
    required this.blanketSmallPrice,
    required this.blanketLargePrice,
    required this.dropoffDiscountRate,
  });

  factory LegacyBusinessSettings.fromMap(Map<String, dynamic> map) {
    double d(dynamic x) =>
        (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0;

    return LegacyBusinessSettings(
      carpetPricePerM2: d(map['carpet_price_per_m2']),
      stairPricePerPiece: d(map['stair_price_per_piece']),
      blanketSmallPrice: d(map['blanket_small_price']),
      blanketLargePrice: d(map['blanket_large_price']),
      dropoffDiscountRate: d(map['dropoff_discount_rate']),
    );
  }
}

class SettingsService {
  final SupabaseClient _client;
  SettingsService(this._client);

  /// Ako ti ovo treba samo za "read", RLS će automatski vratiti settings za current business.
  Future<LegacyBusinessSettings> getLegacySettings() async {
    final data = await _client
        .from('business_settings')
        .select(
          'carpet_price_per_m2, stair_price_per_piece, blanket_small_price, blanket_large_price, dropoff_discount_rate',
        )
        .single();

    return LegacyBusinessSettings.fromMap(data);
  }

  /// Ako ti još negdje treba "upsert", koristi prave kolone.
  Future<void> upsertLegacySettings({
    required double carpetPricePerM2,
    required double stairPricePerPiece,
    required double blanketSmallPrice,
    required double blanketLargePrice,
    required double dropoffDiscountRate,
  }) async {
    final businessId = await _client.rpc('current_business_id');

    await _client.from('business_settings').upsert({
      'business_id': businessId,
      'carpet_price_per_m2': carpetPricePerM2,
      'stair_price_per_piece': stairPricePerPiece,
      'blanket_small_price': blanketSmallPrice,
      'blanket_large_price': blanketLargePrice,
      'dropoff_discount_rate': dropoffDiscountRate,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
