import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/owner_business_settings_provider.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:service_manegement_app/app/features/settings/domain/business_settings_model.dart';



class OwnerSettingsScreen extends ConsumerStatefulWidget {
  const OwnerSettingsScreen({super.key});

  @override
  ConsumerState<OwnerSettingsScreen> createState() =>
      _OwnerSettingsScreenState();
}

class _OwnerSettingsScreenState extends ConsumerState<OwnerSettingsScreen> {
  final _carpet = TextEditingController();
  final _runner = TextEditingController();
  final _stair = TextEditingController();
  final _blanketS = TextEditingController();
  final _blanketL = TextEditingController();
  final _discount = TextEditingController(); // u % (npr 10)
  final _contactPhone = TextEditingController();
  final _smsTemplate = TextEditingController();

  String? _businessId;
  bool _filledOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(ownerBusinessSettingsProvider.notifier).load();
      _fillIfNeeded();
    });
  }

  @override
  void dispose() {
    _carpet.dispose();
    _runner.dispose();
    _stair.dispose();
    _blanketS.dispose();
    _blanketL.dispose();
    _discount.dispose();
    _contactPhone.dispose();
    _smsTemplate.dispose();
    super.dispose();
  }

  void _fillIfNeeded() {
    if (_filledOnce) return;

    final s = ref.read(ownerBusinessSettingsProvider).settings;
    if (s == null) return;

    _businessId = s.businessId;

    _carpet.text = s.carpetPricePerM2.toStringAsFixed(2);
    _runner.text = s.runnerPricePerM2.toStringAsFixed(2);
    _stair.text = s.stairPricePerPiece.toStringAsFixed(2);
    _blanketS.text = s.blanketSmallPrice.toStringAsFixed(2);
    _blanketL.text = s.blanketLargePrice.toStringAsFixed(2);
    _discount.text = (s.dropoffDiscountRate * 100).toStringAsFixed(0);

    _contactPhone.text = s.contactPhone ?? '';
    _smsTemplate.text = s.smsReadyTemplate ?? '';

    _filledOnce = true;
    setState(() {});
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> _save() async {
    final businessId = _businessId;
    if (businessId == null) return;

    final discountPct = _d(_discount);
    final discountRate = (discountPct.clamp(0, 90)) / 100.0;

    final s = BusinessSettings(
      businessId: businessId,
      carpetPricePerM2: _d(_carpet),
      runnerPricePerM2: _d(_runner),
      stairPricePerPiece: _d(_stair),
      blanketSmallPrice: _d(_blanketS),
      blanketLargePrice: _d(_blanketL),
      dropoffDiscountRate: discountRate,
      contactPhone: _contactPhone.text.trim().isEmpty
          ? null
          : _contactPhone.text.trim(),
      smsReadyTemplate: _smsTemplate.text.trim().isEmpty
          ? null
          : _smsTemplate.text.trim(),
    );

    final ok = await ref.read(ownerBusinessSettingsProvider.notifier).save(s);
    if (!mounted) return;

    if (ok) {
      showSnackBar(context, "Postavke sačuvane.", Colors.green);
    } else {
      final err = ref.read(ownerBusinessSettingsProvider).error ?? "Greška.";
      showSnackBar(context, err, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(ownerBusinessSettingsProvider);

    // kad settings dođu, napuni kontrole (samo prvi put)
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillIfNeeded());

    return Scaffold(
      appBar: AppBar(title: const Text('Owner settings')),
      body: st.isLoading && st.settings == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (st.error != null) ...[
                    Text(st.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  _numField(_carpet, "Cijena tepiha po m²"),
                  _numField(_runner, "Cijena staza po m²"),
                  _numField(_stair, "Cijena gazišta po kom"),
                  _numField(_blanketS, "Cijena deke male"),
                  _numField(_blanketL, "Cijena deke velike"),
                  const SizedBox(height: 12),
                  _numField(_discount, "Dropoff popust (%)", hint: "npr 10"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contactPhone,
                    decoration: const InputDecoration(
                      labelText: "Kontakt telefon servisa",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _smsTemplate,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "SMS template (Ready)",
                      hintText:
                          "npr: Poštovani {name}, Vaši tepisi su gotovi...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: st.isLoading ? null : _save,
                      child: st.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Sačuvaj"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _numField(TextEditingController c, String label, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
