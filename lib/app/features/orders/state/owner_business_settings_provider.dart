import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/features/settings/data/business_settings_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_manegement_app/app/features/settings/domain/business_settings_model.dart';

class OwnerBusinessSettingsState {
  final bool isLoading;
  final String? error;
  final BusinessSettings? settings;

  const OwnerBusinessSettingsState({
    this.isLoading = false,
    this.error,
    this.settings,
  });

  OwnerBusinessSettingsState copyWith({
    bool? isLoading,
    String? error,
    BusinessSettings? settings,
  }) {
    return OwnerBusinessSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      settings: settings ?? this.settings,
    );
  }
}

final businessSettingsServiceProvider = Provider<BusinessSettingsService>((
  ref,
) {
  return BusinessSettingsService(Supabase.instance.client);
});

final ownerBusinessSettingsProvider =
    NotifierProvider<OwnerBusinessSettingsNotifier, OwnerBusinessSettingsState>(
      OwnerBusinessSettingsNotifier.new,
    );

class OwnerBusinessSettingsNotifier
    extends Notifier<OwnerBusinessSettingsState> {
  BusinessSettingsService get _svc => ref.read(businessSettingsServiceProvider);

  @override
  OwnerBusinessSettingsState build() => const OwnerBusinessSettingsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final s = await _svc.fetchMySettings();
      state = state.copyWith(isLoading: false, settings: s);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> save(BusinessSettings s) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _svc.updateMySettings(s);
      state = state.copyWith(isLoading: false, settings: s);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
