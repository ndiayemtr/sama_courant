import 'tariff_calculation_method.dart';
import 'tariff_component_type.dart';

class TariffComponentCalculation {
  final String name;
  final TariffComponentType type;
  final TariffCalculationMethod calculationMethod;
  final double? baseAmount;
  final double value;
  final String unit;
  final double amount;

  const TariffComponentCalculation({
    required this.name,
    required this.type,
    required this.calculationMethod,
    required this.baseAmount,
    required this.value,
    required this.unit,
    required this.amount,
  });
}
