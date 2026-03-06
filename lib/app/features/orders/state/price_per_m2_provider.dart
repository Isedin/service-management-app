// lib/app/features/orders/state/price_per_m2_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/business_settings_provider.dart';
import 'package:service_manegement_app/core/utils/pricing_helper.dart';

final pricePerM2Provider = Provider<double>((ref) {
  final asyncSettings = ref.watch(businessSettingsProvider);

  return asyncSettings.when(
    data: (data) {
      final v = (data['carpet_price_per_m2'] as num?)?.toDouble();
      return v ?? PricingHelper.defaultPricePerM2;
    },
    loading: () => PricingHelper.defaultPricePerM2,
    error: (_, __) => PricingHelper.defaultPricePerM2,
  );
});
