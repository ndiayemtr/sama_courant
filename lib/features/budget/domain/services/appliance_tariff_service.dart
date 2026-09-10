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

  double calculateAllocatedMonthlyCost({
    required Appliance appliance,
    required List<Appliance> appliances,
    required TariffConfiguration configuration,
  }) {
    if (!appliance.isActive) {
      return 0;
    }

    final activeAppliances = appliances.where((item) => item.isActive).toList();

    final totalConsumptionKwh = activeAppliances.fold<double>(
      0,
      (total, item) => total + item.monthlyConsumptionKwh,
    );

    if (totalConsumptionKwh <= 0) {
      return 0;
    }

    final totalResult = tariffEngine.calculate(
      consumptionKwh: totalConsumptionKwh,
      configuration: configuration,
    );

    final consumptionShare =
        appliance.monthlyConsumptionKwh / totalConsumptionKwh;

    return totalResult.totalCost * consumptionShare;
  }
}
