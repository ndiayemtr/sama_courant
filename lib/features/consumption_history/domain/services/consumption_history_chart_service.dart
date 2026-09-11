import '../entities/consumption_history_point.dart';
import '../entities/consumption_snapshot.dart';

class ConsumptionHistoryChartService {
  const ConsumptionHistoryChartService();

  List<ConsumptionHistoryPoint> buildPoints(
    List<ConsumptionSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) {
      return const [];
    }

    final sortedSnapshots = [...snapshots]
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    return sortedSnapshots
        .map(
          (snapshot) => ConsumptionHistoryPoint(
            capturedAt: snapshot.capturedAt,
            consumptionKwh: snapshot.totalMonthlyConsumptionKwh,
            costFcfa: snapshot.totalMonthlyCostFcfa,
          ),
        )
        .toList(growable: false);
  }
}
