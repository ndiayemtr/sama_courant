import '../../domain/entities/tariff_calculation_result.dart';
import '../../domain/entities/tariff_configuration.dart';
import '../../domain/services/fee_calculator.dart';
import '../../domain/services/tariff_configuration_validator.dart';
import '../../domain/services/tariff_engine.dart';
import '../../domain/services/tax_calculator.dart';
import '../../domain/services/tier_calculator.dart';

class TariffEngineImpl implements TariffEngine {
  final TierCalculator tierCalculator;
  final FeeCalculator feeCalculator;
  final TaxCalculator taxCalculator;
  final TariffConfigurationValidator configurationValidator;

  const TariffEngineImpl({
    this.tierCalculator = const TierCalculator(),
    this.feeCalculator = const FeeCalculator(),
    this.taxCalculator = const TaxCalculator(),
    this.configurationValidator = const TariffConfigurationValidator(),
  });

  @override
  TariffCalculationResult calculate({
    required double consumptionKwh,
    required TariffConfiguration configuration,
  }) {
    final validationErrors = configurationValidator.validate(configuration);

    if (validationErrors.isNotEmpty) {
      throw ArgumentError(
        'Configuration tarifaire invalide: '
        '${validationErrors.join(' ')}',
      );
    }
    final tierCalculations = tierCalculator.calculate(
      consumptionKwh: consumptionKwh,
      tiers: configuration.tiers,
    );

    final energyCost = tierCalculations.fold<double>(
      0,
      (total, calculation) => total + calculation.cost,
    );

    final feeCalculations = feeCalculator.calculateBreakdown(
      consumptionKwh: consumptionKwh,
      components: configuration.components,
    );

    final fees = feeCalculations.fold<double>(
      0,
      (total, calculation) => total + calculation.amount,
    );

    final taxCalculations = taxCalculator.calculateBreakdown(
      energyCost: energyCost,
      fees: fees,
      components: configuration.components,
    );

    final taxes = taxCalculations.fold<double>(
      0,
      (total, calculation) => total + calculation.amount,
    );

    final totalCost = energyCost + fees + taxes;

    return TariffCalculationResult(
      consumptionKwh: consumptionKwh,
      energyCost: energyCost,
      fees: fees,
      taxes: taxes,
      totalCost: totalCost,
      tierCalculations: tierCalculations,
      feeCalculations: feeCalculations,
      taxCalculations: taxCalculations,
    );
  }
}
