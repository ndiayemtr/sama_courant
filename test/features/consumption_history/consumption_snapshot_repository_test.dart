import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sama_courant/core/database/app_database.dart';
import 'package:sama_courant/core/database/database_provider.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart'
    as domain;
import 'package:sama_courant/features/consumption_history/data/repositories/drift_consumption_snapshot_repository.dart';
import 'package:sama_courant/features/consumption_history/data/providers/consumption_snapshot_repository_provider.dart';
import 'package:sama_courant/features/appliances/data/repositories/drift_appliance_repository.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart'
    as appliance_domain;

void main() {
  late AppDatabase database;
  late DriftConsumptionSnapshotRepository repository;
  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftConsumptionSnapshotRepository(database);
  });
  tearDown(() async => database.close());

  domain.ConsumptionSnapshot snapshot(int day, {int? id}) =>
      domain.ConsumptionSnapshot(
        id: id,
        capturedAt: DateTime(2026, 9, day, 10, 30, 15),
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551.75,
        activeAppliancesCount: 3,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: DateTime(2026, 10, 1, 11, 5, 20),
      );

  test('empty repository returns an empty list and null lookups', () async {
    expect(await repository.getAll(), isEmpty);
    expect(await repository.getLatest(), isNull);
    expect(await repository.getById(99), isNull);
  });

  test('creation generates an id and maps all values and dates', () async {
    final original = snapshot(11);
    final id = await repository.create(original);
    expect(id, greaterThan(0));
    expect(original.id, isNull);
    final row = (await repository.getById(id))!;
    expect(row.id, id);
    expect(row.capturedAt, original.capturedAt);
    expect(row.createdAt, original.createdAt);
    expect(row.totalMonthlyConsumptionKwh, 55.5);
    expect(row.totalMonthlyCostFcfa, 4551.75);
    expect(row.activeAppliancesCount, 3);
    expect(row.tariffConfigurationName, 'Woyofal DPP 2026');
    expect(await repository.getById(id + 1), isNull);
  });

  test('creation preserves an explicit id', () async {
    expect(await repository.create(snapshot(11, id: 42)), 42);
    expect((await repository.getById(42))?.id, 42);
  });

  test(
    'reads by capture time descending regardless of insertion order',
    () async {
      final newest = await repository.create(snapshot(13));
      final oldest = await repository.create(snapshot(10));
      final middle = await repository.create(snapshot(11));
      expect((await repository.getAll()).map((row) => row.id), [
        newest,
        middle,
        oldest,
      ]);
      expect((await repository.getLatest())?.id, newest);
    },
  );

  test('equal capture times use descending id consistently', () async {
    final first = await repository.create(snapshot(11));
    final second = await repository.create(snapshot(11));
    expect((await repository.getAll()).map((row) => row.id), [second, first]);
    expect((await repository.getLatest())?.id, second);
  });

  test('repository provider uses the supplied database', () async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final provided = container.read(consumptionSnapshotRepositoryProvider);
    final id = await provided.create(snapshot(11));
    expect((await repository.getById(id))?.id, id);
  });

  test('snapshot persists after database restart', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    final tempDir = await Directory.systemTemp.createTemp(
      'sama_courant_snapshot_persistence_',
    );

    AppDatabase? firstDatabase;
    AppDatabase? secondDatabase;

    try {
      final dbFile = File('${tempDir.path}/sama_courant.sqlite');

      final original = domain.ConsumptionSnapshot(
        capturedAt: DateTime(2026, 9, 18, 14, 30),
        totalMonthlyConsumptionKwh: 125.75,
        totalMonthlyCostFcfa: 9876.50,
        activeAppliancesCount: 4,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: DateTime(2026, 9, 18, 14, 31),
      );

      // Première ouverture : création
      firstDatabase = AppDatabase.forFile(dbFile);

      final firstRepository = DriftConsumptionSnapshotRepository(firstDatabase);

      final id = await firstRepository.create(original);

      expect(id, greaterThan(0));

      await firstDatabase.close();
      firstDatabase = null;

      // Simulation d'un redémarrage de l'application
      secondDatabase = AppDatabase.forFile(dbFile);

      final secondRepository = DriftConsumptionSnapshotRepository(
        secondDatabase,
      );

      final persisted = await secondRepository.getById(id);

      expect(persisted, isNotNull);

      expect(persisted!.id, id);
      expect(persisted.capturedAt, original.capturedAt);
      expect(
        persisted.totalMonthlyConsumptionKwh,
        original.totalMonthlyConsumptionKwh,
      );
      expect(persisted.totalMonthlyCostFcfa, original.totalMonthlyCostFcfa);
      expect(persisted.activeAppliancesCount, original.activeAppliancesCount);
      expect(
        persisted.tariffConfigurationName,
        original.tariffConfigurationName,
      );
      expect(persisted.createdAt, original.createdAt);

      final all = await secondRepository.getAll();

      expect(all, hasLength(1));
      expect(all.single.id, id);

      final latest = await secondRepository.getLatest();

      expect(latest, isNotNull);
      expect(latest!.id, id);
    } finally {
      if (firstDatabase != null) {
        await firstDatabase.close();
      }

      if (secondDatabase != null) {
        await secondDatabase.close();
      }

      driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test(
    'deleting all appliances does not delete existing consumption history',
    () async {
      final applianceRepository = DriftApplianceRepository(database);

      final createdAt = DateTime(2026, 9, 18, 10);

      final firstApplianceId = await applianceRepository.create(
        appliance_domain.Appliance(
          name: 'Réfrigérateur',
          category: 'Cuisine',
          powerWatts: 150,
          quantity: 1,
          hoursPerDay: 10,
          daysPerMonth: 30,
          isActive: true,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final secondApplianceId = await applianceRepository.create(
        appliance_domain.Appliance(
          name: 'Ventilateur',
          category: 'Confort',
          powerWatts: 60,
          quantity: 1,
          hoursPerDay: 8,
          daysPerMonth: 30,
          isActive: true,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      expect(await applianceRepository.getAll(), hasLength(2));

      final snapshotId = await repository.create(
        domain.ConsumptionSnapshot(
          capturedAt: DateTime(2026, 9, 18, 12),
          totalMonthlyConsumptionKwh: 189.0,
          totalMonthlyCostFcfa: 17600.0,
          activeAppliancesCount: 2,
          tariffConfigurationName: 'Woyofal DPP 2026',
          createdAt: DateTime(2026, 9, 18, 12),
        ),
      );

      await applianceRepository.delete(firstApplianceId);
      await applianceRepository.delete(secondApplianceId);

      final remainingAppliances = await applianceRepository.getAll();

      expect(remainingAppliances, isEmpty);

      final persistedSnapshot = await repository.getById(snapshotId);

      expect(persistedSnapshot, isNotNull);
      expect(persistedSnapshot!.activeAppliancesCount, 2);
      expect(persistedSnapshot.tariffConfigurationName, 'Woyofal DPP 2026');
      expect(persistedSnapshot.totalMonthlyConsumptionKwh, 189.0);
      expect(persistedSnapshot.totalMonthlyCostFcfa, 17600.0);

      final latest = await repository.getLatest();

      expect(latest, isNotNull);
      expect(latest!.id, snapshotId);
    },
  );
}
