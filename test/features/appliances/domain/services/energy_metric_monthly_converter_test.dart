import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/domain/services/energy_metric_monthly_converter.dart';

void main() {
  const converter = EnergyMetricMonthlyConverter();

  test('convertit kwh par an directement en kwh par mois', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 216,
      basis: EnergyConsumptionBasis.perYear,
    );

    final result = converter.convert(metric: metric);

    expect(result, 18);
  });

  test('convertit kwh par 100 cycles selon les cycles mensuels', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 50,
      basis: EnergyConsumptionBasis.per100Cycles,
    );

    final result = converter.convert(
      metric: metric,
      usageCount: 3,
      usageFrequency: UsageFrequency.weekly,
    );

    // 3 × 4.33 = 12.99 cycles/mois
    // 50 / 100 × 12.99 = 6.495 kWh/mois
    expect(result, closeTo(6.495, 0.0001));
  });

  test('convertit kwh par cycle selon les cycles mensuels', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 0.8,
      basis: EnergyConsumptionBasis.perCycle,
    );

    final result = converter.convert(
      metric: metric,
      usageCount: 2,
      usageFrequency: UsageFrequency.weekly,
    );

    // 2 × 4.33 = 8.66 cycles/mois
    // 0.8 × 8.66 = 6.928
    expect(result, closeTo(6.928, 0.0001));
  });

  test('convertit kwh par 1000 heures selon les heures mensuelles', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 65,
      basis: EnergyConsumptionBasis.per1000Hours,
    );

    final result = converter.convert(
      metric: metric,
      usageDurationMinutes: 120,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    // 2 h × 30 = 60 h/mois
    // 65 / 1000 × 60 = 3.9
    expect(result, closeTo(3.9, 0.0001));
  });

  test('per100Cycles retourne null sans frequence d utilisation', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 50,
      basis: EnergyConsumptionBasis.per100Cycles,
    );

    final result = converter.convert(metric: metric, usageCount: 3);

    expect(result, isNull);
  });

  test('per1000Hours retourne null sans duree d utilisation', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 65,
      basis: EnergyConsumptionBasis.per1000Hours,
    );

    final result = converter.convert(
      metric: metric,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
    );

    expect(result, isNull);
  });

  test('rejette une metrique invalide', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: -10,
      basis: EnergyConsumptionBasis.perYear,
    );

    expect(converter.convert(metric: metric), isNull);
  });
}
