import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_power_estimator.dart';

void main() {
  const estimator = AppliancePowerEstimator(
    estimates: {'fan': 60, 'television': 100},
  );

  test('retourne une estimation pour une catégorie connue', () {
    final result = estimator.estimate('fan');

    expect(result.powerWatts, 60);
    expect(result.powerSource, PowerSource.estimated);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.hasPower, isTrue);
  });

  test('retourne aucune puissance pour une catégorie inconnue', () {
    final result = estimator.estimate('unknown');

    expect(result.powerWatts, isNull);
    expect(result.powerSource, isNull);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.hasPower, isFalse);
  });

  test('retourne aucune puissance si la catégorie est null', () {
    final result = estimator.estimate(null);

    expect(result.powerWatts, isNull);
    expect(result.hasPower, isFalse);
  });

  test('ignore une estimation invalide', () {
    const invalidEstimator = AppliancePowerEstimator(estimates: {'fan': -10});

    final result = invalidEstimator.estimate('fan');

    expect(result.powerWatts, isNull);
    expect(result.hasPower, isFalse);
  });
}
