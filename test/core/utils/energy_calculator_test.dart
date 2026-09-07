import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/core/utils/energy_calculator.dart';

void main() {
  group('EnergyCalculator', () {
    test('calcule la consommation horaire', () {
      final result = EnergyCalculator.calculateHourlyConsumption(
        powerWatts: 150,
        quantity: 1,
      );

      expect(result, closeTo(0.15, 0.0001));
    });

    test('calcule la consommation quotidienne', () {
      final result = EnergyCalculator.calculateDailyConsumption(
        powerWatts: 150,
        hoursPerDay: 8,
        quantity: 1,
      );

      expect(result, closeTo(1.2, 0.0001));
    });

    test('calcule la consommation mensuelle', () {
      final result = EnergyCalculator.calculateMonthlyConsumption(
        powerWatts: 150,
        hoursPerDay: 8,
        daysPerMonth: 30,
        quantity: 1,
      );

      expect(result, closeTo(36.0, 0.0001));
    });

    test('calcule la consommation annuelle', () {
      final result = EnergyCalculator.calculateYearlyConsumption(
        powerWatts: 150,
        hoursPerDay: 8,
        quantity: 1,
      );

      expect(result, closeTo(438.0, 0.0001));
    });

    test('prend en compte plusieurs appareils identiques', () {
      final result = EnergyCalculator.calculateDailyConsumption(
        powerWatts: 100,
        hoursPerDay: 5,
        quantity: 3,
      );

      expect(result, closeTo(1.5, 0.0001));
    });

    test('prend en compte une année de 366 jours', () {
      final result = EnergyCalculator.calculateYearlyConsumption(
        powerWatts: 100,
        hoursPerDay: 10,
        quantity: 1,
        daysPerYear: 366,
      );

      expect(result, closeTo(366.0, 0.0001));
    });
  });
}
