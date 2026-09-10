import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../appliances/domain/entities/appliance.dart';
import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../budget/data/factories/woyofal_tariff_configuration_factory.dart';
import '../../../budget/domain/providers/appliance_tariff_service_provider.dart';

final dashboardProvider = Provider<DashboardSummary>((ref) {
  final active = ref
      .watch(appliancesProvider)
      .appliances
      .where((appliance) => appliance.isActive)
      .toList();
  final consumption = active.fold<double>(
    0,
    (total, appliance) => total + appliance.monthlyConsumptionKwh,
  );
  Appliance? mostConsuming;
  for (final appliance in active) {
    if (mostConsuming == null ||
        appliance.monthlyConsumptionKwh > mostConsuming.monthlyConsumptionKwh) {
      mostConsuming = appliance;
    }
  }
  final result = ref
      .watch(applianceTariffServiceProvider)
      .tariffEngine
      .calculate(
        consumptionKwh: consumption,
        configuration: WoyofalTariffConfigurationFactory.dpp2026(),
      );

  final shares = <ApplianceConsumptionShare>[];
  if (consumption > 0) {
    final sorted = [...active]
      ..sort(
        (a, b) => b.monthlyConsumptionKwh.compareTo(a.monthlyConsumptionKwh),
      );
    for (final appliance in sorted.take(5)) {
      shares.add(
        ApplianceConsumptionShare(
          name: appliance.name,
          consumptionKwh: appliance.monthlyConsumptionKwh,
          percentage: appliance.monthlyConsumptionKwh / consumption * 100,
        ),
      );
    }
    if (sorted.length > 5) {
      final others = sorted
          .skip(5)
          .fold<double>(
            0,
            (total, appliance) => total + appliance.monthlyConsumptionKwh,
          );
      shares.add(
        ApplianceConsumptionShare(
          name: 'Autres',
          consumptionKwh: others,
          percentage: others / consumption * 100,
        ),
      );
    }
  }

  return DashboardSummary(
    activeCount: active.length,
    consumptionKwh: consumption,
    costFcfa: result.totalCost,
    mostConsuming: mostConsuming,
    consumptionShares: List.unmodifiable(shares),
  );
});

class DashboardSummary {
  final int activeCount;
  final double consumptionKwh;
  final double costFcfa;
  final Appliance? mostConsuming;
  final List<ApplianceConsumptionShare> consumptionShares;

  const DashboardSummary({
    required this.activeCount,
    required this.consumptionKwh,
    required this.costFcfa,
    required this.mostConsuming,
    required this.consumptionShares,
  });
}

class ApplianceConsumptionShare {
  final String name;
  final double consumptionKwh;
  final double percentage;

  const ApplianceConsumptionShare({
    required this.name,
    required this.consumptionKwh,
    required this.percentage,
  });
}
