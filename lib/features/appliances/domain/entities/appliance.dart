import '../../../../core/utils/energy_calculator.dart';

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
}
