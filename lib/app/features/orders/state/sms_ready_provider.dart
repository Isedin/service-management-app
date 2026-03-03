import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kSmsFunctionName =
    'rapid-endpoint'; // <-- TAČNO ime iz Supabase UI

class SmsReadyState {
  final bool isLoading;
  final bool alreadySent;
  final DateTime? sentAt;
  final String? error;

  const SmsReadyState({
    this.isLoading = false,
    this.alreadySent = false,
    this.sentAt,
    this.error,
  });

  SmsReadyState copyWith({
    bool? isLoading,
    bool? alreadySent,
    DateTime? sentAt,
    String? error,
  }) {
    return SmsReadyState(
      isLoading: isLoading ?? this.isLoading,
      alreadySent: alreadySent ?? this.alreadySent,
      sentAt: sentAt ?? this.sentAt,
      error: error,
    );
  }
}

final smsReadyProvider = NotifierProvider<SmsReadyNotifier, SmsReadyState>(
  SmsReadyNotifier.new,
);

class SmsReadyNotifier extends Notifier<SmsReadyState> {
  SupabaseClient get _client => Supabase.instance.client;

  String? _orderId;

  @override
  SmsReadyState build() => const SmsReadyState();

  /// Pozovi kad uđeš na OrderDetailScreen
  Future<void> init(String orderId) async {
    // ako je isti order, ne moraš ponovo
    if (_orderId == orderId && (state.alreadySent || state.sentAt != null)) {
      return;
    }
    _orderId = orderId;
    await loadStatus();
  }

  Future<void> loadStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    print("LOAD STATUS session null? ${session == null}");

    if (session == null) {
      state = state.copyWith(isLoading: false, error: "Nisi prijavljen.");
      return;
    }

    final orderId = _orderId;
    if (orderId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _client.functions.invoke(
        kSmsFunctionName,
        body: {'order_id': orderId, 'dry_run': true},
      );

      final data = (res.data as Map).cast<String, dynamic>();

      final alreadySent = (data['already_sent'] ?? false) as bool;
      final sentAtRaw = data['sent_at'];
      final sentAt = sentAtRaw != null
          ? DateTime.tryParse(sentAtRaw.toString())
          : null;

      state = state.copyWith(
        isLoading: false,
        alreadySent: alreadySent,
        sentAt: sentAt,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> send({String? message}) async {
    // ✅ Debug: da vidimo ima li JWT
    final session = Supabase.instance.client.auth.currentSession;
    print("SESSION is null? ${session == null}");
    if (session != null) {
      final token = session.accessToken;
      print("JWT prefix: ${token.substring(0, 20)}...");
    }

    // ✅ ako nema sessiona, nema ni JWT -> 401
    if (session == null) {
      state = state.copyWith(
        isLoading: false,
        error: "Nisi prijavljen (nema sessiona).",
      );
      return false;
    }

    // ✅ opcionalno: refresh (dobro ako token zna isteći)
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (e) {
      print("refreshSession error: $e");
    }

    if (state.isLoading || state.alreadySent) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      print("SMS invoke orderId: $_orderId");
      final res = await _client.functions.invoke(
        kSmsFunctionName, // npr 'rapid-endpoint'
        body: {
          'order_id': _orderId,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
      );

      final data = (res.data as Map).cast<String, dynamic>();

      final ok = (data['ok'] ?? false) as bool;
      final alreadySent = (data['already_sent'] ?? false) as bool;
      final sentAtRaw = data['sent_at'];
      final sentAt = sentAtRaw != null
          ? DateTime.tryParse(sentAtRaw.toString())
          : null;

      state = state.copyWith(
        isLoading: false,
        alreadySent: alreadySent || ok,
        sentAt: sentAt,
        error: ok ? null : (data['error']?.toString() ?? 'Unknown error'),
      );

      return ok;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
