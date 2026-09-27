import 'confidence_level.dart';
import 'power_source.dart';

class PowerResolutionResult {
  final double? powerWatts;
  final PowerSource? powerSource;
  final ConfidenceLevel confidenceLevel;
  final String? explanation;

  final double? minWatts;
  final double? maxWatts;

  const PowerResolutionResult({
    required this.powerWatts,
    required this.powerSource,
    required this.confidenceLevel,
    this.explanation,
    this.minWatts,
    this.maxWatts,
  });

  bool get hasPower => powerWatts != null;

  bool get hasEstimatedRange => minWatts != null && maxWatts != null;
}
