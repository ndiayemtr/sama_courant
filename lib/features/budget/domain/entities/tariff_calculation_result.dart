import 'tariff_tier_calculation.dart';

class TariffCalculationResult {
  final double consumptionKwh;
  final double energyCost;
  final double fees;
  final double taxes;
  final double totalCost;
  final List<TariffTierCalculation> tierCalculations;

  const TariffCalculationResult({
    required this.consumptionKwh,
    required this.energyCost,
    required this.fees,
    required this.taxes,
    required this.totalCost,
    required this.tierCalculations,
  });
}
