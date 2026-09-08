import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';

void main() {
  group('WoyofalTariffConfigurationFactory', () {
    test('should create DPP 2026 Woyofal configuration', () {
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();

      expect(configuration.name, 'Woyofal DPP 2026');
      expect(configuration.customerCategory, 'DPP');
      expect(configuration.billingMode, BillingMode.woyofal);
      expect(configuration.isActive, isTrue);
      expect(configuration.effectiveFrom, DateTime(2026, 1, 1));
      expect(configuration.effectiveTo, isNull);
    });

    test('should contain three tariff tiers', () {
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();

      expect(configuration.tiers.length, 3);
    });

    test('should contain official DPP 2026 prices', () {
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();

      expect(configuration.tiers[0].pricePerKwh, 82.00);
      expect(configuration.tiers[1].pricePerKwh, 136.49);
      expect(configuration.tiers[2].pricePerKwh, 136.49);
    });

    test('should not add unconfirmed fees or taxes', () {
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();

      expect(configuration.components, isEmpty);
    });
  });
}
