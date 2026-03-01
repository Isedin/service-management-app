import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:service_manegement_app/core/ui/widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/orders_provider.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  Timer? _debounce;
  bool _searching = false;
  List<Map<String, dynamic>> _suggestions = [];

  // ✅ bitno: spriječi da programatsko setovanje teksta okine search
  bool _suppressCustomerSearch = false;

  bool isDropoff = true;

  int carpetCount = 0;
  int stairCount = 0;
  int smallBlankets = 0;
  int largeBlankets = 0;

  bool _loading = false;

  SupabaseClient get _client => Supabase.instance.client;

  bool get _anyCustomerFieldFocused =>
      _nameFocus.hasFocus || _phoneFocus.hasFocus;

  @override
  void initState() {
    super.initState();

    _nameCtrl.addListener(_onCustomerTextChanged);
    _phoneCtrl.addListener(_onCustomerTextChanged);

    // ✅ kad se izgubi fokus sa oba polja, sakrij suggestions
    _nameFocus.addListener(_onFocusChanged);
    _phoneFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_anyCustomerFieldFocused) {
      _hideSuggestions(alsoUnfocus: false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _nameCtrl.removeListener(_onCustomerTextChanged);
    _phoneCtrl.removeListener(_onCustomerTextChanged);

    _nameFocus.removeListener(_onFocusChanged);
    _phoneFocus.removeListener(_onFocusChanged);

    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();

    super.dispose();
  }

  void _onCustomerTextChanged() {
    if (_suppressCustomerSearch) return;

    // koristimo ono polje koje trenutno user kuca (focus),
    // a fallback: ako nema fokusa, uzmi ono koje nije prazno
    final focusedQuery = _nameFocus.hasFocus
        ? _nameCtrl.text
        : _phoneFocus.hasFocus
        ? _phoneCtrl.text
        : (_phoneCtrl.text.trim().isNotEmpty
              ? _phoneCtrl.text
              : _nameCtrl.text);

    final query = focusedQuery.trim();
    _debounce?.cancel();

    if (query.isEmpty || query.length < 2) {
      if (_suggestions.isNotEmpty || _searching) {
        setState(() {
          _suggestions = [];
          _searching = false;
        });
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _searching = true);

      try {
        final data = await _client.rpc(
          'search_customers',
          params: {'p_query': query},
        );

        final list = (data as List).cast<Map<String, dynamic>>();

        if (!mounted) return;
        setState(() {
          // ✅ prikazuj samo ako user i dalje ima fokus u customer poljima
          _suggestions = _anyCustomerFieldFocused ? list.take(8).toList() : [];
          _searching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _searching = false);
      }
    });
  }

  void _selectSuggestion(Map<String, dynamic> c) {
    final fullName = (c['full_name'] ?? '').toString();
    final phone = (c['phone'] ?? '').toString();

    // ✅ ugasi debounce i search odmah
    _debounce?.cancel();

    // ✅ utišaj listener dok postavljaš tekst
    _suppressCustomerSearch = true;

    setState(() {
      _suggestions = [];
      _searching = false;
    });

    _nameCtrl.text = fullName;
    _phoneCtrl.text = phone;

    // ✅ zatvori dropdown i tastaturu; ili prebaci fokus gdje želiš
    FocusScope.of(context).unfocus();

    // ✅ vrati listener u normalu nakon što se UI smiri
    Future.microtask(() {
      _suppressCustomerSearch = false;
    });
  }

  void _hideSuggestions({bool alsoUnfocus = true}) {
    _debounce?.cancel();
    if (_suggestions.isNotEmpty || _searching) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
    }
    if (alsoUnfocus) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _hideSuggestions(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nova narudžba')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                focusNode: _nameFocus,
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Ime klijenta',
                  border: const OutlineInputBorder(),
                  suffixIcon: _searching && _nameFocus.hasFocus
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onSubmitted: (_) => _phoneFocus.requestFocus(),
              ),

              // ✅ Suggestions list prikazuj samo dok user kuca (focus)
              if (_suggestions.isNotEmpty && _anyCustomerFieldFocused) ...[
                const SizedBox(height: 8),
                _SuggestionsCard(
                  suggestions: _suggestions,
                  onTap: _selectSuggestion,
                ),
              ] else
                const SizedBox(height: 10),

              TextField(
                focusNode: _phoneFocus,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Telefon',
                  border: const OutlineInputBorder(),
                  suffixIcon: _searching && _phoneFocus.hasFocus
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
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
    _hideSuggestions(); // ✅ sakrij dropdown prije save

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

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pop(context);
  }
}

class _SuggestionsCard extends StatelessWidget {
  const _SuggestionsCard({required this.suggestions, required this.onTap});

  final List<Map<String, dynamic>> suggestions;
  final void Function(Map<String, dynamic>) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = suggestions[i];
            final name = (c['full_name'] ?? '').toString();
            final phone = (c['phone'] ?? '').toString();

            return ListTile(
              dense: true,
              title: Text(name),
              subtitle: Text(phone),
              onTap: () => onTap(c),
            );
          },
        ),
      ),
    );
  }
}
