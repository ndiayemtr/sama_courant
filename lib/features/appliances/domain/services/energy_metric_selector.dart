import '../entities/energy_consumption_basis.dart';
import '../entities/energy_consumption_metric.dart';

class EnergyMetricSelector {
  const EnergyMetricSelector();

  EnergyConsumptionMetric? selectPreferred(
    List<EnergyConsumptionMetric> metrics,
  ) {
    if (metrics.isEmpty) {
      return null;
    }

    const priority = [
      EnergyConsumptionBasis.perYear,
      EnergyConsumptionBasis.per100Cycles,
      EnergyConsumptionBasis.perCycle,
      EnergyConsumptionBasis.per1000Hours,
    ];

    for (final basis in priority) {
      for (final metric in metrics) {
        if (metric.basis == basis) {
          return metric;
        }
      }
    }

    return null;
  }
}
