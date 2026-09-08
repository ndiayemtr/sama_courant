import '../../domain/entities/tariff_calculation_result.dart';
import '../../domain/entities/tariff_configuration.dart';
import '../../domain/services/tariff_engine.dart';
import '../../domain/services/tier_calculator.dart';

class TariffEngineImpl implements TariffEngine {
  final TierCalculator tierCalculator;

  const TariffEngineImpl({this.tierCalculator = const TierCalculator()});

  @override
  TariffCalculationResult calculate({
    required double consumptionKwh,
    required TariffConfiguration configuration,
  }) {
    final tierCalculations = tierCalculator.calculate(
      consumptionKwh: consumptionKwh,
      tiers: configuration.tiers,
    );

    final energyCost = tierCalculations.fold<double>(
      0,
      (total, calculation) => total + calculation.cost,
    );

    return TariffCalculationResult(
      consumptionKwh: consumptionKwh,
      energyCost: energyCost,
      fees: 0,
      taxes: 0,
      totalCost: energyCost,
      tierCalculations: tierCalculations,
    );
  }
}
