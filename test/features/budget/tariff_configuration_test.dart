import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';

void main() {
  group('TariffConfiguration', () {
    final effectiveFrom = DateTime(2026, 1, 1);

    const tiers = [
      TariffTier(minKwh: 0, maxKwh: 150, pricePerKwh: 82, tierOrder: 1),
      TariffTier(minKwh: 150, maxKwh: 250, pricePerKwh: 136.49, tierOrder: 2),
      TariffTier(minKwh: 250, maxKwh: null, pricePerKwh: 136.49, tierOrder: 3),
    ];

    test('crée une configuration tarifaire Woyofal DPP', () {
      final configuration = TariffConfiguration(
        name: 'Woyofal DPP 2026',
        customerCategory: 'DPP',
        billingMode: BillingMode.woyofal,
        tiers: tiers,
        effectiveFrom: effectiveFrom,
        effectiveTo: null,
        isActive: true,
      );

      expect(configuration.name, 'Woyofal DPP 2026');
      expect(configuration.customerCategory, 'DPP');
      expect(configuration.billingMode, BillingMode.woyofal);
      expect(configuration.tiers.length, 3);
      expect(configuration.effectiveFrom, effectiveFrom);
      expect(configuration.effectiveTo, isNull);
      expect(configuration.isActive, isTrue);
    });

    test('crée une configuration postpayée', () {
      final configuration = TariffConfiguration(
        name: 'Tarif DPP Postpayé 2026',
        customerCategory: 'DPP',
        billingMode: BillingMode.postpaid,
        tiers: tiers,
        effectiveFrom: effectiveFrom,
        effectiveTo: DateTime(2026, 12, 31),
        isActive: true,
      );

      expect(configuration.billingMode, BillingMode.postpaid);

      expect(configuration.effectiveTo, DateTime(2026, 12, 31));
    });

    test('conserve les différentes tranches tarifaires', () {
      final configuration = TariffConfiguration(
        name: 'Woyofal DPP 2026',
        customerCategory: 'DPP',
        billingMode: BillingMode.woyofal,
        tiers: tiers,
        effectiveFrom: effectiveFrom,
        effectiveTo: null,
        isActive: true,
      );

      expect(configuration.tiers[0].pricePerKwh, 82);
      expect(configuration.tiers[1].pricePerKwh, 136.49);
      expect(configuration.tiers[2].maxKwh, isNull);
    });
  });
}
