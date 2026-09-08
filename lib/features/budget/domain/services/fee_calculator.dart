import '../entities/tariff_calculation_method.dart';
import '../entities/tariff_component.dart';
import '../entities/tariff_component_calculation.dart';
import '../entities/tariff_component_type.dart';

class FeeCalculator {
  const FeeCalculator();

  double calculate({
    required double consumptionKwh,
    required List<TariffComponent> components,
  }) {
    final breakdown = calculateBreakdown(
      consumptionKwh: consumptionKwh,
      components: components,
    );

    return breakdown.fold<double>(
      0,
      (total, calculation) => total + calculation.amount,
    );
  }

  List<TariffComponentCalculation> calculateBreakdown({
    required double consumptionKwh,
    required List<TariffComponent> components,
  }) {
    final calculations = <TariffComponentCalculation>[];

    for (final component in components) {
      if (component.type != TariffComponentType.fee) {
        continue;
      }

      if (component.includedInTariff) {
        continue;
      }

      switch (component.calculationMethod) {
        case TariffCalculationMethod.perKwh:
          final amount = consumptionKwh * component.value;

          calculations.add(
            TariffComponentCalculation(
              name: component.name,
              type: component.type,
              calculationMethod: component.calculationMethod,
              baseAmount: consumptionKwh,
              value: component.value,
              unit: component.unit,
              amount: amount,
            ),
          );
          break;

        case TariffCalculationMethod.fixed:
          calculations.add(
            TariffComponentCalculation(
              name: component.name,
              type: component.type,
              calculationMethod: component.calculationMethod,
              baseAmount: null,
              value: component.value,
              unit: component.unit,
              amount: component.value,
            ),
          );
          break;

        case TariffCalculationMethod.percentage:
          // Les frais en pourcentage sont traités par la
          // couche fiscale et ne sont pas calculés ici.
          break;
      }
    }

    return calculations;
  }
}
