import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart';
import 'package:sama_courant/features/consumption_history/domain/services/consumption_history_chart_service.dart';

void main() {
  const service = ConsumptionHistoryChartService();

  group('ConsumptionHistoryChartService', () {
    test('should return an empty list when snapshots are empty', () {
      final points = service.buildPoints(const []);

      expect(points, isEmpty);
    });

    test('should convert one snapshot into one history point', () {
      final capturedAt = DateTime(2026, 9, 11, 10, 30);

      final snapshot = ConsumptionSnapshot(
        id: 1,
        capturedAt: capturedAt,
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551,
        activeAppliancesCount: 2,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: capturedAt,
      );

      final points = service.buildPoints([snapshot]);

      expect(points, hasLength(1));

      final point = points.first;

      expect(point.capturedAt, capturedAt);
      expect(point.consumptionKwh, 55.5);
      expect(point.costFcfa, 4551);
    });

    test('should sort points from oldest to newest', () {
      final oldestDate = DateTime(2026, 9, 9, 8);
      final middleDate = DateTime(2026, 9, 10, 8);
      final newestDate = DateTime(2026, 9, 11, 8);

      final oldest = ConsumptionSnapshot(
        id: 1,
        capturedAt: oldestDate,
        totalMonthlyConsumptionKwh: 40,
        totalMonthlyCostFcfa: 3280,
        activeAppliancesCount: 1,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: oldestDate,
      );

      final middle = ConsumptionSnapshot(
        id: 2,
        capturedAt: middleDate,
        totalMonthlyConsumptionKwh: 48,
        totalMonthlyCostFcfa: 3936,
        activeAppliancesCount: 2,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: middleDate,
      );

      final newest = ConsumptionSnapshot(
        id: 3,
        capturedAt: newestDate,
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551,
        activeAppliancesCount: 2,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: newestDate,
      );

      final points = service.buildPoints([newest, oldest, middle]);

      expect(points, hasLength(3));

      expect(points[0].capturedAt, oldestDate);
      expect(points[1].capturedAt, middleDate);
      expect(points[2].capturedAt, newestDate);
    });

    test('should preserve consumption, cost and capture date', () {
      final firstDate = DateTime(2026, 9, 10, 9);
      final secondDate = DateTime(2026, 9, 11, 9);

      final snapshots = [
        ConsumptionSnapshot(
          id: 1,
          capturedAt: firstDate,
          totalMonthlyConsumptionKwh: 25.75,
          totalMonthlyCostFcfa: 2111.50,
          activeAppliancesCount: 1,
          tariffConfigurationName: 'Woyofal DPP 2026',
          createdAt: firstDate,
        ),
        ConsumptionSnapshot(
          id: 2,
          capturedAt: secondDate,
          totalMonthlyConsumptionKwh: 61.25,
          totalMonthlyCostFcfa: 5336.50,
          activeAppliancesCount: 3,
          tariffConfigurationName: 'Woyofal DPP 2026',
          createdAt: secondDate,
        ),
      ];

      final points = service.buildPoints(snapshots);

      expect(points, hasLength(2));

      expect(points[0].capturedAt, firstDate);
      expect(points[0].consumptionKwh, 25.75);
      expect(points[0].costFcfa, 2111.50);

      expect(points[1].capturedAt, secondDate);
      expect(points[1].consumptionKwh, 61.25);
      expect(points[1].costFcfa, 5336.50);
    });

    test('should not modify the original snapshots list order', () {
      final olderDate = DateTime(2026, 9, 10, 8);
      final newerDate = DateTime(2026, 9, 11, 8);

      final older = ConsumptionSnapshot(
        id: 1,
        capturedAt: olderDate,
        totalMonthlyConsumptionKwh: 40,
        totalMonthlyCostFcfa: 3280,
        activeAppliancesCount: 1,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: olderDate,
      );

      final newer = ConsumptionSnapshot(
        id: 2,
        capturedAt: newerDate,
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551,
        activeAppliancesCount: 2,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: newerDate,
      );

      final snapshots = [newer, older];

      service.buildPoints(snapshots);

      expect(snapshots[0], same(newer));
      expect(snapshots[1], same(older));
    });
  });
}
