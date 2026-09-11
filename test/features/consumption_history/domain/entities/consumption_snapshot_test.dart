import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart';

void main() {
  test(
    'preserves all estimation fields without rounding or changing dates',
    () {
      final capturedAt = DateTime.utc(2026, 9, 11, 10, 30);
      final createdAt = DateTime.utc(2026, 9, 11, 10, 31);
      final snapshot = ConsumptionSnapshot(
        id: 42,
        capturedAt: capturedAt,
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551.75,
        activeAppliancesCount: 3,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: createdAt,
      );

      expect(snapshot.id, 42);
      expect(snapshot.capturedAt, capturedAt);
      expect(snapshot.createdAt, createdAt);
      expect(snapshot.capturedAt.isUtc, isTrue);
      expect(snapshot.totalMonthlyConsumptionKwh, 55.5);
      expect(snapshot.totalMonthlyCostFcfa, 4551.75);
      expect(snapshot.activeAppliancesCount, 3);
      expect(snapshot.tariffConfigurationName, 'Woyofal DPP 2026');
    },
  );

  test('allows an omitted local id and a zero-consumption snapshot', () {
    final date = DateTime(2026, 9, 11);
    final snapshot = ConsumptionSnapshot(
      capturedAt: date,
      totalMonthlyConsumptionKwh: 0,
      totalMonthlyCostFcfa: 0,
      activeAppliancesCount: 0,
      tariffConfigurationName: 'Woyofal DPP 2026',
      createdAt: date,
    );

    expect(snapshot.id, isNull);
    expect(snapshot.totalMonthlyConsumptionKwh, 0);
    expect(snapshot.totalMonthlyCostFcfa, 0);
    expect(snapshot.activeAppliancesCount, 0);
    expect(snapshot.capturedAt, date);
    expect(snapshot.createdAt, date);
  });
}
