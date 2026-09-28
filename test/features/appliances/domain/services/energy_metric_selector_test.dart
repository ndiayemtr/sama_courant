import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';
import 'package:sama_courant/features/appliances/domain/services/energy_metric_selector.dart';

void main() {
  const selector = EnergyMetricSelector();

  test('priorise la consommation annuelle', () {
    final result = selector.selectPreferred([
      const EnergyConsumptionMetric(
        valueKwh: 55,
        basis: EnergyConsumptionBasis.per100Cycles,
      ),
      const EnergyConsumptionMetric(
        valueKwh: 216,
        basis: EnergyConsumptionBasis.perYear,
      ),
    ]);

    expect(result, isNotNull);
    expect(result!.valueKwh, 216);
    expect(result.basis, EnergyConsumptionBasis.perYear);
  });

  test('utilise per100Cycles sans consommation annuelle', () {
    final result = selector.selectPreferred([
      const EnergyConsumptionMetric(
        valueKwh: 65,
        basis: EnergyConsumptionBasis.per1000Hours,
      ),
      const EnergyConsumptionMetric(
        valueKwh: 55,
        basis: EnergyConsumptionBasis.per100Cycles,
      ),
    ]);

    expect(result, isNotNull);
    expect(result!.basis, EnergyConsumptionBasis.per100Cycles);
  });

  test('utilise perCycle avant per1000Hours', () {
    final result = selector.selectPreferred([
      const EnergyConsumptionMetric(
        valueKwh: 65,
        basis: EnergyConsumptionBasis.per1000Hours,
      ),
      const EnergyConsumptionMetric(
        valueKwh: 0.8,
        basis: EnergyConsumptionBasis.perCycle,
      ),
    ]);

    expect(result, isNotNull);
    expect(result!.basis, EnergyConsumptionBasis.perCycle);
  });

  test('retourne null sans métrique', () {
    expect(selector.selectPreferred(const []), isNull);
  });
}
