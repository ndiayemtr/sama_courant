import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_taxable_base.dart';

void main() {
  group('TariffComponent', () {
    test('represents a per-kWh energy component', () {
      const component = TariffComponent(
        name: 'Énergie',
        type: TariffComponentType.energy,
        calculationMethod: TariffCalculationMethod.perKwh,
        value: 82.0,
        unit: 'FCFA/kWh',
        taxableBase: null,
        includedInTariff: false,
      );

      expect(component.name, 'Énergie');
      expect(component.type, TariffComponentType.energy);
      expect(component.calculationMethod, TariffCalculationMethod.perKwh);
      expect(component.value, 82.0);
      expect(component.unit, 'FCFA/kWh');
      expect(component.taxableBase, isNull);
      expect(component.includedInTariff, isFalse);
    });

    test('represents a per-kWh fee', () {
      const component = TariffComponent(
        name: 'Redevance',
        type: TariffComponentType.fee,
        calculationMethod: TariffCalculationMethod.perKwh,
        value: 0.7,
        unit: 'FCFA/kWh',
        taxableBase: null,
        includedInTariff: true,
      );

      expect(component.type, TariffComponentType.fee);
      expect(component.calculationMethod, TariffCalculationMethod.perKwh);
      expect(component.value, 0.7);
      expect(component.includedInTariff, isTrue);
    });

    test('represents a percentage tax on energy', () {
      const component = TariffComponent(
        name: 'Taxe',
        type: TariffComponentType.tax,
        calculationMethod: TariffCalculationMethod.percentage,
        value: 18.0,
        unit: '%',
        taxableBase: TariffTaxableBase.energy,
        includedInTariff: false,
      );

      expect(component.type, TariffComponentType.tax);
      expect(component.calculationMethod, TariffCalculationMethod.percentage);
      expect(component.value, 18.0);
      expect(component.unit, '%');
      expect(component.taxableBase, TariffTaxableBase.energy);
    });

    test('represents a fixed fee', () {
      const component = TariffComponent(
        name: 'Frais fixes',
        type: TariffComponentType.fee,
        calculationMethod: TariffCalculationMethod.fixed,
        value: 500.0,
        unit: 'FCFA',
        taxableBase: null,
        includedInTariff: false,
      );

      expect(component.calculationMethod, TariffCalculationMethod.fixed);
      expect(component.value, 500.0);
      expect(component.unit, 'FCFA');
    });

    test('supports all taxable bases', () {
      expect(TariffTaxableBase.values, contains(TariffTaxableBase.energy));
      expect(TariffTaxableBase.values, contains(TariffTaxableBase.fees));
      expect(
        TariffTaxableBase.values,
        contains(TariffTaxableBase.energyAndFees),
      );
      expect(TariffTaxableBase.values, contains(TariffTaxableBase.subtotal));
    });
  });
}
