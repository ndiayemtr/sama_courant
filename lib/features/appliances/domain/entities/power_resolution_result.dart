import 'confidence_level.dart';
import 'power_source.dart';

class PowerResolutionResult {
  final double? powerWatts;
  final PowerSource? powerSource;
  final ConfidenceLevel confidenceLevel;
  final String? explanation;

  const PowerResolutionResult({
    required this.powerWatts,
    required this.powerSource,
    required this.confidenceLevel,
    this.explanation,
  });

  bool get hasPower => powerWatts != null;
}
