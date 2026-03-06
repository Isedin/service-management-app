import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/settings/screens/settings_entry_screen.dart';
import 'package:service_manegement_app/app/features/orders/state/profile_provider.dart';
import '../state/orders_provider.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(ordersProvider);

    return Scaffold(
      drawer: Drawer(
        child: Consumer(
          builder: (context, ref, _) {
            final prof = ref.watch(myProfileProvider);

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    "Menu",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                prof.when(
                  data: (profile) => profile.role == 'owner'
                      ? ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text("Settings"),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsEntryScreen(),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Narudžbe'),
        actions: [
          IconButton(
            onPressed: () => ref.read(ordersProvider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Pretraga (ime ili telefon)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) =>
                    ref.read(ordersProvider.notifier).setSearch(v),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                          FocusScope.of(context).unfocus();
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
                  if (p.isLoading)
                    const IgnorePointer(
                      ignoring: true,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (p.error != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              p.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
