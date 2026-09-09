import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';
import 'package:sama_courant/features/budget/domain/services/tariff_configuration_validator.dart';

void main() {
  group('TariffConfigurationValidator', () {
    const validator = TariffConfigurationValidator();

    test('should accept official DPP Woyofal 2026 configuration', () {
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();

      expect(validator.isValid(configuration), isTrue);
      expect(validator.validate(configuration), isEmpty);
    });

    test('should reject configuration without tiers', () {
      final configuration = TariffConfiguration(
        name: 'Configuration vide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test('should reject negative tariff price', () {
      final configuration = TariffConfiguration(
        name: 'Configuration invalide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: -10, tierOrder: 1),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);

      expect(
        validator.validate(configuration),
        contains('Le prix par kWh ne peut pas être négatif.'),
      );
    });

    test('should reject negative minimum threshold', () {
      final configuration = TariffConfiguration(
        name: 'Configuration invalide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(minKwh: -1, maxKwh: 150, pricePerKwh: 82, tierOrder: 1),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test('should reject invalid tier range', () {
      final configuration = TariffConfiguration(
        name: 'Configuration invalide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(
            minKwh: 150,
            maxKwh: 100,
            pricePerKwh: 136.49,
            tierOrder: 1,
          ),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test('should reject duplicate tier orders', () {
      final configuration = TariffConfiguration(
        name: 'Configuration invalide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: 150, pricePerKwh: 82, tierOrder: 1),
          TariffTier(
            minKwh: 150,
            maxKwh: null,
            pricePerKwh: 136.49,
            tierOrder: 1,
          ),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test('should reject a gap between tiers', () {
      final configuration = TariffConfiguration(
        name: 'Configuration invalide',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: 150, pricePerKwh: 82, tierOrder: 1),
          TariffTier(
            minKwh: 200,
            maxKwh: null,
            pricePerKwh: 136.49,
            tierOrder: 2,
          ),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test('should reject empty configuration name', () {
      final configuration = TariffConfiguration(
        name: '   ',
        customerCategory: 'DPP',
        billingMode: WoyofalTariffConfigurationFactory.dpp2026().billingMode,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 1, 1),
        effectiveTo: null,
        isActive: true,
      );

      expect(validator.isValid(configuration), isFalse);
    });

    test(
      'should reject a configuration with an open tier before the last tier',
      () {
        final configuration = TariffConfiguration(
          name: 'Invalid configuration',
          customerCategory: 'DPP',
          billingMode: BillingMode.woyofal,
          tiers: const [
            TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
            TariffTier(
              minKwh: 150,
              maxKwh: 250,
              pricePerKwh: 136.49,
              tierOrder: 2,
            ),
          ],
          components: const [],
          effectiveFrom: DateTime(2026, 1, 1),
          effectiveTo: null,
          isActive: true,
        );

        final errors = validator.validate(configuration);

        expect(errors, isNotEmpty);
      },
    );

    test('should reject an effectiveTo before effectiveFrom', () {
      final configuration = TariffConfiguration(
        name: 'Invalid dates',
        customerCategory: 'DPP',
        billingMode: BillingMode.woyofal,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
        ],
        components: const [],
        effectiveFrom: DateTime(2026, 6, 1),
        effectiveTo: DateTime(2026, 1, 1),
        isActive: true,
      );

      final errors = validator.validate(configuration);

      expect(errors, isNotEmpty);
    });
  });
}
