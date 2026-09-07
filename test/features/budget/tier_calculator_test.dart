import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';
import 'package:sama_courant/features/budget/domain/services/tier_calculator.dart';

void main() {
  const calculator = TierCalculator();

  group('TierCalculator', () {
    final tiers = [
      const TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
      const TariffTier(
        minKwh: 50,
        maxKwh: 150,
        pricePerKwh: 136.49,
        tierOrder: 2,
      ),
      const TariffTier(
        minKwh: 150,
        maxKwh: null,
        pricePerKwh: 159,
        tierOrder: 3,
      ),
    ];

    test('returns empty result for zero consumption', () {
      final result = calculator.calculate(consumptionKwh: 0, tiers: tiers);

      expect(result, isEmpty);
    });

    test('calculates consumption entirely in first tier', () {
      final result = calculator.calculate(consumptionKwh: 30, tiers: tiers);

      expect(result, hasLength(1));
      expect(result[0].tierOrder, 1);
      expect(result[0].consumedKwh, 30);
      expect(result[0].cost, 2460);
    });

    test('splits consumption across two tiers', () {
      final result = calculator.calculate(consumptionKwh: 100, tiers: tiers);

      expect(result, hasLength(2));

      expect(result[0].tierOrder, 1);
      expect(result[0].consumedKwh, 50);
      expect(result[0].cost, 4100);

      expect(result[1].tierOrder, 2);
      expect(result[1].consumedKwh, 50);
      expect(result[1].cost, closeTo(6824.5, 0.001));
    });

    test('splits consumption across three tiers', () {
      final result = calculator.calculate(consumptionKwh: 200, tiers: tiers);

      expect(result, hasLength(3));

      expect(result[0].consumedKwh, 50);
      expect(result[1].consumedKwh, 100);
      expect(result[2].consumedKwh, 50);

      expect(result[0].cost, 4100);
      expect(result[1].cost, closeTo(13649, 0.001));
      expect(result[2].cost, 7950);
    });

    test('uses the unlimited final tier for remaining consumption', () {
      final result = calculator.calculate(consumptionKwh: 500, tiers: tiers);

      expect(result, hasLength(3));
      expect(result[2].consumedKwh, 350);
    });

    test('returns empty result when there are no tiers', () {
      final result = calculator.calculate(consumptionKwh: 100, tiers: []);

      expect(result, isEmpty);
    });
  });
}
