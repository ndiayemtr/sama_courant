import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_label_type.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_type_detector.dart';

void main() {
  const detector = ApplianceLabelTypeDetector();

  test('detecte une plaque signaletique', () {
    final result = detector.detect('model rt38 220 v 0.8 a 50 hz 180 w');

    expect(result, ApplianceLabelType.technicalPlate);
  });

  test('detecte une etiquette energetique', () {
    final result = detector.detect('bosch 216 kwh/annum 375 l 105 l 42 db');

    expect(result, ApplianceLabelType.energyLabel);
  });

  test('detecte une etiquette mixte', () {
    final result = detector.detect(
      'bosch refrigerator 220 v 50 hz 180 w 216 kwh/annum',
    );

    expect(result, ApplianceLabelType.mixed);
  });

  test('retourne unknown sans indice exploitable', () {
    final result = detector.detect('bosch model xyz');

    expect(result, ApplianceLabelType.unknown);
  });
}
