import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/services/appliance_tariff_service.dart';

void main() {
  group('ApplianceTariffService - DPP Woyofal 2026', () {
    final service = ApplianceTariffService(
      tariffEngine: const TariffEngineImpl(),
    );

    final configuration = WoyofalTariffConfigurationFactory.dpp2026();

    test('should calculate monthly cost for a 100W appliance used 5h/day', () {
      final appliance = Appliance(
        name: 'Réfrigérateur',
        category: 'Cuisine',
        powerWatts: 100,
        quantity: 1,
        hoursPerDay: 5,
        daysPerMonth: 30,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = service.calculateMonthlyCost(
        appliance: appliance,
        configuration: configuration,
      );

      expect(result.consumptionKwh, 15);
      expect(result.energyCost, 1230);
      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, 1230);
    });

    test(
      'should calculate monthly cost for two appliances of the same type',
      () {
        final appliance = Appliance(
          name: 'Climatiseur',
          category: 'Chambre',
          powerWatts: 500,
          quantity: 2,
          hoursPerDay: 4,
          daysPerMonth: 30,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        final result = service.calculateMonthlyCost(
          appliance: appliance,
          configuration: configuration,
        );

        // 500 W × 4 h × 2 × 30 / 1000 = 120 kWh
        expect(result.consumptionKwh, 120);

        // 120 × 82 = 9 840 FCFA
        expect(result.energyCost, 9840);
        expect(result.totalCost, 9840);
      },
    );

    test(
      'should apply progressive Woyofal pricing to a high-consuming appliance',
      () {
        final appliance = Appliance(
          name: 'Climatiseur',
          category: 'Salon',
          powerWatts: 1500,
          quantity: 1,
          hoursPerDay: 8,
          daysPerMonth: 30,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        final result = service.calculateMonthlyCost(
          appliance: appliance,
          configuration: configuration,
        );

        // 1500 W × 8 h × 30 / 1000 = 360 kWh
        expect(result.consumptionKwh, 360);

        // 150 kWh × 82
        // + 100 kWh × 136.49
        // + 110 kWh × 136.49
        expect(result.energyCost, closeTo(40962.90, 0.001));
        expect(result.totalCost, closeTo(40962.90, 0.001));
      },
    );
  });
}
