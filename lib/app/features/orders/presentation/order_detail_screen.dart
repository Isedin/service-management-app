import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/data/orders_service.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:uuid/uuid.dart';

import '../state/orders_provider.dart';
import '../state/sms_ready_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late final OrdersService _service;

  @override
  void initState() {
    super.initState();
    _service = ref.read(ordersServiceProvider);

    // ✅ init SMS state za ovaj order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsReadyProvider.notifier).init(widget.orderId);
    });
  }

  String _hhmm(DateTime dt) {
    final t = dt.toLocal();
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    print("ORDER DETAIL orderId: ${widget.orderId}");
    final p = ref.watch(ordersProvider);

    final order = p.orders.any((x) => x.id == widget.orderId)
        ? p.orders.firstWhere((x) => x.id == widget.orderId)
        : null;

    if (p.isLoading && order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalji')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Narudžba nije pronađena (možda je obrisana).'),
        ),
      );
    }

    final notDone = order.measuredCarpetCount < order.plannedCarpetCount;
    final canAddCarpet = order.measuredCarpetCount < order.plannedCarpetCount;
    final canClose = !canAddCarpet; // tek kad su svi tepisi uneseni

    final smsState = ref.watch(smsReadyProvider);
    final smsNotifier = ref.read(smsReadyProvider.notifier);

    String label = "Pošalji SMS: Tepisi gotovi";
    if (smsState.alreadySent && smsState.sentAt != null) {
      final t = smsState.sentAt!.toLocal();
      label = "Poslano u ${_hhmm(t)}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _closeOrder),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Klijent: ${order.customerName}',
                style: const TextStyle(fontSize: 18),
              ),
              Text('Telefon: ${order.customerPhone}'),
              const SizedBox(height: 12),
              Text(
                "Tepisi izmjereno: ${order.measuredCarpetCount}/${order.plannedCarpetCount}",
                style: TextStyle(color: notDone ? Colors.red : Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                "Gazista: ${order.plannedStairCount} • "
                "Deke male: ${order.plannedBlanketSmallCount} • "
                "Deke velike: ${order.plannedBlanketLargeCount}",
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<Map<String, dynamic>>>(
                key: ValueKey(
                  'items-${order.measuredCarpetCount}-${order.totalAmount}',
                ),
                future: _service.fetchOrderItems(widget.orderId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Greška pri učitavanju stavki: ${snap.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final items = snap.data ?? [];
                  if (items.isEmpty)
                    return const Text("Nema unesenih stavki još.");

                  num sumType(String type) => items
                      .where((x) => x['type'] == type)
                      .fold<num>(
                        0,
                        (s, e) => s + ((e['line_total'] as num?) ?? 0),
                      );

                  final carpets = items
                      .where((x) => x['type'] == 'carpet')
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Stavke",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (carpets.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _rowLine("Tepih (cm)", "Iznos", bold: true),
                                const Divider(),
                                ...carpets.map((c) {
                                  final lCm =
                                      ((((c['length_m'] as num?) ?? 0) * 100))
                                          .round();
                                  final wCm =
                                      ((((c['width_m'] as num?) ?? 0) * 100))
                                          .round();
                                  final total =
                                      (((c['line_total'] as num?) ?? 0))
                                          .toStringAsFixed(2);

                                  return InkWell(
                                    onTap: () => _editCarpetDialog(
                                      itemId: c['id'].toString(),
                                      currentLCm: lCm.toDouble(),
                                      currentWCm: wCm.toDouble(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("$lCm x $wCm cm"),
                                          Text("$total KM"),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                      _rowLine(
                        "Gazista",
                        "${sumType('stair').toStringAsFixed(2)} KM",
                      ),
                      _rowLine(
                        "Deke male",
                        "${sumType('blanket_small').toStringAsFixed(2)} KM",
                      ),
                      _rowLine(
                        "Deke velike",
                        "${sumType('blanket_large').toStringAsFixed(2)} KM",
                      ),

                      const Divider(height: 24),
                      _rowLine(
                        "TOTAL",
                        "${order.totalAmount.toStringAsFixed(2)} KM",
                        bold: true,
                      ),

                      if (p.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          p.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1) Add carpet
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAddCarpet ? _addCarpetDialog : null,
                  child: const Text("Dodaj izmjeren tepih (cm)"),
                ),
              ),
              const SizedBox(height: 12),

              // 2) SMS button (samo kad je order “gotov”)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      (!canClose || smsState.isLoading || smsState.alreadySent)
                      ? null
                      : () async {
                          final ok = await smsNotifier.send();

                          if (!context.mounted) return;

                          if (ok) {
                            showSnackBar(
                              context,
                              "SMS poslan klijentu.",
                              Colors.green,
                            );
                          } else {
                            showSnackBar(
                              context,
                              smsState.error ?? "Greška pri slanju SMS-a.",
                              Colors.red,
                            );
                          }
                        },
                  icon: smsState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sms),
                  label: Text(label),
                ),
              ),
              const SizedBox(height: 12),

              // 3) Close
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canClose ? _closeOrder : null,
                  child: const Text("Zaključi narudžbu (obriši)"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _rowLine(String left, String right, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: style),
          Text(right, style: style),
        ],
      ),
    );
  }

  void _addCarpetDialog() {
    final lengthCtrl = TextEditingController();
    final widthCtrl = TextEditingController();

    final itemId = const Uuid().v4();
    bool saving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          Future<void> submit() async {
            if (saving) return;

            saving = true;
            setLocal(() {});

            final l = double.tryParse(lengthCtrl.text.trim()) ?? 0;
            final w = double.tryParse(widthCtrl.text.trim()) ?? 0;

            if (l <= 0 || w <= 0) {
              saving = false;
              setLocal(() {});
              return;
            }

            try {
              await ref
                  .read(ordersProvider.notifier)
                  .addMeasuredCarpetCm(widget.orderId, l, w, itemId);

              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (_) {
              saving = false;
              if (context.mounted) setLocal(() {});
            }
          }

          return AlertDialog(
            title: const Text("Dimenzije tepiha (cm)"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: widthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Širina (cm)"),
                ),
                TextField(
                  controller: lengthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Dužina (cm)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text("Odustani"),
              ),
              ElevatedButton(
                onPressed: saving ? null : submit,
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Spremi"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editCarpetDialog({
    required String itemId,
    required double currentLCm,
    required double currentWCm,
  }) {
    final lengthCtrl = TextEditingController(
      text: currentLCm.toStringAsFixed(0),
    );
    final widthCtrl = TextEditingController(
      text: currentWCm.toStringAsFixed(0),
    );
    bool saving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text("Ispravi dimenzije (cm)"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: widthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Širina (cm)"),
                ),
                TextField(
                  controller: lengthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Dužina (cm)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text("Odustani"),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final l = double.tryParse(lengthCtrl.text.trim()) ?? 0;
                        final w = double.tryParse(widthCtrl.text.trim()) ?? 0;
                        if (l <= 0 || w <= 0) return;

                        setLocal(() => saving = true);

                        await ref
                            .read(ordersProvider.notifier)
                            .updateCarpetItemCm(itemId, l, w);

                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Spremi"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _closeOrder() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Zaključiti narudžbu?"),
        content: const Text("Jeste li sigurni? Ovo će obrisati narudžbu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NE"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(ordersProvider.notifier)
                  .closeAndDelete(widget.orderId);
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("DA"),
          ),
        ],
      ),
    );
  }
}
