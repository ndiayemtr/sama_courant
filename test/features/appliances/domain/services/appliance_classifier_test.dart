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

  test('un mot faible seul ne suffit pas pour classifier', () {
    final result = classifier.classify('split 220 v 50 hz');

    expect(result.category, isNull);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.score, 1);
    expect(result.isRecognized, isFalse);
  });

  test('reconnait refrigerador comme refrigerateur', () {
    final result = classifier.classify(
      'samsung refrigerador modelo rt35k5982sl',
    );

    expect(result.category, 'refrigerator');
    expect(result.confidenceLevel, ConfidenceLevel.high);
    expect(result.isRecognized, isTrue);
  });

  test('refrigerant seul ne classe pas comme refrigerateur', () {
    final result = classifier.classify('refrigerant r-410a 115 v 8.5 a');

    expect(result.category, isNull);
    expect(result.isRecognized, isFalse);
  });

  test('r410a seul ne suffit pas pour classifier un climatiseur', () {
    final result = classifier.classify('refrigerant r-410a 115 v 8.5 a 980 w');

    expect(result.category, isNull);
    expect(result.isRecognized, isFalse);
  });

  test('reconnait un climatiseur avec plusieurs indices techniques', () {
    final result = classifier.classify(
      'cooling capacity 12000 btu refrigerant r-410a',
    );

    expect(result.category, 'air_conditioner');
    expect(result.isRecognized, isTrue);
    expect(result.score, greaterThanOrEqualTo(3));
  });

  test('reconnait une lavadora comme machine a laver', () {
    final result = classifier.classify('lavadora 7 kg 1400 rpm');

    expect(result.category, 'washing_machine');
    expect(result.confidenceLevel, ConfidenceLevel.high);
    expect(result.isRecognized, isTrue);
  });

  test('reconnait televisor comme television', () {
    final result = classifier.classify('samsung televisor led model ue55f6400');

    expect(result.category, 'television');
    expect(result.confidenceLevel, ConfidenceLevel.high);
    expect(result.isRecognized, isTrue);
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
