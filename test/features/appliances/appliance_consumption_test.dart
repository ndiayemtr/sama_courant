import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';

void main() {
  group('Appliance - propriétés de consommation', () {
    final createdAt = DateTime(2026, 1, 1);

    test('calcule la consommation horaire', () {
      final appliance = Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 8,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(appliance.hourlyConsumptionKwh, closeTo(0.15, 0.0001));
    });

    test('calcule la consommation quotidienne', () {
      final appliance = Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 8,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(appliance.dailyConsumptionKwh, closeTo(1.2, 0.0001));
    });

    test('calcule la consommation mensuelle', () {
      final appliance = Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 8,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(appliance.monthlyConsumptionKwh, closeTo(36.0, 0.0001));
    });

    test('calcule la consommation annuelle', () {
      final appliance = Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 8,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(appliance.yearlyConsumptionKwh, closeTo(438.0, 0.0001));
    });

    test('prend en compte plusieurs appareils identiques', () {
      final appliance = Appliance(
        name: 'Ampoule',
        category: 'Éclairage',
        powerWatts: 100,
        quantity: 3,
        hoursPerDay: 5,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(appliance.hourlyConsumptionKwh, closeTo(0.3, 0.0001));

      expect(appliance.dailyConsumptionKwh, closeTo(1.5, 0.0001));

      expect(appliance.monthlyConsumptionKwh, closeTo(45.0, 0.0001));

      expect(appliance.yearlyConsumptionKwh, closeTo(547.5, 0.0001));
    });

    test(
      'la consommation théorique reste calculable pour un appareil inactif',
      () {
        final appliance = Appliance(
          name: 'Climatiseur',
          category: 'Chambre',
          powerWatts: 1000,
          quantity: 1,
          hoursPerDay: 6,
          daysPerMonth: 30,
          isActive: false,
          createdAt: createdAt,
          updatedAt: createdAt,
        );

        expect(appliance.dailyConsumptionKwh, closeTo(6.0, 0.0001));

        expect(appliance.monthlyConsumptionKwh, closeTo(180.0, 0.0001));
      },
    );
  });
}
