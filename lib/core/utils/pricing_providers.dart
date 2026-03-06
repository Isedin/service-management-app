import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/business_settings_provider.dart';

/// runtime cijena po m²
final pricePerM2Provider = Provider<double>((ref) {
  final settings = ref.watch(businessSettingsProvider);

  return settings.when(
    data: (data) {
      final price = (data['carpet_price_per_m2'] as num?)?.toDouble();
      return price ?? 3.0;
    },
    loading: () => 3.0,
    error: (_, __) => 3.0,
  );
});
