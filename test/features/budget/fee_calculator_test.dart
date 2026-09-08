import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/services/fee_calculator.dart';

void main() {
  const calculator = FeeCalculator();

  group('FeeCalculator', () {
    test('calculates a per-kWh fee', () {
      const components = [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, closeTo(70.0, 0.001));
    });

    test('calculates a fixed fee', () {
      const components = [
        TariffComponent(
          name: 'Frais fixes',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 500,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, 500);
    });

    test('calculates multiple fees', () {
      const components = [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Frais fixes',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 500,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, closeTo(570.0, 0.001));
    });

    test('ignores fees already included in tariff', () {
      const components = [
        TariffComponent(
          name: 'Redevance incluse',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: true,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, 0);
    });

    test('ignores energy components', () {
      const components = [
        TariffComponent(
          name: 'Énergie',
          type: TariffComponentType.energy,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 82,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, 0);
    });

    test('ignores percentage components', () {
      const components = [
        TariffComponent(
          name: 'Taxe',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        consumptionKwh: 100,
        components: components,
      );

      expect(result, 0);
    });

    test('returns zero when there are no components', () {
      final result = calculator.calculate(
        consumptionKwh: 100,
        components: const [],
      );

      expect(result, 0);
    });
  });
}
