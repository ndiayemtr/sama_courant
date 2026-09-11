import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/core/database/app_database.dart';

// Recreates the version 1 schema in the existing in-memory test connection.
class _VersionOneDatabase extends AppDatabase {
  _VersionOneDatabase() : super.forTesting();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createTable(appliances);
      await migrator.createTable(tariffConfigurations);
      await migrator.createTable(tariffTiers);
    },
    onUpgrade: super.migration.onUpgrade,
  );
}

void main() {
  test(
    'snapshot insertion generates an id and preserves all stored values',
    () async {
      final db = AppDatabase.forTesting();
      addTearDown(db.close);
      final captured = DateTime(2026, 9, 11, 10, 30, 15);
      final created = DateTime(2026, 9, 11, 10, 31, 20);
      final companion = ConsumptionSnapshotsCompanion.insert(
        capturedAt: captured,
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551.75,
        activeAppliancesCount: 3,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: created,
      );
      final id = await db.into(db.consumptionSnapshots).insert(companion);
      final row = await db.select(db.consumptionSnapshots).getSingle();
      expect(id, greaterThan(0));
      expect(row.id, id);
      expect(row.capturedAt, captured);
      expect(row.createdAt, created);
      expect(row.totalMonthlyConsumptionKwh, 55.5);
      expect(row.totalMonthlyCostFcfa, 4551.75);
      expect(row.activeAppliancesCount, 3);
      expect(row.tariffConfigurationName, 'Woyofal DPP 2026');
      final nextId = await db.into(db.consumptionSnapshots).insert(companion);
      expect(nextId, greaterThan(id));
      expect(db.schemaVersion, 2);
    },
  );

  test('snapshot rejects an empty tariff configuration name', () async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);
    final date = DateTime(2026, 9, 11);
    await expectLater(
      db
          .into(db.consumptionSnapshots)
          .insert(
            ConsumptionSnapshotsCompanion.insert(
              capturedAt: date,
              totalMonthlyConsumptionKwh: 0,
              totalMonthlyCostFcfa: 0,
              activeAppliancesCount: 0,
              tariffConfigurationName: '',
              createdAt: date,
            ),
          ),
      throwsA(isA<InvalidDataException>()),
    );
  });

  test(
    'version 1 to 2 migration adds snapshots without changing existing rows',
    () async {
      final db = _VersionOneDatabase();
      addTearDown(db.close);
      await db.customStatement(
        "INSERT INTO appliances (name, category, power_watts, quantity, hours_per_day, days_per_month, is_active, created_at, updated_at) VALUES ('Lampe', 'Maison', 50, 1, 2, 30, 1, 1000, 1000)",
      );
      await db.customStatement(
        "INSERT INTO tariff_configurations (name, effective_from, is_active, created_at, updated_at) VALUES ('Tarif existant', 1000, 1, 1000, 1000)",
      );
      await db.customStatement(
        'INSERT INTO tariff_tiers (tariff_configuration_id, min_kwh, price_per_kwh, tier_order, created_at, updated_at) VALUES (1, 0, 82, 1, 1000, 1000)',
      );
      final tables = ['appliances', 'tariff_configurations', 'tariff_tiers'];
      final before = [
        for (final table in tables)
          (await db.customSelect('SELECT * FROM $table').getSingle()).data,
      ];
      expect(
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE name = 'consumption_snapshots'",
            )
            .get(),
        isEmpty,
      );
      await db.migration.onUpgrade(Migrator(db), 1, 2);
      for (var i = 0; i < tables.length; i++) {
        expect(
          (await db.customSelect('SELECT * FROM ${tables[i]}').getSingle())
              .data,
          before[i],
        );
      }
      expect(await db.select(db.consumptionSnapshots).get(), isEmpty);
      await db
          .into(db.consumptionSnapshots)
          .insert(
            ConsumptionSnapshotsCompanion.insert(
              capturedAt: DateTime(2026),
              totalMonthlyConsumptionKwh: 0,
              totalMonthlyCostFcfa: 0,
              activeAppliancesCount: 0,
              tariffConfigurationName: 'Tarif existant',
              createdAt: DateTime(2026),
            ),
          );
      expect(await db.select(db.consumptionSnapshots).get(), hasLength(1));
    },
  );
}
