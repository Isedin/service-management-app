import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/business_settings_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/features/orders/state/orders_provider.dart';
import '../../app/features/orders/state/business_provider.dart';

Future<void> performLogout(WidgetRef ref) async {
  // očisti sve cached podatke
  ref.invalidate(businessProvider);
  ref.invalidate(ordersProvider);
  ref.invalidate(businessSettingsProvider);

  // logout sa svih uređaja
  await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
}
