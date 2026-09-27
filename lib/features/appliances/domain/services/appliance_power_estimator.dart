import '../entities/confidence_level.dart';
import '../entities/power_resolution_result.dart';
import '../entities/power_source.dart';

class AppliancePowerEstimator {
  final Map<String, double> estimates;

  const AppliancePowerEstimator({required this.estimates});

  PowerResolutionResult estimate(String? category) {
    if (category == null) {
      return _unknownResult();
    }

    final estimatedPower = estimates[category];

    if (estimatedPower == null ||
        !estimatedPower.isFinite ||
        estimatedPower <= 0) {
      return _unknownResult();
    }

    return PowerResolutionResult(
      powerWatts: estimatedPower,
      powerSource: PowerSource.estimated,
      confidenceLevel: ConfidenceLevel.low,
      explanation: 'Puissance estimée à partir du type d’appareil.',
    );
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
