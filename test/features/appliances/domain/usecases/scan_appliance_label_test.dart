import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_classifier.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_parser.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_power_estimator.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_normalizer.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_recognizer.dart';
import 'package:sama_courant/features/appliances/domain/services/power_resolver.dart';
import 'package:sama_courant/features/appliances/domain/usecases/scan_appliance_label.dart';

class FakeLabelTextRecognizer implements LabelTextRecognizer {
  final String text;

  FakeLabelTextRecognizer(this.text);

  @override
  Future<String> recognizeText(String imagePath) async {
    return text;
  }
}

ScanApplianceLabel createUseCase(String ocrText) {
  return ScanApplianceLabel(
    textRecognizer: FakeLabelTextRecognizer(ocrText),
    textNormalizer: const LabelTextNormalizer(),
    labelParser: const ApplianceLabelParser(),
    classifier: const ApplianceClassifier(),
    powerResolver: const PowerResolver(),
    powerEstimator: const AppliancePowerEstimator(),
  );
}

void main() {
  test('orchestre un scan avec puissance directement détectée', () async {
    final useCase = createUseCase(
      'SAMSUNG REFRIGERATOR 220 V 0,8 A 50 Hz 180 W',
    );

    final result = await useCase('label.jpg');

    expect(result.rawOcrText, contains('SAMSUNG'));
    expect(result.applianceType, 'refrigerator');

    expect(result.powerWatts, 180);
    expect(result.powerSource, PowerSource.detected);
    expect(result.confidenceLevel, ConfidenceLevel.high);

    expect(result.voltageVolts, 220);
    expect(result.currentAmps, 0.8);
    expect(result.frequencyHz, 50);

    expect(result.matchedKeywords, contains('refrigerator'));
  });

  test('calcule la puissance avec V x A si les watts manquent', () async {
    final useCase = createUseCase('AIR CONDITIONER 230 V 2 A 50 Hz');

    final result = await useCase('label.jpg');

    expect(result.applianceType, 'air_conditioner');

    expect(result.powerWatts, 460);
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.medium);
  });

  test('utilise estimation comme dernier recours', () async {
    final useCase = createUseCase('VENTILATEUR 50 Hz');

    final result = await useCase('label.jpg');

    expect(result.applianceType, 'fan');

    expect(result.powerWatts, 75);
    expect(result.powerSource, PowerSource.estimated);
    expect(result.confidenceLevel, ConfidenceLevel.low);
  });

  test(
    'conserve plages et fréquences multiples sans choisir arbitrairement',
    () async {
      final useCase = createUseCase(
        'REFRIGERATOR 220-240 V 0,8-1,2 A 50/60 Hz',
      );

      final result = await useCase('label.jpg');

      expect(result.applianceType, 'refrigerator');

      expect(result.voltageVolts, isNull);
      expect(result.voltageRange, isNotNull);
      expect(result.voltageRange!.min, 220);
      expect(result.voltageRange!.max, 240);

      expect(result.currentAmps, isNull);
      expect(result.currentRange, isNotNull);
      expect(result.currentRange!.min, 0.8);
      expect(result.currentRange!.max, 1.2);

      expect(result.frequencyHz, isNull);
      expect(result.frequencyOptions, [50, 60]);

      // Impossible de calculer V × A à partir de plages sans règle explicite :
      // fallback sur l'estimation du réfrigérateur.
      expect(result.powerSource, PowerSource.estimated);
    },
  );
}
