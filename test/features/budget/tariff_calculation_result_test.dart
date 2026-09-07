import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier_calculation.dart';

void main() {
  group('TariffCalculationResult', () {
    test('stores the complete tariff calculation result', () {
      const tierCalculation = TariffTierCalculation(
        tierOrder: 1,
        consumedKwh: 100.0,
        pricePerKwh: 82.0,
        cost: 8200.0,
      );

      const result = TariffCalculationResult(
        consumptionKwh: 100.0,
        energyCost: 8200.0,
        fees: 70.0,
        taxes: 0.0,
        totalCost: 8270.0,
        tierCalculations: [tierCalculation],
      );

      expect(result.consumptionKwh, 100.0);
      expect(result.energyCost, 8200.0);
      expect(result.fees, 70.0);
      expect(result.taxes, 0.0);
      expect(result.totalCost, 8270.0);
      expect(result.tierCalculations, hasLength(1));
      expect(result.tierCalculations.first.tierOrder, 1);
    });

    test('supports zero fees and taxes', () {
      const result = TariffCalculationResult(
        consumptionKwh: 50.0,
        energyCost: 4100.0,
        fees: 0.0,
        taxes: 0.0,
        totalCost: 4100.0,
        tierCalculations: [],
      );

      expect(result.fees, 0.0);
      expect(result.taxes, 0.0);
      expect(result.totalCost, result.energyCost);
      expect(result.tierCalculations, isEmpty);
    });
  });
}
