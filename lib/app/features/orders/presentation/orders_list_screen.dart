import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/orders_provider.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Narudžbe'),
        actions: [
          IconButton(
            onPressed: () => ref.read(ordersProvider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pretraga (ime ili telefon)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(ordersProvider.notifier).setSearch(v),
            ),
          ),
          Expanded(
            child: p.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: p.orders.length,
                    itemBuilder: (_, i) {
                      final o = p.orders[i];
                      final notDone =
                          o.measuredCarpetCount < o.plannedCarpetCount;

                      return ListTile(
                        title: Text(o.customerName),
                        subtitle: Text(
                          '${o.customerPhone} • ${o.status} • ${o.totalAmount.toStringAsFixed(2)} KM',
                        ),
                        trailing: Icon(
                          notDone ? Icons.warning : Icons.check_circle,
                          color: notDone ? Colors.red : Colors.green,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(orderId: o.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
