import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/orders_service.dart';
import '../domain/order_model.dart';

class OrdersState {
  final bool isLoading;
  final String? error;
  final String searchText;
  final List<OrderModel> orders;

  const OrdersState({
    this.isLoading = false,
    this.error,
    this.searchText = '',
    this.orders = const [],
  });

  OrdersState copyWith({
    bool? isLoading,
    String? error,
    String? searchText,
    List<OrderModel>? orders,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchText: searchText ?? this.searchText,
      orders: orders ?? this.orders,
    );
  }
}

final ordersServiceProvider = Provider<OrdersService>((ref) {
  return OrdersService(Supabase.instance.client);
});

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

class OrdersNotifier extends Notifier<OrdersState> {
  OrdersService get _service => ref.read(ordersServiceProvider);

  @override
  OrdersState build() => const OrdersState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.fetchOrders(search: state.searchText);
      state = state.copyWith(isLoading: false, orders: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String value) {
    state = state.copyWith(searchText: value);
    load();
  }

  Future<void> create({
    required String customerName,
    required String customerPhone,
    required String mode,
    required int carpetCount,
    required int stairCount,
    required int blanketSmallCount,
    required int blanketLargeCount,
  }) async {
    state = state.copyWith(error: null);
    try {
      await _service.createOrder(
        customerName: customerName,
        customerPhone: customerPhone,
        mode: mode,
        carpetCount: carpetCount,
        stairCount: stairCount,
        blanketSmallCount: blanketSmallCount,
        blanketLargeCount: blanketLargeCount,
      );
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMeasuredCarpetCm(
    String orderId,
    double lCm,
    double wCm,
    String itemId,
  ) async {
    state = state.copyWith(error: null);
    try {
      print("ADD CARPET CALLED: $itemId");
      await _service.addMeasuredCarpetCm(
        orderId: orderId,
        lengthCm: lCm,
        widthCm: wCm,
        itemId: itemId,
      );
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> closeAndDelete(String orderId) async {
    state = state.copyWith(error: null);
    try {
      await _service.closeAndDeleteOrder(orderId);
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCarpetItemCm(String itemId, double lCm, double wCm) async {
    state = state.copyWith(error: null);
    try {
      await _service.updateCarpetItemCm(
        itemId: itemId,
        lengthCm: lCm,
        widthCm: wCm,
      );
      await load(); // osvježi orders list (total_amount, itd)
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
