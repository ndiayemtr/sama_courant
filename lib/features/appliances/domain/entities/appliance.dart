import '../../../../core/utils/energy_calculator.dart';
import 'usage_frequency.dart';
import 'appliance_label_type.dart';
import 'energy_consumption_metric.dart';
import 'monthly_consumption_result.dart';
import 'power_source.dart';
import '../services/monthly_consumption_selector.dart';

class Appliance {
  final int? id;
  final String name;
  final String category;
  final double powerWatts;
  final int quantity;
  final double hoursPerDay;
  final int daysPerMonth;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? usageDurationMinutes;
  final int? usageCount;
  final UsageFrequency? usageFrequency;
  final ApplianceLabelType labelType;
  final List<EnergyConsumptionMetric> energyConsumptionMetrics;
  final PowerSource? powerSource;

  const Appliance({
    this.id,
    required this.name,
    required this.category,
    required this.powerWatts,
    required this.quantity,
    required this.hoursPerDay,
    required this.daysPerMonth,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.usageDurationMinutes,
    this.usageCount,
    this.usageFrequency,
    this.labelType = ApplianceLabelType.unknown,
    this.energyConsumptionMetrics = const [],
    this.powerSource,
  });

  double get hourlyConsumptionKwh {
    return EnergyCalculator.calculateHourlyConsumption(
      powerWatts: powerWatts,
      quantity: quantity,
    );
  }

  double get dailyConsumptionKwh {
    if (usesNewUsageModel) {
      return monthlyConsumptionKwh / 30;
    }

    return EnergyCalculator.calculateDailyConsumption(
      powerWatts: powerWatts,
      hoursPerDay: hoursPerDay,
      quantity: quantity,
    );
  }

  double get monthlyConsumptionKwh {
    if (usesNewUsageModel) {
      final selected = selectedMonthlyConsumption;

      return selected?.monthlyKwh ?? double.nan;
    }

    return EnergyCalculator.calculateMonthlyConsumption(
      powerWatts: powerWatts,
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
      quantity: quantity,
    );
  }

  double get yearlyConsumptionKwh {
    if (usesNewUsageModel) {
      return monthlyConsumptionKwh * 12;
    }

    return EnergyCalculator.calculateYearlyConsumption(
      powerWatts: powerWatts,
      hoursPerDay: hoursPerDay,
      quantity: quantity,
    );
  }

  bool get usesNewUsageModel {
    return usageDurationMinutes != null &&
        usageCount != null &&
        usageFrequency != null;
  }

  double get monthlyFrequencyMultiplier {
    switch (usageFrequency) {
      case UsageFrequency.daily:
        return 30;
      case UsageFrequency.weekly:
        return 4.33;
      case UsageFrequency.monthly:
        return 1;
      case null:
        return 0;
    }
  }

  double get averageDailyUsageHours {
    if (!usesNewUsageModel) {
      return hoursPerDay;
    }

    final frequencyMultiplier = switch (usageFrequency!) {
      UsageFrequency.daily => 30.0,
      UsageFrequency.weekly => 4.33,
      UsageFrequency.monthly => 1.0,
    };

    final monthlyUsageHours =
        (usageDurationMinutes! / 60) * usageCount! * frequencyMultiplier;

    return monthlyUsageHours / 30;
  }

  MonthlyConsumptionResult? get selectedMonthlyConsumption {
    if (!usesNewUsageModel) {
      return null;
    }

    return const MonthlyConsumptionSelector().select(
      labelType: labelType,
      energyMetrics: energyConsumptionMetrics,
      powerWatts: powerWatts,
      powerSource: powerSource,
      quantity: quantity,
      usageDurationMinutes: usageDurationMinutes,
      usageCount: usageCount,
      usageFrequency: usageFrequency,
    );
  }
}
