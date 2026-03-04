// u signup flow-u
import 'package:flutter/material.dart';
import 'package:service_manegement_app/app/features/orders/state/auth_provider.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:service_manegement_app/core/ui/widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../business/data/business_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../features/orders/presentation/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() =>
      _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  final _nameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  String _type = 'carpet_cleaning';
  bool _loading = false;

  late final BusinessService _businessService = BusinessService(
    Supabase.instance.client,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreiraj servis'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Ime i prezime (opcionalno)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Naziv servisa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(
                  value: 'carpet_cleaning',
                  child: Text('Servis pranja tepiha'),
                ),
                DropdownMenuItem(
                  value: 'auto_repair',
                  child: Text('Auto servis'),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'carpet_cleaning'),
              decoration: const InputDecoration(
                labelText: 'Tip servisa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(onTap: _create, buttontext: 'Kreiraj'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showSnackBar(context, 'Unesi naziv servisa', Colors.red);
      return;
    }

    setState(() => _loading = true);
    try {
      await _businessService.createBusinessAndOwnerProfile(
        businessName: name,
        businessType: _type,
        fullName: _fullNameCtrl.text.trim().isEmpty
            ? null
            : _fullNameCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Greška: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
