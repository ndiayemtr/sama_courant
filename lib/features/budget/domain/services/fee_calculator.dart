import '../entities/tariff_calculation_method.dart';
import '../entities/tariff_component.dart';
import '../entities/tariff_component_type.dart';

class FeeCalculator {
  const FeeCalculator();

  double calculate({
    required double consumptionKwh,
    required List<TariffComponent> components,
  }) {
    var totalFees = 0.0;

    for (final component in components) {
      if (component.type != TariffComponentType.fee) {
        continue;
      }

      if (component.includedInTariff) {
        continue;
      }

      switch (component.calculationMethod) {
        case TariffCalculationMethod.perKwh:
          totalFees += consumptionKwh * component.value;
          break;

        case TariffCalculationMethod.fixed:
          totalFees += component.value;
          break;

        case TariffCalculationMethod.percentage:
          // Les pourcentages sont traités par le calculateur de taxes.
          break;
      }
    }

    return totalFees;
  }
}
