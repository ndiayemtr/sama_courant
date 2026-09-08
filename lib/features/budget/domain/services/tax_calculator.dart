import '../entities/tariff_calculation_method.dart';
import '../entities/tariff_component.dart';
import '../entities/tariff_component_type.dart';
import '../entities/tariff_taxable_base.dart';

class TaxCalculator {
  const TaxCalculator();

  double calculate({
    required double energyCost,
    required double fees,
    required List<TariffComponent> components,
  }) {
    var totalTaxes = 0.0;

    for (final component in components) {
      if (component.type != TariffComponentType.tax) {
        continue;
      }

      if (component.includedInTariff) {
        continue;
      }

      switch (component.calculationMethod) {
        case TariffCalculationMethod.percentage:
          final base = _calculateTaxableBase(
            taxableBase: component.taxableBase,
            energyCost: energyCost,
            fees: fees,
          );

          totalTaxes += base * component.value / 100;
          break;

        case TariffCalculationMethod.fixed:
          totalTaxes += component.value;
          break;

        case TariffCalculationMethod.perKwh:
          // Une taxe au kWh n'est pas traitée ici.
          // Elle pourra être ajoutée si une règle réglementaire
          // nécessite explicitement ce mode.
          break;
      }
    }

    return totalTaxes;
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
