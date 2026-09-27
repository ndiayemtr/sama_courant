import '../entities/confidence_level.dart';
import '../entities/power_resolution_result.dart';
import '../entities/power_source.dart';

class PowerResolver {
  const PowerResolver();

  PowerResolutionResult resolve({
    double? detectedPowerWatts,
    double? voltageVolts,
    double? currentAmps,
    double? powerFactor,
  }) {
    if (_isPositiveFinite(detectedPowerWatts)) {
      return PowerResolutionResult(
        powerWatts: detectedPowerWatts,
        powerSource: PowerSource.detected,
        confidenceLevel: ConfidenceLevel.high,
        explanation: 'Puissance détectée directement sur l’étiquette.',
      );
    }

    if (_isPositiveFinite(voltageVolts) &&
        _isPositiveFinite(currentAmps) &&
        _isValidPowerFactor(powerFactor)) {
      final calculatedPower = voltageVolts! * currentAmps! * powerFactor!;

      return PowerResolutionResult(
        powerWatts: calculatedPower,
        powerSource: PowerSource.calculated,
        confidenceLevel: ConfidenceLevel.high,
        explanation:
            'Puissance calculée à partir de la tension, du courant '
            'et du facteur de puissance.',
      );
    }

    if (_isPositiveFinite(voltageVolts) && _isPositiveFinite(currentAmps)) {
      final calculatedPower = voltageVolts! * currentAmps!;

      return PowerResolutionResult(
        powerWatts: calculatedPower,
        powerSource: PowerSource.calculated,
        confidenceLevel: ConfidenceLevel.medium,
        explanation:
            'Puissance approximative calculée à partir de la tension '
            'et du courant.',
      );
    }

    return const PowerResolutionResult(
      powerWatts: null,
      powerSource: null,
      confidenceLevel: ConfidenceLevel.low,
      explanation: 'Aucune puissance exploitable n’a pu être déterminée.',
    );
  }

  bool _isPositiveFinite(double? value) {
    return value != null && value.isFinite && value > 0;
  }

  bool _isValidPowerFactor(double? value) {
    return value != null && value.isFinite && value > 0 && value <= 1;
  }
}
