import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';

void main() {
  const engine = TariffEngineImpl();

  group('TariffEngineImpl', () {
    final configuration = TariffConfiguration(
      name: 'Configuration de test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: 150, pricePerKwh: 136.49, tierOrder: 2),
        TariffTier(minKwh: 150, maxKwh: null, pricePerKwh: 159, tierOrder: 3),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    test('calculates energy cost using tariff tiers', () {
      final result = engine.calculate(
        consumptionKwh: 100,
        configuration: configuration,
      );

      expect(result.consumptionKwh, 100);
      expect(result.tierCalculations, hasLength(2));

      expect(result.energyCost, closeTo(10924.5, 0.001));
      expect(result.totalCost, closeTo(10924.5, 0.001));
    });

    test('returns zero cost for zero consumption', () {
      final result = engine.calculate(
        consumptionKwh: 0,
        configuration: configuration,
      );

      expect(result.consumptionKwh, 0);
      expect(result.energyCost, 0);
      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, 0);
      expect(result.tierCalculations, isEmpty);
    });

    test('calculates all three tiers', () {
      final result = engine.calculate(
        consumptionKwh: 200,
        configuration: configuration,
      );

      expect(result.tierCalculations, hasLength(3));

      expect(result.energyCost, closeTo(25699, 0.001));

      expect(result.totalCost, closeTo(25699, 0.001));
    });

    test('does not add fees or taxes yet', () {
      final result = engine.calculate(
        consumptionKwh: 100,
        configuration: configuration,
      );

      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, result.energyCost);
    });
  });
}
