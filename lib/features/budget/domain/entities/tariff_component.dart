import 'tariff_calculation_method.dart';
import 'tariff_component_type.dart';
import 'tariff_taxable_base.dart';

class TariffComponent {
  final String name;
  final TariffComponentType type;
  final TariffCalculationMethod calculationMethod;
  final double value;
  final String unit;
  final TariffTaxableBase? taxableBase;

  /// Already included in the energy price; must not be added again.
  final bool includedInTariff;

  /// Whether this component participates in the calculation.
  final bool enabled;

  /// Optional consumption threshold in kWh, without applicability logic here.
  final double? thresholdKwh;

  const TariffComponent({
    required this.name,
    required this.type,
    required this.calculationMethod,
    required this.value,
    required this.unit,
    required this.taxableBase,
    required this.includedInTariff,
    this.enabled = true,
    this.thresholdKwh,
  });
}
