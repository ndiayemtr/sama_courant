import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_label_type.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/monthly_consumption_source.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/domain/services/monthly_consumption_selector.dart';

void main() {
  const selector = MonthlyConsumptionSelector();

  test('priorise une consommation annuelle officielle', () {
    final result = selector.select(
      labelType: ApplianceLabelType.energyLabel,
      energyMetrics: const [
        EnergyConsumptionMetric(
          valueKwh: 216,
          basis: EnergyConsumptionBasis.perYear,
        ),
      ],
      powerWatts: 150,
      powerSource: PowerSource.detected,
      quantity: 1,
      usageDurationMinutes: 1440,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNotNull);
    expect(result!.monthlyKwh, 18);
    expect(result.source, MonthlyConsumptionSource.energyMetric);
  });

  test('multiplie la metrique energetique par la quantite', () {
    final result = selector.select(
      labelType: ApplianceLabelType.energyLabel,
      energyMetrics: const [
        EnergyConsumptionMetric(
          valueKwh: 120,
          basis: EnergyConsumptionBasis.perYear,
        ),
      ],
      powerWatts: null,
      powerSource: null,
      quantity: 2,
    );

    expect(result, isNotNull);
    expect(result!.monthlyKwh, 20);
  });

  test('utilise la puissance pour une plaque technique', () {
    final result = selector.select(
      labelType: ApplianceLabelType.technicalPlate,
      energyMetrics: const [],
      powerWatts: 1000,
      powerSource: PowerSource.detected,
      quantity: 1,
      usageDurationMinutes: 60,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNotNull);
    expect(result!.monthlyKwh, 30);
    expect(result.source, MonthlyConsumptionSource.power);
    expect(result.powerSource, PowerSource.detected);
  });

  test('retombe sur la puissance si la metrique necessite un usage absent', () {
    final result = selector.select(
      labelType: ApplianceLabelType.energyLabel,
      energyMetrics: const [
        EnergyConsumptionMetric(
          valueKwh: 50,
          basis: EnergyConsumptionBasis.per100Cycles,
        ),
      ],
      powerWatts: 1000,
      powerSource: PowerSource.calculated,
      quantity: 1,
      usageDurationMinutes: 60,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNotNull);
    expect(result!.source, MonthlyConsumptionSource.energyMetric);
  });

  test('utilise une puissance estimee comme fallback', () {
    final result = selector.select(
      labelType: ApplianceLabelType.technicalPlate,
      energyMetrics: const [],
      powerWatts: 100,
      powerSource: PowerSource.estimated,
      quantity: 1,
      usageDurationMinutes: 120,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNotNull);
    expect(result!.monthlyKwh, 6);
    expect(result.powerSource, PowerSource.estimated);
  });

  test('retourne null sans metrique exploitable ni puissance', () {
    final result = selector.select(
      labelType: ApplianceLabelType.unknown,
      energyMetrics: const [],
      powerWatts: null,
      powerSource: null,
      quantity: 1,
    );

    expect(result, isNull);
  });

  test('retourne null pour une quantite invalide', () {
    final result = selector.select(
      labelType: ApplianceLabelType.technicalPlate,
      energyMetrics: const [],
      powerWatts: 100,
      powerSource: PowerSource.detected,
      quantity: 0,
      usageDurationMinutes: 60,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNull);
  });
}
