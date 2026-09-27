import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_scan_result.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/numeric_range.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';

void main() {
  test('transporte les valeurs électriques simples', () {
    const result = ApplianceScanResult(
      rawOcrText: '220 v 0.8 a 50 hz 180 w',
      powerWatts: 180,
      voltageVolts: 220,
      currentAmps: 0.8,
      frequencyHz: 50,
      powerSource: PowerSource.detected,
      confidenceLevel: ConfidenceLevel.high,
    );

    expect(result.powerWatts, 180);
    expect(result.voltageVolts, 220);
    expect(result.currentAmps, 0.8);
    expect(result.frequencyHz, 50);

    expect(result.voltageRange, isNull);
    expect(result.currentRange, isNull);
    expect(result.frequencyOptions, isEmpty);
  });

  test('transporte les plages et fréquences multiples', () {
    const result = ApplianceScanResult(
      rawOcrText: '220-240 v 0.8-1.2 a 50/60 hz',
      voltageRange: NumericRange(min: 220, max: 240),
      currentRange: NumericRange(min: 0.8, max: 1.2),
      frequencyOptions: [50, 60],
      confidenceLevel: ConfidenceLevel.high,
    );

    expect(result.voltageVolts, isNull);
    expect(result.voltageRange!.min, 220);
    expect(result.voltageRange!.max, 240);

    expect(result.currentAmps, isNull);
    expect(result.currentRange!.min, 0.8);
    expect(result.currentRange!.max, 1.2);

    expect(result.frequencyHz, isNull);
    expect(result.frequencyOptions, [50, 60]);
  });
}
