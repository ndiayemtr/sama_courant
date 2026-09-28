import '../entities/energy_consumption_basis.dart';
import '../entities/energy_consumption_metric.dart';
import '../entities/usage_frequency.dart';

class EnergyMetricMonthlyConverter {
  const EnergyMetricMonthlyConverter();

  double? convert({
    required EnergyConsumptionMetric metric,
    int? usageDurationMinutes,
    int? usageCount,
    UsageFrequency? usageFrequency,
  }) {
    if (!metric.valueKwh.isFinite || metric.valueKwh <= 0) {
      return null;
    }

    switch (metric.basis) {
      case EnergyConsumptionBasis.perYear:
        return metric.valueKwh / 12;

      case EnergyConsumptionBasis.per100Cycles:
        final monthlyCycles = _monthlyCycles(
          usageCount: usageCount,
          usageFrequency: usageFrequency,
        );

        if (monthlyCycles == null) {
          return null;
        }

        return (metric.valueKwh / 100) * monthlyCycles;

      case EnergyConsumptionBasis.perCycle:
        final monthlyCycles = _monthlyCycles(
          usageCount: usageCount,
          usageFrequency: usageFrequency,
        );

        if (monthlyCycles == null) {
          return null;
        }

        return metric.valueKwh * monthlyCycles;

      case EnergyConsumptionBasis.per1000Hours:
        final monthlyHours = _monthlyHours(
          usageDurationMinutes: usageDurationMinutes,
          usageCount: usageCount,
          usageFrequency: usageFrequency,
        );

        if (monthlyHours == null) {
          return null;
        }

        return (metric.valueKwh / 1000) * monthlyHours;
    }
  }

  double? _monthlyCycles({
    required int? usageCount,
    required UsageFrequency? usageFrequency,
  }) {
    if (usageCount == null || usageCount <= 0 || usageFrequency == null) {
      return null;
    }

    return usageCount * _frequencyMultiplier(usageFrequency);
  }

  double? _monthlyHours({
    required int? usageDurationMinutes,
    required int? usageCount,
    required UsageFrequency? usageFrequency,
  }) {
    if (usageDurationMinutes == null ||
        usageDurationMinutes <= 0 ||
        usageCount == null ||
        usageCount <= 0 ||
        usageFrequency == null) {
      return null;
    }

    final durationHours = usageDurationMinutes / 60;

    return durationHours * usageCount * _frequencyMultiplier(usageFrequency);
  }

  double _frequencyMultiplier(UsageFrequency frequency) {
    return switch (frequency) {
      UsageFrequency.daily => 30,
      UsageFrequency.weekly => 4.33,
      UsageFrequency.monthly => 1,
    };
  }
}
