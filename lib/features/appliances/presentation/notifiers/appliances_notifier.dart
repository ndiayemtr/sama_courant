import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/appliance.dart';
import '../../domain/providers/appliance_usecase_providers.dart';
import '../state/appliances_state.dart';

class AppliancesNotifier extends Notifier<AppliancesState> {
  @override
  AppliancesState build() {
    return const AppliancesState();
  }

  Future<void> loadAppliances() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final appliances = await ref.read(getAppliancesProvider)();

      state = state.copyWith(appliances: appliances, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> createAppliance(Appliance appliance) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await ref.read(createApplianceProvider)(appliance);

      await loadAppliances();
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> updateAppliance(Appliance appliance) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updated = await ref.read(updateApplianceProvider)(appliance);

      if (!updated) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Impossible de modifier cet appareil.',
        );
        return;
      }

      await loadAppliances();
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> deleteAppliance(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await ref.read(deleteApplianceProvider)(id);

      await loadAppliances();
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
