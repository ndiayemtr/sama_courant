import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/core/database/app_database.dart';
import 'package:sama_courant/features/appliances/data/repositories/drift_appliance_repository.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart'
    as domain;
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_label_type.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftApplianceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftApplianceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('CRUD Appliance', () async {
    final now = DateTime.now();

    final appliance = domain.Appliance(
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 10,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    // CREATE
    final id = await repository.create(appliance);

    expect(id, greaterThan(0));

    // READ
    final created = await repository.getById(id);

    expect(created, isNotNull);
    expect(created!.name, 'Réfrigérateur');
    expect(created.powerWatts, 150);
    expect(created.quantity, 1);

    // UPDATE
    // UPDATE
    final newUpdatedAt = created.createdAt.add(const Duration(minutes: 1));

    final updatedAppliance = domain.Appliance(
      id: id,
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 180,
      quantity: 1,
      hoursPerDay: 12,
      daysPerMonth: 30,
      isActive: true,
      createdAt: created.createdAt,
      updatedAt: newUpdatedAt,
    );

    final updated = await repository.update(updatedAppliance);

    expect(updated, isTrue);

    final updatedResult = await repository.getById(id);

    expect(updatedResult, isNotNull);
    expect(updatedResult!.powerWatts, 180);
    expect(updatedResult.hoursPerDay, 12);

    expect(updatedResult.createdAt, created.createdAt);
    expect(updatedResult.updatedAt, newUpdatedAt);

    // timestamps
    expect(updatedResult.createdAt, created.createdAt);
    expect(updatedResult.updatedAt, newUpdatedAt);
  });

  test('update returns false when appliance id is null', () async {
    final now = DateTime(2026, 1, 1);

    final appliance = domain.Appliance(
      name: 'Ventilateur',
      category: 'Confort',
      powerWatts: 60,
      quantity: 1,
      hoursPerDay: 8,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repository.update(appliance);

    expect(result, isFalse);
  });

  test('getById returns null for unknown id', () async {
    final result = await repository.getById(999);

    expect(result, isNull);
  });

  test('appliance persists after database restart', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'sama_courant_persistence_test_',
    );

    final dbFile = File('${tempDir.path}/sama_courant.sqlite');

    final createdAt = DateTime(2026, 9, 18, 10, 0);
    final updatedAt = DateTime(2026, 9, 18, 10, 0);

    var firstDatabase = AppDatabase.forFile(dbFile);
    var firstRepository = DriftApplianceRepository(firstDatabase);

    final id = await firstRepository.create(
      domain.Appliance(
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
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    await firstDatabase.close();

    final secondDatabase = AppDatabase.forFile(dbFile);
    final secondRepository = DriftApplianceRepository(secondDatabase);

    final persisted = await secondRepository.getById(id);

    expect(persisted, isNotNull);
    expect(persisted!.id, id);
    expect(persisted.name, 'Fer à repasser');
    expect(persisted.category, 'Électroménager');
    expect(persisted.powerWatts, 1600);
    expect(persisted.quantity, 1);
    expect(persisted.hoursPerDay, 0);
    expect(persisted.daysPerMonth, 30);
    expect(persisted.isActive, isTrue);
    expect(persisted.createdAt, createdAt);
    expect(persisted.updatedAt, updatedAt);
    expect(persisted.usageDurationMinutes, 30);
    expect(persisted.usageCount, 2);
    expect(persisted.usageFrequency, UsageFrequency.weekly);
    expect(persisted.usesNewUsageModel, isTrue);
    expect(persisted.monthlyConsumptionKwh, closeTo(6.928, 0.0001));

    await secondDatabase.close();
    await tempDir.delete(recursive: true);
  });

  test('legacy appliance keeps new usage fields null', () async {
    final now = DateTime(2026, 9, 26, 9, 0);

    final id = await repository.create(
      domain.Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 120,
        quantity: 1,
        hoursPerDay: 5,
        daysPerMonth: 30,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final persisted = await repository.getById(id);

    expect(persisted, isNotNull);
    expect(persisted!.usageDurationMinutes, isNull);
    expect(persisted.usageCount, isNull);
    expect(persisted.usageFrequency, isNull);
    expect(persisted.usesNewUsageModel, isFalse);

    // Vérifie que le fallback legacy reste fonctionnel.
    expect(persisted.monthlyConsumptionKwh, closeTo(18.0, 0.0001));
  });

  test('legacy appliance keeps new usage fields null', () async {
    final now = DateTime(2026, 9, 26, 9, 0);

    final id = await repository.create(
      domain.Appliance(
        name: 'Télévision',
        category: 'Salon',
        powerWatts: 120,
        quantity: 1,
        hoursPerDay: 5,
        daysPerMonth: 30,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final persisted = await repository.getById(id);

    expect(persisted, isNotNull);
    expect(persisted!.usageDurationMinutes, isNull);
    expect(persisted.usageCount, isNull);
    expect(persisted.usageFrequency, isNull);
    expect(persisted.usesNewUsageModel, isFalse);

    // Vérifie que le fallback legacy reste fonctionnel.
    expect(persisted.monthlyConsumptionKwh, closeTo(18.0, 0.0001));
  });

  test('new usage model persists and reloads correctly', () async {
    final now = DateTime(2026, 9, 26, 9, 0);

    final id = await repository.create(
      domain.Appliance(
        name: 'Fer à repasser',
        category: 'Électroménager',
        powerWatts: 1600,
        quantity: 1,

        // Legacy conservé temporairement pour compatibilité.
        hoursPerDay: 0,
        daysPerMonth: 30,

        usageDurationMinutes: 30,
        usageCount: 2,
        usageFrequency: UsageFrequency.weekly,

        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final persisted = await repository.getById(id);

    expect(persisted, isNotNull);

    expect(persisted!.usageDurationMinutes, 30);
    expect(persisted.usageCount, 2);
    expect(persisted.usageFrequency, UsageFrequency.weekly);
    expect(persisted.usesNewUsageModel, isTrue);

    expect(persisted.monthlyConsumptionKwh, closeTo(6.928, 0.0001));
  });

  test('persists label type and power source', () async {
    final now = DateTime(2026, 9, 28);

    final appliance = domain.Appliance(
      name: 'Refrigerateur',
      category: 'refrigerator',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 1440,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
      labelType: ApplianceLabelType.energyLabel,
      powerSource: PowerSource.detected,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final id = await repository.create(appliance);

    final stored = await repository.getById(id);

    expect(stored, isNotNull);
    expect(stored!.labelType, ApplianceLabelType.energyLabel);
    expect(stored.powerSource, PowerSource.detected);
  });

  test('persists energy consumption metrics', () async {
    final now = DateTime(2026, 9, 28);

    final appliance = domain.Appliance(
      name: 'Réfrigérateur énergie',
      category: 'refrigerator',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 1440,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
      labelType: ApplianceLabelType.energyLabel,
      powerSource: PowerSource.detected,
      energyConsumptionMetrics: const [
        EnergyConsumptionMetric(
          valueKwh: 216,
          basis: EnergyConsumptionBasis.perYear,
        ),
        EnergyConsumptionMetric(
          valueKwh: 25,
          basis: EnergyConsumptionBasis.per100Cycles,
        ),
      ],
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final id = await repository.create(appliance);

    final stored = await repository.getById(id);

    expect(stored, isNotNull);
    expect(stored!.energyConsumptionMetrics, hasLength(2));

    expect(stored.energyConsumptionMetrics[0].valueKwh, 216);
    expect(
      stored.energyConsumptionMetrics[0].basis,
      EnergyConsumptionBasis.perYear,
    );

    expect(stored.energyConsumptionMetrics[1].valueKwh, 25);
    expect(
      stored.energyConsumptionMetrics[1].basis,
      EnergyConsumptionBasis.per100Cycles,
    );
  });

  test('scan metadata persists after database restart', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'sama_courant_scan_metadata_restart_',
    );

    final databaseFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}sama_courant.sqlite',
    );

    AppDatabase? firstDatabase;
    AppDatabase? reopenedDatabase;

    try {
      // ----------------------------------------------------------
      // 1. Première ouverture de la base
      // ----------------------------------------------------------
      firstDatabase = AppDatabase.forFile(databaseFile);

      final firstRepository = DriftApplianceRepository(firstDatabase);

      final now = DateTime(2026, 9, 28, 15);

      final appliance = domain.Appliance(
        name: 'Réfrigérateur énergie',
        category: 'refrigerator',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 0,
        daysPerMonth: 30,
        usageDurationMinutes: 1440,
        usageCount: 1,
        usageFrequency: UsageFrequency.daily,
        labelType: ApplianceLabelType.energyLabel,
        powerSource: PowerSource.detected,
        energyConsumptionMetrics: const [
          EnergyConsumptionMetric(
            valueKwh: 216,
            basis: EnergyConsumptionBasis.perYear,
          ),
          EnergyConsumptionMetric(
            valueKwh: 25,
            basis: EnergyConsumptionBasis.per100Cycles,
          ),
        ],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final id = await firstRepository.create(appliance);

      expect(id, greaterThan(0));

      // ----------------------------------------------------------
      // 2. Fermeture complète de la première base
      // ----------------------------------------------------------
      await firstDatabase.close();
      firstDatabase = null;

      // ----------------------------------------------------------
      // 3. Réouverture du même fichier SQLite
      // ----------------------------------------------------------
      reopenedDatabase = AppDatabase.forFile(databaseFile);

      final reopenedRepository = DriftApplianceRepository(reopenedDatabase);

      final restored = await reopenedRepository.getById(id);

      // ----------------------------------------------------------
      // 4. Vérification de l'appareil rechargé
      // ----------------------------------------------------------
      expect(restored, isNotNull);

      expect(restored!.labelType, ApplianceLabelType.energyLabel);

      expect(restored.powerSource, PowerSource.detected);

      expect(restored.energyConsumptionMetrics, hasLength(2));

      expect(restored.energyConsumptionMetrics[0].valueKwh, 216);

      expect(
        restored.energyConsumptionMetrics[0].basis,
        EnergyConsumptionBasis.perYear,
      );

      expect(restored.energyConsumptionMetrics[1].valueKwh, 25);

      expect(
        restored.energyConsumptionMetrics[1].basis,
        EnergyConsumptionBasis.per100Cycles,
      );
    } finally {
      if (firstDatabase != null) {
        await firstDatabase.close();
      }

      if (reopenedDatabase != null) {
        await reopenedDatabase.close();
      }

      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  });
}
