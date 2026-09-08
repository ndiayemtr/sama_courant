import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_taxable_base.dart';
import 'package:sama_courant/features/budget/domain/services/tax_calculator.dart';

void main() {
  const calculator = TaxCalculator();

  group('TaxCalculator', () {
    test('calculates percentage tax on energy', () {
      const components = [
        TariffComponent(
          name: 'Taxe test',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energy,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, closeTo(1000, 0.001));
    });

    test('calculates percentage tax on fees', () {
      const components = [
        TariffComponent(
          name: 'Taxe sur frais',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.fees,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, closeTo(50, 0.001));
    });

    test('calculates percentage tax on energy and fees', () {
      const components = [
        TariffComponent(
          name: 'Taxe sur sous-total',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energyAndFees,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, closeTo(1050, 0.001));
    });

    test('calculates fixed tax', () {
      const components = [
        TariffComponent(
          name: 'Taxe fixe',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 250,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, 250);
    });

    test('ignores tax already included in tariff', () {
      const components = [
        TariffComponent(
          name: 'Taxe incluse',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energy,
          includedInTariff: true,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, 0);
    });

    test('ignores percentage tax without taxable base', () {
      const components = [
        TariffComponent(
          name: 'Taxe sans base',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: null,
          includedInTariff: false,
        ),
      ];

      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, 0);
    });

    test('ignores non-tax components', () {
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
        energyCost: 10000,
        fees: 500,
        components: components,
      );

      expect(result, 0);
    });

    test('returns zero when there are no components', () {
      final result = calculator.calculate(
        energyCost: 10000,
        fees: 500,
        components: const [],
      );

      expect(result, 0);
    });
  });
}
