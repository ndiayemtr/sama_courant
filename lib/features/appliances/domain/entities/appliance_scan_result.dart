import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';

class ApplianceScanResult {
  final String rawOcrText;

  final String? brand;
  final String? model;
  final String? applianceType;

  final double? powerWatts;
  final double? voltageVolts;
  final double? currentAmps;
  final double? frequencyHz;
  final double? powerFactor;

  final double? annualConsumptionKwh;
  final String? capacity;

  final PowerSource? powerSource;
  final ConfidenceLevel confidenceLevel;

  final List<String> matchedKeywords;

  const ApplianceScanResult({
    required this.rawOcrText,
    this.brand,
    this.model,
    this.applianceType,
    this.powerWatts,
    this.voltageVolts,
    this.currentAmps,
    this.frequencyHz,
    this.powerFactor,
    this.annualConsumptionKwh,
    this.capacity,
    this.powerSource,
    required this.confidenceLevel,
    this.matchedKeywords = const [],
  });
}
