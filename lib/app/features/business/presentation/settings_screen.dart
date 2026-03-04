import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/business_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final phoneCtrl = TextEditingController();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(businessSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Postavke servisa")),
      body: settingsAsync.when(
        data: (settings) {
          phoneCtrl.text = settings['contact_phone'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Telefon servisa",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);

                          await ref
                              .read(businessServiceProvider)
                              .updateContactPhone(phoneCtrl.text.trim());

                          ref.invalidate(businessSettingsProvider);

                          if (mounted) {
                            setState(() => saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Postavke spašene")),
                            );
                          }
                        },
                  child: saving
                      ? const CircularProgressIndicator()
                      : const Text("Sačuvaj"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
