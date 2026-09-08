import '../entities/tariff_calculation_method.dart';
import '../entities/tariff_component.dart';
import '../entities/tariff_component_calculation.dart';
import '../entities/tariff_component_type.dart';
import '../entities/tariff_taxable_base.dart';

class TaxCalculator {
  const TaxCalculator();

  double calculate({
    required double energyCost,
    required double fees,
    required List<TariffComponent> components,
  }) {
    final breakdown = calculateBreakdown(
      energyCost: energyCost,
      fees: fees,
      components: components,
    );

    return breakdown.fold<double>(
      0,
      (total, calculation) => total + calculation.amount,
    );
  }

  List<TariffComponentCalculation> calculateBreakdown({
    required double energyCost,
    required double fees,
    required List<TariffComponent> components,
  }) {
    final calculations = <TariffComponentCalculation>[];

    for (final component in components) {
      if (component.type != TariffComponentType.tax) {
        continue;
      }

      if (component.includedInTariff) {
        continue;
      }

      switch (component.calculationMethod) {
        case TariffCalculationMethod.percentage:
          final baseAmount = _calculateTaxableBase(
            taxableBase: component.taxableBase,
            energyCost: energyCost,
            fees: fees,
          );

          if (baseAmount <= 0) {
            continue;
          }

          final amount = baseAmount * component.value / 100;

          calculations.add(
            TariffComponentCalculation(
              name: component.name,
              type: component.type,
              calculationMethod: component.calculationMethod,
              baseAmount: baseAmount,
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

        case TariffCalculationMethod.perKwh:
          // Une taxe au kWh n'est pas encore traitée.
          // Elle pourra être ajoutée lorsqu'une règle
          // réglementaire nécessitera explicitement ce mode.
          break;
      }
    }

    return calculations;
  }

  double _calculateTaxableBase({
    required TariffTaxableBase? taxableBase,
    required double energyCost,
    required double fees,
  }) {
    switch (taxableBase) {
      case TariffTaxableBase.energy:
        return energyCost;

      case TariffTaxableBase.fees:
        return fees;

      case TariffTaxableBase.energyAndFees:
        return energyCost + fees;

      case TariffTaxableBase.subtotal:
        return energyCost + fees;

      case null:
        return 0;
    }
  }
}
