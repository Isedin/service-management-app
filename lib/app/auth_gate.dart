import 'package:flutter/material.dart';
import 'package:service_manegement_app/app/features/orders/presentation/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/business/presentation/create_business_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }

        // User is logged in -> check if profile exists
        return FutureBuilder<bool>(
          future: _hasProfile(supabase),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasProfile = snap.data!;
            if (!hasProfile) {
              return const CreateBusinessScreen();
            }

            return const DashboardScreen();
          },
        );
      },
    );
  }

  Future<bool> _hasProfile(SupabaseClient client) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;

    final res = await client
        .from('profiles')
        .select('user_id')
        .eq('user_id', uid)
        .maybeSingle();

    return res != null;
  }
}
  