class TariffCalculationResult {
  final double consumptionKwh;
  final double energyCost;
  final double fees;
  final double taxes;
  final double totalCost;

  const TariffCalculationResult({
    required this.consumptionKwh,
    required this.energyCost,
    required this.fees,
    required this.taxes,
    required this.totalCost,
  });
}
