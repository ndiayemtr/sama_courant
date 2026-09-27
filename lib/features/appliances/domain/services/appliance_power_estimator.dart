import '../constants/appliance_power_estimates.dart';
import '../entities/appliance_power_estimate.dart';
import '../entities/confidence_level.dart';
import '../entities/power_resolution_result.dart';
import '../entities/power_source.dart';

class AppliancePowerEstimator {
  final Map<String, AppliancePowerEstimate> estimates;

  const AppliancePowerEstimator({this.estimates = appliancePowerEstimates});

  PowerResolutionResult estimate(String? category) {
    if (category == null) {
      return _unknownResult();
    }

    final estimate = estimates[category];

    if (estimate == null || !_isValidEstimate(estimate)) {
      return _unknownResult();
    }

    return PowerResolutionResult(
      powerWatts: estimate.typicalWatts,
      powerSource: PowerSource.estimated,
      confidenceLevel: ConfidenceLevel.low,
      minWatts: estimate.minWatts,
      maxWatts: estimate.maxWatts,
      explanation: 'Puissance estimée à partir du type d’appareil.',
    );
  }

  bool _isValidEstimate(AppliancePowerEstimate estimate) {
    return estimate.typicalWatts.isFinite &&
        estimate.minWatts.isFinite &&
        estimate.maxWatts.isFinite &&
        estimate.typicalWatts > 0 &&
        estimate.minWatts > 0 &&
        estimate.maxWatts > 0 &&
        estimate.minWatts <= estimate.typicalWatts &&
        estimate.typicalWatts <= estimate.maxWatts;
  }

  PowerResolutionResult _unknownResult() {
    return const PowerResolutionResult(
      powerWatts: null,
      powerSource: null,
      confidenceLevel: ConfidenceLevel.low,
      explanation:
          'Aucune estimation de puissance disponible pour cet appareil.',
    );
  }
}
