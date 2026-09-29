import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_normalizer.dart';

void main() {
  final normalizer = LabelTextNormalizer();

  test('normalise les accents et les majuscules', () {
    expect(
      normalizer.normalize('RÉFRIGÉRATEUR ÉLECTRIQUE'),
      'refrigerateur electrique',
    );
  });

  test('convertit la virgule décimale en point', () {
    expect(normalizer.normalize('220 V 0,8 A'), '220 v 0.8 a');
  });

  test('conserve les caractères électriques utiles', () {
    expect(normalizer.normalize('220-240V 2.2kW A/C'), '220-240v 2.2kw a/c');
  });

  test('réduit les espaces multiples', () {
    expect(
      normalizer.normalize('Samsung   Refrigerator\n120 W'),
      'samsung refrigerator 120 w',
    );
  });

  test('normalise une lecture OCR deformee de kWh par an', () {
    const normalizer = LabelTextNormalizer();

    final result = normalizer.normalize('355 kVWhiaño');

    expect(result, contains('355 kwh'));
  });
}
