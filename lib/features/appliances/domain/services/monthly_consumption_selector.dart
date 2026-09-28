import '../entities/appliance_label_type.dart';
import '../entities/energy_consumption_metric.dart';
import '../entities/monthly_consumption_result.dart';
import '../entities/monthly_consumption_source.dart';
import '../entities/power_source.dart';
import '../entities/usage_frequency.dart';
import 'energy_metric_monthly_converter.dart';
import 'energy_metric_selector.dart';

class MonthlyConsumptionSelector {
  final EnergyMetricSelector energyMetricSelector;
  final EnergyMetricMonthlyConverter energyMetricConverter;

  const MonthlyConsumptionSelector({
    this.energyMetricSelector = const EnergyMetricSelector(),
    this.energyMetricConverter = const EnergyMetricMonthlyConverter(),
  });

  MonthlyConsumptionResult? select({
    required ApplianceLabelType labelType,
    required List<EnergyConsumptionMetric> energyMetrics,
    required double? powerWatts,
    required PowerSource? powerSource,
    required int quantity,
    int? usageDurationMinutes,
    int? usageCount,
    UsageFrequency? usageFrequency,
  }) {
    if (quantity <= 0) {
      return null;
    }

    final canUseEnergyMetric =
        labelType == ApplianceLabelType.energyLabel ||
        labelType == ApplianceLabelType.mixed;

    if (canUseEnergyMetric) {
      final metric = energyMetricSelector.selectPreferred(energyMetrics);

      if (metric != null) {
        final monthlyKwh = energyMetricConverter.convert(
          metric: metric,
          usageDurationMinutes: usageDurationMinutes,
          usageCount: usageCount,
          usageFrequency: usageFrequency,
        );

        if (monthlyKwh != null && monthlyKwh.isFinite && monthlyKwh > 0) {
          return MonthlyConsumptionResult(
            monthlyKwh: monthlyKwh * quantity,
            source: MonthlyConsumptionSource.energyMetric,
            energyMetric: metric,
          );
        }
      }
    }

    final powerMonthlyKwh = _calculateFromPower(
      powerWatts: powerWatts,
      quantity: quantity,
      usageDurationMinutes: usageDurationMinutes,
      usageCount: usageCount,
      usageFrequency: usageFrequency,
    );

    if (powerMonthlyKwh == null) {
      return null;
    }

    return MonthlyConsumptionResult(
      monthlyKwh: powerMonthlyKwh,
      source: MonthlyConsumptionSource.power,
      powerSource: powerSource,
    );
  }

  double? _calculateFromPower({
    required double? powerWatts,
    required int quantity,
    required int? usageDurationMinutes,
    required int? usageCount,
    required UsageFrequency? usageFrequency,
  }) {
    if (powerWatts == null ||
        !powerWatts.isFinite ||
        powerWatts <= 0 ||
        usageDurationMinutes == null ||
        usageDurationMinutes <= 0 ||
        usageCount == null ||
        usageCount <= 0 ||
        usageFrequency == null) {
      return null;
    }

    final multiplier = switch (usageFrequency) {
      UsageFrequency.daily => 30.0,
      UsageFrequency.weekly => 4.33,
      UsageFrequency.monthly => 1.0,
    };

    return powerWatts /
        1000 *
        (usageDurationMinutes / 60) *
        usageCount *
        multiplier *
        quantity;
  }
}
