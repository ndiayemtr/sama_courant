import 'tariff_calculation_method.dart';
import 'tariff_component_type.dart';
import 'tariff_taxable_base.dart';

class TariffComponentCalculation {
  final String name;
  final TariffComponentType type;
  final TariffCalculationMethod calculationMethod;
  final double? baseAmount;
  final double value;
  final String unit;
  final double amount;
  final bool enabled;
  final bool includedInTariff;
  final TariffTaxableBase? taxableBase;
  final double? thresholdKwh;

  /// Calculators only return enabled components not already included in energy.
  bool get includedInTotal => enabled && !includedInTariff;

  const TariffComponentCalculation({
    required this.name,
    required this.type,
    required this.calculationMethod,
    required this.baseAmount,
    required this.value,
    required this.unit,
    required this.amount,
    this.enabled = true,
    this.includedInTariff = false,
    this.taxableBase,
    this.thresholdKwh,
  });
}
