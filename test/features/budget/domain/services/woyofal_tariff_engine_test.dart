import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';

void main() {
  group('DPP Woyofal 2026 - TariffEngine', () {
    final engine = const TariffEngineImpl();

    final configuration = WoyofalTariffConfigurationFactory.dpp2026();

    test('should calculate 100 kWh at 8,200 FCFA', () {
      final result = engine.calculate(
        consumptionKwh: 100,
        configuration: configuration,
      );

      expect(result.energyCost, 8200);
      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, 8200);

      expect(result.tierCalculations.length, 1);
      expect(result.tierCalculations[0].consumedKwh, 100);
      expect(result.tierCalculations[0].pricePerKwh, 82);
    });

    test('should calculate 150 kWh at 12,300 FCFA', () {
      final result = engine.calculate(
        consumptionKwh: 150,
        configuration: configuration,
      );

      expect(result.energyCost, 12300);
      expect(result.totalCost, 12300);

      expect(result.tierCalculations.length, 1);
      expect(result.tierCalculations[0].consumedKwh, 150);
    });

    test('should calculate 200 kWh progressively across two tiers', () {
      final result = engine.calculate(
        consumptionKwh: 200,
        configuration: configuration,
      );

      expect(result.energyCost, closeTo(19124.50, 0.001));
      expect(result.totalCost, closeTo(19124.50, 0.001));

      expect(result.tierCalculations.length, 2);

      expect(result.tierCalculations[0].consumedKwh, 150);
      expect(result.tierCalculations[0].pricePerKwh, 82);
      expect(result.tierCalculations[0].cost, 12300);

      expect(result.tierCalculations[1].consumedKwh, 50);
      expect(result.tierCalculations[1].pricePerKwh, 136.49);
      expect(result.tierCalculations[1].cost, closeTo(6824.50, 0.001));
    });

    test('should calculate 300 kWh progressively across three tiers', () {
      final result = engine.calculate(
        consumptionKwh: 300,
        configuration: configuration,
      );

      expect(result.energyCost, closeTo(32773.50, 0.001));
      expect(result.totalCost, closeTo(32773.50, 0.001));

      expect(result.tierCalculations.length, 3);

      expect(result.tierCalculations[0].consumedKwh, 150);
      expect(result.tierCalculations[0].pricePerKwh, 82);

      expect(result.tierCalculations[1].consumedKwh, 100);
      expect(result.tierCalculations[1].pricePerKwh, 136.49);

      expect(result.tierCalculations[2].consumedKwh, 50);
      expect(result.tierCalculations[2].pricePerKwh, 136.49);
    });

    test('should continue using the second tariff above 250 kWh', () {
      final result = engine.calculate(
        consumptionKwh: 400,
        configuration: configuration,
      );

      expect(result.energyCost, closeTo(46422.50, 0.001));
      expect(result.totalCost, closeTo(46422.50, 0.001));

      expect(result.tierCalculations.length, 3);

      expect(result.tierCalculations[0].consumedKwh, 150);
      expect(result.tierCalculations[1].consumedKwh, 100);
      expect(result.tierCalculations[2].consumedKwh, 150);

      expect(result.tierCalculations[2].pricePerKwh, 136.49);
    });
  });
}
