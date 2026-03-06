// lib/app/features/auth/state/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProfile {
  final String userId;
  final String businessId;
  final String role; // 'owner' | 'worker'
  final String? fullName;

  MyProfile({
    required this.userId,
    required this.businessId,
    required this.role,
    this.fullName,
  });

  factory MyProfile.fromMap(Map<String, dynamic> m) => MyProfile(
    userId: m['user_id'] as String,
    businessId: m['business_id'] as String,
    role: (m['role'] ?? 'worker').toString(),
    fullName: m['full_name']?.toString(),
  );
}

final myProfileProvider = FutureProvider<MyProfile>((ref) async {
  final client = Supabase.instance.client;
  final uid = client.auth.currentUser?.id;
  if (uid == null) throw Exception('Nisi ulogovan.');

  final data = await client
      .from('profiles')
      .select('user_id, business_id, role, full_name')
      .eq('user_id', uid)
      .single();

  return MyProfile.fromMap(data);
});
