import '../../../../core/utils/energy_calculator.dart';
import 'usage_frequency.dart';

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
  });

  double get hourlyConsumptionKwh {
    return EnergyCalculator.calculateHourlyConsumption(
      powerWatts: powerWatts,
      quantity: quantity,
    );
  }

  double get dailyConsumptionKwh {
    return EnergyCalculator.calculateDailyConsumption(
      powerWatts: powerWatts,
      hoursPerDay: hoursPerDay,
      quantity: quantity,
    );
  }

  double get monthlyConsumptionKwh {
    if (usesNewUsageModel) {
      return EnergyCalculator.calculateMonthlyConsumptionFromUsage(
        powerWatts: powerWatts,
        usageDurationMinutes: usageDurationMinutes!,
        usageCount: usageCount!,
        monthlyFrequencyMultiplier: monthlyFrequencyMultiplier,
        quantity: quantity,
      );
    }

    return EnergyCalculator.calculateMonthlyConsumption(
      powerWatts: powerWatts,
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
      quantity: quantity,
    );
  }

  double get yearlyConsumptionKwh {
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
}
