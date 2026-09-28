import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';

void main() {
  test('transporte une consommation annuelle', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 216,
      basis: EnergyConsumptionBasis.perYear,
    );

    expect(metric.valueKwh, 216);
    expect(metric.basis, EnergyConsumptionBasis.perYear);
  });

  test('transporte une consommation pour 100 cycles', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 55,
      basis: EnergyConsumptionBasis.per100Cycles,
    );

    expect(metric.valueKwh, 55);
    expect(metric.basis, EnergyConsumptionBasis.per100Cycles);
  });

  test('transporte une consommation pour 1000 heures', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 65,
      basis: EnergyConsumptionBasis.per1000Hours,
    );

    expect(metric.valueKwh, 65);
    expect(metric.basis, EnergyConsumptionBasis.per1000Hours);
  });

  test('transporte une consommation par cycle', () {
    const metric = EnergyConsumptionMetric(
      valueKwh: 0.8,
      basis: EnergyConsumptionBasis.perCycle,
    );

    expect(metric.valueKwh, 0.8);
    expect(metric.basis, EnergyConsumptionBasis.perCycle);
  });
}
