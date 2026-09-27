import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/services/power_resolver.dart';

void main() {
  const resolver = PowerResolver();

  test('priorise la puissance détectée directement', () {
    final result = resolver.resolve(
      detectedPowerWatts: 180,
      voltageVolts: 220,
      currentAmps: 0.8,
    );

    expect(result.powerWatts, 180);
    expect(result.powerSource, PowerSource.detected);
    expect(result.confidenceLevel, ConfidenceLevel.high);
    expect(result.hasPower, isTrue);
  });

  test('calcule V x A x PF quand le facteur de puissance existe', () {
    final result = resolver.resolve(
      voltageVolts: 230,
      currentAmps: 2,
      powerFactor: 0.85,
    );

    expect(result.powerWatts, closeTo(391, 0.0001));
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.high);
  });

  test('calcule V x A sans facteur de puissance', () {
    final result = resolver.resolve(voltageVolts: 220, currentAmps: 0.8);

    expect(result.powerWatts, closeTo(176, 0.0001));
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.medium);
  });

  test('retourne aucune puissance avec seulement la tension', () {
    final result = resolver.resolve(voltageVolts: 220);

    expect(result.powerWatts, isNull);
    expect(result.powerSource, isNull);
    expect(result.confidenceLevel, ConfidenceLevel.low);
    expect(result.hasPower, isFalse);
  });

  test('retourne aucune puissance avec seulement le courant', () {
    final result = resolver.resolve(currentAmps: 0.8);

    expect(result.powerWatts, isNull);
    expect(result.powerSource, isNull);
    expect(result.hasPower, isFalse);
  });

  test('ignore un facteur de puissance invalide', () {
    final result = resolver.resolve(
      voltageVolts: 220,
      currentAmps: 1,
      powerFactor: 1.5,
    );

    expect(result.powerWatts, 220);
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.medium);
  });

  test('ignore une puissance détectée négative', () {
    final result = resolver.resolve(detectedPowerWatts: -100);

    expect(result.powerWatts, isNull);
    expect(result.hasPower, isFalse);
  });
}
