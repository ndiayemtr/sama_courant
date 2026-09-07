import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';

void main() {
  group('TariffCalculationResult', () {
    test('stores the complete tariff calculation result', () {
      const result = TariffCalculationResult(
        consumptionKwh: 100.0,
        energyCost: 8200.0,
        fees: 70.0,
        taxes: 0.0,
        totalCost: 8270.0,
      );

      expect(result.consumptionKwh, 100.0);
      expect(result.energyCost, 8200.0);
      expect(result.fees, 70.0);
      expect(result.taxes, 0.0);
      expect(result.totalCost, 8270.0);
    });

    test('supports zero fees and taxes', () {
      const result = TariffCalculationResult(
        consumptionKwh: 50.0,
        energyCost: 4100.0,
        fees: 0.0,
        taxes: 0.0,
        totalCost: 4100.0,
      );

      expect(result.fees, 0.0);
      expect(result.taxes, 0.0);
      expect(result.totalCost, result.energyCost);
    });
  });
}
