import '../entities/appliance_scan_result.dart';
import '../services/appliance_classifier.dart';
import '../services/appliance_label_parser.dart';
import '../services/appliance_power_estimator.dart';
import '../services/label_text_normalizer.dart';
import '../services/label_text_recognizer.dart';
import '../services/power_resolver.dart';

class ScanApplianceLabel {
  final LabelTextRecognizer textRecognizer;
  final LabelTextNormalizer textNormalizer;
  final ApplianceLabelParser labelParser;
  final ApplianceClassifier classifier;
  final PowerResolver powerResolver;
  final AppliancePowerEstimator powerEstimator;

  const ScanApplianceLabel({
    required this.textRecognizer,
    required this.textNormalizer,
    required this.labelParser,
    required this.classifier,
    required this.powerResolver,
    required this.powerEstimator,
  });

  Future<ApplianceScanResult> call(String imagePath) async {
    final rawOcrText = await textRecognizer.recognizeText(imagePath);

    final normalizedText = textNormalizer.normalize(rawOcrText);

    final brand = labelParser.extractBrand(normalizedText);
    final model = labelParser.extractModel(normalizedText);

    final powerFactor = labelParser.extractPowerFactor(normalizedText);

    final annualConsumptionKwh = labelParser.extractAnnualConsumptionKwh(
      normalizedText,
    );

    final capacity = labelParser.extractCapacity(normalizedText);

    final voltageRange = labelParser.extractVoltageRange(normalizedText);
    final currentRange = labelParser.extractCurrentRange(normalizedText);
    final frequencyOptions = labelParser.extractFrequencyOptions(
      normalizedText,
    );

    final voltageVolts = voltageRange == null
        ? labelParser.extractVoltageVolts(normalizedText)
        : null;

    final currentAmps = currentRange == null
        ? labelParser.extractCurrentAmps(normalizedText)
        : null;

    final frequencyHz = frequencyOptions.isEmpty
        ? labelParser.extractFrequencyHz(normalizedText)
        : null;

    final detectedPowerWatts = labelParser.extractPowerWatts(normalizedText);

    final classification = classifier.classify(normalizedText);

    var powerResult = powerResolver.resolve(
      detectedPowerWatts: detectedPowerWatts,
      voltageVolts: voltageVolts,
      currentAmps: currentAmps,

      // Pas encore extrait de l'étiquette.
      powerFactor: powerFactor,
    );

    if (!powerResult.hasPower) {
      powerResult = powerEstimator.estimate(classification.category);
    }

    return ApplianceScanResult(
      rawOcrText: rawOcrText,

      brand: brand,
      model: model,
      applianceType: classification.category,

      powerWatts: powerResult.powerWatts,

      voltageVolts: voltageVolts,
      voltageRange: voltageRange,

      currentAmps: currentAmps,
      currentRange: currentRange,

      frequencyHz: frequencyHz,
      frequencyOptions: frequencyOptions,

      powerFactor: powerFactor,
      annualConsumptionKwh: annualConsumptionKwh,
      capacity: capacity,

      powerSource: powerResult.powerSource,
      confidenceLevel: powerResult.confidenceLevel,

      matchedKeywords: classification.matchedKeywords,
    );
  }
}
