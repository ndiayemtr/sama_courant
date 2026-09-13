import '../entities/tariff_calculation_method.dart';
import '../entities/tariff_component.dart';
import '../entities/tariff_component_calculation.dart';
import '../entities/tariff_component_type.dart';
import '../entities/tariff_taxable_base.dart';

class FeeCalculator {
  const FeeCalculator();

  double calculate({
    double? energyCost,
    double Function(double thresholdKwh)? excessEnergyCost,
    required double consumptionKwh,
    required List<TariffComponent> components,
  }) {
    final breakdown = calculateBreakdown(
      energyCost: energyCost,
      excessEnergyCost: excessEnergyCost,
      consumptionKwh: consumptionKwh,
      components: components,
    );

    return breakdown.fold<double>(
      0,
      (total, calculation) => total + calculation.amount,
    );
  }

  List<TariffComponentCalculation> calculateBreakdown({
    double? energyCost,
    double Function(double thresholdKwh)? excessEnergyCost,
    required double consumptionKwh,
    required List<TariffComponent> components,
  }) {
    final calculations = <TariffComponentCalculation>[];

    for (final component in components) {
      if (component.type != TariffComponentType.fee) {
        continue;
      }

      if (!component.enabled ||
          component.includedInTariff ||
          (component.thresholdKwh != null &&
              consumptionKwh <= component.thresholdKwh!)) {
        continue;
      }

      switch (component.calculationMethod) {
        case TariffCalculationMethod.perKwh:
          final applicableKwh = consumptionKwh - (component.thresholdKwh ?? 0);
          final amount = applicableKwh * component.value;

          calculations.add(
            TariffComponentCalculation(
              name: component.name,
              enabled: component.enabled,
              includedInTariff: component.includedInTariff,
              taxableBase: component.taxableBase,
              thresholdKwh: component.thresholdKwh,
              type: component.type,
              calculationMethod: component.calculationMethod,
              baseAmount: applicableKwh,
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
              enabled: component.enabled,
              includedInTariff: component.includedInTariff,
              taxableBase: component.taxableBase,
              thresholdKwh: component.thresholdKwh,
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
          break;
      }
    }

    // Percentage fees use the non-percentage fees as their explicit fee base.
    // This keeps the result independent of component ordering and avoids cycles.
    if (energyCost != null) {
      final fixedFees = calculations.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );
      for (final component in components) {
        if (component.type != TariffComponentType.fee ||
            component.calculationMethod != TariffCalculationMethod.percentage ||
            !component.enabled ||
            component.includedInTariff ||
            (component.thresholdKwh != null &&
                consumptionKwh <= component.thresholdKwh!)) {
          continue;
        }
        final base = switch (component.taxableBase) {
          TariffTaxableBase.excessEnergyCost =>
            (excessEnergyCost ??
                (throw ArgumentError('Missing tier cost resolver')))(
              component.thresholdKwh ?? 0,
            ),
          TariffTaxableBase.fees => fixedFees,
          TariffTaxableBase.energyAndFees ||
          TariffTaxableBase.subtotal => energyCost + fixedFees,
          _ => energyCost,
        };
        calculations.add(
          TariffComponentCalculation(
            name: component.name,
            enabled: component.enabled,
            includedInTariff: component.includedInTariff,
            taxableBase: component.taxableBase,
            thresholdKwh: component.thresholdKwh,
            type: component.type,
            calculationMethod: component.calculationMethod,
            baseAmount: base,
            value: component.value,
            unit: component.unit,
            amount: base * component.value / 100,
          ),
        );
      }
    }
    return calculations;
  }
}
