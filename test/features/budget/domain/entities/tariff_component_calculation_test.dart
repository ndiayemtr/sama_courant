import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_calculation.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';

void main() {
  test('should create a tariff component calculation', () {
    const calculation = TariffComponentCalculation(
      name: 'Redevance',
      type: TariffComponentType.fee,
      calculationMethod: TariffCalculationMethod.perKwh,
      baseAmount: 100,
      value: 0.7,
      unit: 'FCFA/kWh',
      amount: 70,
    );

    expect(calculation.name, 'Redevance');
    expect(calculation.type, TariffComponentType.fee);
    expect(calculation.calculationMethod, TariffCalculationMethod.perKwh);
    expect(calculation.baseAmount, 100);
    expect(calculation.value, 0.7);
    expect(calculation.unit, 'FCFA/kWh');
    expect(calculation.amount, 70);
  });

  test('should support a percentage calculation with a monetary base', () {
    const calculation = TariffComponentCalculation(
      name: 'Taxe',
      type: TariffComponentType.tax,
      calculationMethod: TariffCalculationMethod.percentage,
      baseAmount: 10000,
      value: 10,
      unit: '%',
      amount: 1000,
    );

    expect(calculation.baseAmount, 10000);
    expect(calculation.value, 10);
    expect(calculation.amount, 1000);
  });

  test('should support a fixed calculation without a base', () {
    const calculation = TariffComponentCalculation(
      name: 'Frais fixe',
      type: TariffComponentType.fee,
      calculationMethod: TariffCalculationMethod.fixed,
      baseAmount: null,
      value: 500,
      unit: 'FCFA',
      amount: 500,
    );

    expect(calculation.baseAmount, isNull);
    expect(calculation.amount, 500);
  });
}
