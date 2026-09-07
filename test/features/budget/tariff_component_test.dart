import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';

void main() {
  group('TariffComponent', () {
    test('crée une composante énergétique', () {
      const component = TariffComponent(
        name: 'Énergie',
        type: TariffComponentType.energy,
        value: 82,
        unit: 'FCFA/kWh',
        includedInTariff: false,
      );

      expect(component.name, 'Énergie');
      expect(component.type, TariffComponentType.energy);
      expect(component.value, 82);
      expect(component.unit, 'FCFA/kWh');
      expect(component.includedInTariff, isFalse);
    });

    test('crée une redevance incluse dans le tarif', () {
      const component = TariffComponent(
        name: 'Redevance',
        type: TariffComponentType.fee,
        value: 0.7,
        unit: 'FCFA/kWh',
        includedInTariff: true,
      );

      expect(component.type, TariffComponentType.fee);
      expect(component.value, 0.7);
      expect(component.unit, 'FCFA/kWh');
      expect(component.includedInTariff, isTrue);
    });

    test('crée une taxe exprimée en pourcentage', () {
      const component = TariffComponent(
        name: 'TVA',
        type: TariffComponentType.tax,
        value: 18,
        unit: '%',
        includedInTariff: false,
      );

      expect(component.name, 'TVA');
      expect(component.type, TariffComponentType.tax);
      expect(component.value, 18);
      expect(component.unit, '%');
      expect(component.includedInTariff, isFalse);
    });
  });
}
