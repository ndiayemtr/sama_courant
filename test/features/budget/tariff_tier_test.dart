import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';

void main() {
  group('TariffTier', () {
    test('crée une tranche tarifaire avec ses propriétés', () {
      const tier = TariffTier(
        minKwh: 0,
        maxKwh: 100,
        pricePerKwh: 100,
        tierOrder: 1,
      );

      expect(tier.minKwh, 0);
      expect(tier.maxKwh, 100);
      expect(tier.pricePerKwh, 100);
      expect(tier.tierOrder, 1);
    });

    test('accepte une tranche sans limite supérieure', () {
      const tier = TariffTier(
        minKwh: 200,
        maxKwh: null,
        pricePerKwh: 150,
        tierOrder: 3,
      );

      expect(tier.minKwh, 200);
      expect(tier.maxKwh, isNull);
      expect(tier.pricePerKwh, 150);
      expect(tier.tierOrder, 3);
    });

    test('est immutable', () {
      const tier = TariffTier(
        minKwh: 0,
        maxKwh: 100,
        pricePerKwh: 100,
        tierOrder: 1,
      );

      expect(tier.minKwh, 0);
      expect(tier.maxKwh, 100);
      expect(tier.pricePerKwh, 100);
      expect(tier.tierOrder, 1);
    });
  });
}
