import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final businessProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = Supabase.instance.client;

  final bizId = await client.rpc('current_business_id');
  if (bizId == null) throw Exception("No business");

  final biz = await client
      .from('businesses')
      .select('id, name, type')
      .eq('id', bizId)
      .single();

  return (biz as Map).cast<String, dynamic>();
});
