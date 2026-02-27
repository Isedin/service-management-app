import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:service_manegement_app/core/ui/widgets/primary_button.dart';
import '../state/orders_provider.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool isDropoff = true;

  int carpetCount = 0;
  int stairCount = 0;
  int smallBlankets = 0;
  int largeBlankets = 0;

  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova narudžba')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Ime klijenta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text("Klijent donosi (10% popust)"),
              value: isDropoff,
              onChanged: (v) => setState(() => isDropoff = v),
            ),

            const SizedBox(height: 16),

            _counter("Tepisi / staze (broj kom)", carpetCount, (v) {
              setState(() => carpetCount = v);
            }),
            _counter("Gazista (kom)", stairCount, (v) {
              setState(() => stairCount = v);
            }),
            _counter("Deke male (kom)", smallBlankets, (v) {
              setState(() => smallBlankets = v);
            }),
            _counter("Deke velike (kom)", largeBlankets, (v) {
              setState(() => largeBlankets = v);
            }),

            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(onTap: _save, buttontext: 'Sačuvaj'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _counter(String label, int value, void Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(value.toString(), style: const TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      showSnackBar(context, 'Popuni obavezna polja', Colors.red);
      return;
    }

    setState(() => _loading = true);

    await ref
        .read(ordersProvider.notifier)
        .create(
          customerName: _nameCtrl.text.trim(),
          customerPhone: _phoneCtrl.text.trim(),
          mode: isDropoff ? 'dropoff' : 'pickup_delivery',
          carpetCount: carpetCount,
          stairCount: stairCount,
          blanketSmallCount: smallBlankets,
          blanketLargeCount: largeBlankets,
        );

    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
