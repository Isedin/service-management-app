import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/orders/state/business_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_manegement_app/app/features/auth/presentation/login_screen.dart';
import '../state/orders_provider.dart';
import 'orders_list_screen.dart';
import 'order_form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(ordersProvider);
    final bizAsync = ref.watch(businessProvider);

    return Scaffold(
      appBar: AppBar(
        title: bizAsync.when(
          data: (biz) => Text((biz['name'] ?? 'Dashboard').toString()),
          loading: () => const Text('Dashboard'),
          error: (_, __) => const Text('Dashboard'),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              // očisti cached business podatke nakon logout-a
              ref.invalidate(businessProvider);
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
        child: p.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktivni poslovi: ${p.orders.length}'),
                  Text(
                    'Neobrađeni: ${p.orders.where((o) => !o.isFullyMeasured).length}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderFormScreen(),
                            ),
                          );
                        },
                        child: const Text('Nova narudžba'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrdersListScreen(),
                            ),
                          );
                        },
                        child: const Text('Sve narudžbe'),
                      ),
                    ],
                  ),
                  if (p.error != null) ...[
                    const SizedBox(height: 12),
                    Text(p.error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
      ),
    );
  }
}
