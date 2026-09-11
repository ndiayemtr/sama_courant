class ConsumptionHistoryPoint {
  final DateTime capturedAt;
  final double consumptionKwh;
  final double costFcfa;

  const ConsumptionHistoryPoint({
    required this.capturedAt,
    required this.consumptionKwh,
    required this.costFcfa,
  });
}
