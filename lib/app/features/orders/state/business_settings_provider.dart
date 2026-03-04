import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/business/data/business_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final businessServiceProvider = Provider<BusinessService>((ref) {
  return BusinessService(Supabase.instance.client);
});

final businessSettingsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.read(businessServiceProvider);
  return service.loadSettings();
});
