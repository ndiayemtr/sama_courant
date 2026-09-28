import 'energy_consumption_metric.dart';
import 'monthly_consumption_source.dart';
import 'power_source.dart';

class MonthlyConsumptionResult {
  final double monthlyKwh;
  final MonthlyConsumptionSource source;

  final EnergyConsumptionMetric? energyMetric;
  final PowerSource? powerSource;

  const MonthlyConsumptionResult({
    required this.monthlyKwh,
    required this.source,
    this.energyMetric,
    this.powerSource,
  });
}
