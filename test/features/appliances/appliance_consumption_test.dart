import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';

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

  test('keeps legacy monthly consumption when new usage model is absent', () {
    final appliance = Appliance(
      id: 1,
      name: 'Télévision',
      category: 'Électronique',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 8,
      daysPerMonth: 30,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.usesNewUsageModel, isFalse);
    expect(appliance.monthlyConsumptionKwh, closeTo(36.0, 0.0001));
  });

  test('calculates monthly consumption with daily usage model', () {
    final appliance = Appliance(
      id: 1,
      name: 'Ventilateur',
      category: 'Ventilation',
      powerWatts: 100,
      quantity: 1,

      // legacy conservé pour compatibilité
      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 120,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,

      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.usesNewUsageModel, isTrue);
    expect(appliance.monthlyFrequencyMultiplier, 30);
    expect(appliance.monthlyConsumptionKwh, closeTo(6.0, 0.0001));
  });

  test('calculates monthly consumption with daily usage model', () {
    final appliance = Appliance(
      id: 1,
      name: 'Ventilateur',
      category: 'Ventilation',
      powerWatts: 100,
      quantity: 1,

      // legacy conservé pour compatibilité
      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 120,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,

      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.usesNewUsageModel, isTrue);
    expect(appliance.monthlyFrequencyMultiplier, 30);
    expect(appliance.monthlyConsumptionKwh, closeTo(6.0, 0.0001));
  });

  test('calculates monthly consumption with weekly usage model', () {
    final appliance = Appliance(
      id: 1,
      name: 'Fer à repasser',
      category: 'Électroménager',
      powerWatts: 1600,
      quantity: 1,

      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 30,
      usageCount: 2,
      usageFrequency: UsageFrequency.weekly,

      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.usesNewUsageModel, isTrue);
    expect(appliance.monthlyFrequencyMultiplier, closeTo(4.33, 0.0001));
    expect(appliance.monthlyConsumptionKwh, closeTo(6.928, 0.0001));
  });

  test('calculates monthly consumption with monthly usage model', () {
    final appliance = Appliance(
      id: 1,
      name: 'Pompe',
      category: 'Autre',
      powerWatts: 1000,
      quantity: 1,

      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 90,
      usageCount: 4,
      usageFrequency: UsageFrequency.monthly,

      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.usesNewUsageModel, isTrue);
    expect(appliance.monthlyFrequencyMultiplier, 1);
    expect(appliance.monthlyConsumptionKwh, closeTo(6.0, 0.0001));
  });

  test('new usage model includes appliance quantity', () {
    final appliance = Appliance(
      id: 1,
      name: 'Ventilateurs',
      category: 'Ventilation',
      powerWatts: 100,
      quantity: 3,

      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 120,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,

      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(appliance.monthlyConsumptionKwh, closeTo(18.0, 0.0001));
  });

  test(
    'falls back to legacy calculation when new usage model is incomplete',
    () {
      final appliance = Appliance(
        id: 1,
        name: 'Télévision',
        category: 'Électronique',
        powerWatts: 150,
        quantity: 1,

        hoursPerDay: 8,
        daysPerMonth: 30,

        usageDurationMinutes: 60,
        usageCount: 2,
        usageFrequency: null,

        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(appliance.usesNewUsageModel, isFalse);
      expect(appliance.monthlyConsumptionKwh, closeTo(36.0, 0.0001));
    },
  );
}
