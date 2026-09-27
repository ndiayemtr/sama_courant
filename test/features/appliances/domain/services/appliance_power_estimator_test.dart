import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_power_estimate.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_power_estimator.dart';

void main() {
  test('utilise le catalogue local par défaut', () {
    const estimator = AppliancePowerEstimator();

    final result = estimator.estimate('fan');

    expect(result.powerWatts, 75);
    expect(result.minWatts, 40);
    expect(result.maxWatts, 250);
    expect(result.powerSource, PowerSource.estimated);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.hasPower, isTrue);
    expect(result.hasEstimatedRange, isTrue);
  });

  test('accepte un catalogue injecté pour les tests', () {
    const estimator = AppliancePowerEstimator(
      estimates: {
        'test_device': AppliancePowerEstimate(
          typicalWatts: 100,
          minWatts: 80,
          maxWatts: 120,
        ),
      },
    );

    final result = estimator.estimate('test_device');

    expect(result.powerWatts, 100);
    expect(result.minWatts, 80);
    expect(result.maxWatts, 120);
  });

  test('retourne aucune puissance pour une catégorie inconnue', () {
    const estimator = AppliancePowerEstimator();

    final result = estimator.estimate('unknown');

    expect(result.powerWatts, isNull);
    expect(result.powerSource, isNull);
    expect(result.hasPower, isFalse);
    expect(result.hasEstimatedRange, isFalse);
  });

  test('retourne aucune puissance si la catégorie est null', () {
    const estimator = AppliancePowerEstimator();

    final result = estimator.estimate(null);

    expect(result.powerWatts, isNull);
    expect(result.hasPower, isFalse);
  });

  test('rejette une estimation incohérente', () {
    const estimator = AppliancePowerEstimator(
      estimates: {
        'invalid': AppliancePowerEstimate(
          typicalWatts: 300,
          minWatts: 400,
          maxWatts: 500,
        ),
      },
    );

    final result = estimator.estimate('invalid');

    expect(result.powerWatts, isNull);
    expect(result.hasPower, isFalse);
  });
}
