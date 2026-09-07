import '../entities/tariff_calculation_result.dart';
import '../entities/tariff_configuration.dart';

abstract interface class TariffEngine {
  TariffCalculationResult calculate({
    required double consumptionKwh,
    required TariffConfiguration configuration,
  });
}
