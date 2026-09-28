import 'energy_consumption_basis.dart';

class EnergyConsumptionMetric {
  final double valueKwh;
  final EnergyConsumptionBasis basis;

  const EnergyConsumptionMetric({required this.valueKwh, required this.basis});
}
