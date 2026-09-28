import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';

import 'confidence_level.dart';
import 'numeric_range.dart';
import 'power_source.dart';

class ApplianceScanResult {
  final String rawOcrText;

  final String? brand;
  final String? model;
  final String? applianceType;

  final double? powerWatts;

  final double? voltageVolts;
  final NumericRange? voltageRange;

  final double? currentAmps;
  final NumericRange? currentRange;

  final double? frequencyHz;
  final List<double> frequencyOptions;

  final double? powerFactor;

  final double? annualConsumptionKwh;
  final String? capacity;

  final PowerSource? powerSource;
  final ConfidenceLevel confidenceLevel;

  final List<String> matchedKeywords;

  final List<EnergyConsumptionMetric> energyConsumptionMetrics;

  const ApplianceScanResult({
    required this.rawOcrText,
    this.brand,
    this.model,
    this.applianceType,
    this.powerWatts,
    this.voltageVolts,
    this.voltageRange,
    this.currentAmps,
    this.currentRange,
    this.frequencyHz,
    this.frequencyOptions = const [],
    this.powerFactor,
    this.annualConsumptionKwh,
    this.capacity,
    this.powerSource,
    required this.confidenceLevel,
    this.matchedKeywords = const [],
    this.energyConsumptionMetrics = const [],
  });
}
