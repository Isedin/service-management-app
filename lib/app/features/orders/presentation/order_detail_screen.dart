import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/orders_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final p = ref.watch(ordersProvider);

    final o = p.orders.where((x) => x.id == widget.orderId).cast().toList();
    final order = o.isNotEmpty ? o.first : null;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _closeOrder),
        ],
      ),
      body: Padding(
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
            const SizedBox(height: 12),

            Text(
              "Gazista: ${order.plannedStairCount} • Deke male: ${order.plannedBlanketSmallCount} • Deke velike: ${order.plannedBlanketLargeCount}",
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _addCarpetDialog,
              child: const Text("Dodaj izmjeren tepih (cm)"),
            ),

            const SizedBox(height: 16),

            Text(
              "Ukupno: ${order.totalAmount.toStringAsFixed(2)} KM",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            if (p.error != null) ...[
              const SizedBox(height: 12),
              Text(p.error!, style: const TextStyle(color: Colors.red)),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _closeOrder,
                child: const Text("Zaključi narudžbu (obriši)"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCarpetDialog() {
    final lengthCtrl = TextEditingController();
    final widthCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dimenzije tepiha (cm)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lengthCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Dužina (cm)"),
            ),
            TextField(
              controller: widthCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Širina (cm)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          TextButton(
            onPressed: () async {
              final l = double.tryParse(lengthCtrl.text.trim()) ?? 0;
              final w = double.tryParse(widthCtrl.text.trim()) ?? 0;

              await ref
                  .read(ordersProvider.notifier)
                  .addMeasuredCarpetCm(widget.orderId, l, w);

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Spremi"),
          ),
        ],
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
