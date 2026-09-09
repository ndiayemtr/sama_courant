import '../../../appliances/domain/entities/appliance.dart';
import '../entities/tariff_calculation_result.dart';
import '../entities/tariff_configuration.dart';
import 'tariff_engine.dart';

class ApplianceTariffService {
  final TariffEngine tariffEngine;

  const ApplianceTariffService({required this.tariffEngine});

  TariffCalculationResult calculateMonthlyCost({
    required Appliance appliance,
    required TariffConfiguration configuration,
  }) {
    final consumptionKwh = appliance.monthlyConsumptionKwh;

    return tariffEngine.calculate(
      consumptionKwh: consumptionKwh,
      configuration: configuration,
    );
  }

  TariffCalculationResult calculateCost({
    required double consumptionKwh,
    required TariffConfiguration configuration,
  }) {
    return tariffEngine.calculate(
      consumptionKwh: consumptionKwh,
      configuration: configuration,
    );
  }
}
