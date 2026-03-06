// lib/app/features/settings/state/business_settings_read_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/settings/data/business_settings_service.dart';
import 'package:service_manegement_app/app/features/settings/domain/business_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Ako već imaš businessSettingsServiceProvider u drugom fajlu,
// možeš ga re-use-ati i obrisati ovaj provider.
final businessSettingsServiceProvider = Provider<BusinessSettingsService>((
  ref,
) {
  return BusinessSettingsService(Supabase.instance.client);
});

/// Read-only settings (auto-fetch). Koristi se za “runtime” cijene/popuste.
final businessSettingsReadProvider = FutureProvider<BusinessSettings>((
  ref,
) async {
  final service = ref.read(businessSettingsServiceProvider);
  return service.fetchMySettings();
});
