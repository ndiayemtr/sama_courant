class TariffTierCalculation {
  final int tierOrder;
  final double consumedKwh;
  final double pricePerKwh;
  final double cost;

  const TariffTierCalculation({
    required this.tierOrder,
    required this.consumedKwh,
    required this.pricePerKwh,
    required this.cost,
  });
}
