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
  final bool includedInTariff;

  const TariffComponent({
    required this.name,
    required this.type,
    required this.calculationMethod,
    required this.value,
    required this.unit,
    required this.taxableBase,
    required this.includedInTariff,
  });
}
