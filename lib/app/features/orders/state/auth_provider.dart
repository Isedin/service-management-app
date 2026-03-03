import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/auth/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});
