import 'tariff_component_calculation.dart';
import 'tariff_tier_calculation.dart';

class TariffCalculationResult {
  final double consumptionKwh;
  final double energyCost;
  final double fees;
  final double taxes;
  final double totalCost;
  final List<TariffTierCalculation> tierCalculations;
  final List<TariffComponentCalculation> feeCalculations;
  final List<TariffComponentCalculation> taxCalculations;

  const TariffCalculationResult({
    required this.consumptionKwh,
    required this.energyCost,
    required this.fees,
    required this.taxes,
    required this.totalCost,
    required this.tierCalculations,
    required this.feeCalculations,
    required this.taxCalculations,
  });
}
