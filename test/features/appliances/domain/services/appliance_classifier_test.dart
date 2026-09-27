import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_classifier.dart';

void main() {
  const classifier = ApplianceClassifier();

  test('reconnait un refrigerateur avec un mot-cle fort', () {
    final result = classifier.classify(
      'samsung refrigerator model rt38 220 v 120 w',
    );

    expect(result.category, 'refrigerator');
    expect(result.confidenceLevel, ConfidenceLevel.high);
    expect(result.score, greaterThanOrEqualTo(5));
    expect(result.matchedKeywords, contains('refrigerator'));
    expect(result.isRecognized, isTrue);
  });

  test('reconnait un climatiseur avec plusieurs indices techniques', () {
    final result = classifier.classify(
      'cooling capacity 12000 btu refrigerant r410a',
    );

    expect(result.category, 'air_conditioner');
    expect(result.score, greaterThanOrEqualTo(3));
    expect(result.isRecognized, isTrue);
  });

  test('un mot faible seul produit une confiance faible', () {
    final result = classifier.classify('split 220 v 50 hz');

    expect(result.category, 'air_conditioner');
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.score, 1);
  });

  test('ac seul ne doit pas matcher a interieur d un autre mot', () {
    final result = classifier.classify('capacity 120 w');

    expect(result.category, isNull);
    expect(result.score, 0);
    expect(result.isRecognized, isFalse);
  });

  test('retourne non reconnu sans indice exploitable', () {
    final result = classifier.classify('220 v 50 hz 180 w model xyz');

    expect(result.category, isNull);
    expect(result.score, 0);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.isRecognized, isFalse);
  });

  test('ne choisit pas arbitrairement en cas d egalite', () {
    final result = classifier.classify('inverter 220 v 50 hz');

    expect(result.category, isNull);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.score, 1);
    expect(result.isRecognized, isFalse);
  });
}
