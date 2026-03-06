import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:service_manegement_app/app/features/orders/state/profile_provider.dart';
import 'package:service_manegement_app/app/features/settings/screens/owner_settings_screen.dart';
import 'package:service_manegement_app/app/features/settings/screens/settings_contact_screen.dart';

class SettingsEntryScreen extends ConsumerWidget {
  const SettingsEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text("Postavke")),
        body: Center(child: Text(e.toString())),
      ),
      data: (p) {
        final role = p.role.toLowerCase();
        final isOwner = role == 'owner';

        // Owner vidi full settings, worker vidi samo kontakt telefon.
        return isOwner
            ? const OwnerSettingsScreen()
            : const SettingsContactScreen();
      },
    );
  }
}
