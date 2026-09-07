import 'tariff_component_type.dart';

class TariffComponent {
  final String name;
  final TariffComponentType type;
  final double value;
  final String unit;
  final bool includedInTariff;

  const TariffComponent({
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.includedInTariff,
  });
}
