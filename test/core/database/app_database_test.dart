import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/core/database/app_database.dart';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

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
      expect(db.schemaVersion, 6);
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

  test(
    'version 3 to 4 migration adds label metadata without changing existing appliances',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'sama_courant_v3_to_v4_',
      );

      final databaseFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}sama_courant.sqlite',
      );

      final sqlite = sqlite3.open(databaseFile.path);

      try {
        sqlite.execute('''
        CREATE TABLE appliances (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          power_watts REAL NOT NULL,
          quantity INTEGER NOT NULL,
          hours_per_day REAL NOT NULL,
          days_per_month INTEGER NOT NULL DEFAULT 30,
          usage_duration_minutes INTEGER NULL,
          usage_count INTEGER NULL,
          usage_frequency TEXT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

        sqlite.execute('''
        INSERT INTO appliances (
          name,
          category,
          power_watts,
          quantity,
          hours_per_day,
          days_per_month,
          usage_duration_minutes,
          usage_count,
          usage_frequency,
          is_active,
          created_at,
          updated_at
        )
        VALUES (
          'Ventilateur test',
          'fan',
          75.0,
          1,
          8.0,
          30,
          120,
          2,
          'daily',
          1,
          1759050000000,
          1759050000000
        );
      ''');

        sqlite.execute('PRAGMA user_version = 3;');

        final beforeVersion = sqlite
            .select('PRAGMA user_version')
            .single['user_version'];

        expect(beforeVersion, 3);

        final beforeColumns = sqlite
            .select('PRAGMA table_info(appliances)')
            .map((row) => row['name'] as String)
            .toList();

        expect(beforeColumns, contains('usage_duration_minutes'));
        expect(beforeColumns, contains('usage_count'));
        expect(beforeColumns, contains('usage_frequency'));

        expect(beforeColumns, isNot(contains('label_type')));
        expect(beforeColumns, isNot(contains('power_source')));
      } finally {
        sqlite.close();
      }

      final database = AppDatabase.forFile(databaseFile);

      try {
        // Force l'ouverture de Drift et donc la migration.
        await database.customStatement('SELECT 1');

        final versionRow = await database
            .customSelect('PRAGMA user_version')
            .getSingle();

        expect(versionRow.read<int>('user_version'), 6);

        final columns = await database
            .customSelect('PRAGMA table_info(appliances)')
            .get();

        final columnNames = columns
            .map((row) => row.read<String>('name'))
            .toList();

        expect(columnNames, contains('label_type'));
        expect(columnNames, contains('power_source'));

        final rows = await database.customSelect('''
        SELECT
          id,
          name,
          category,
          power_watts,
          quantity,
          hours_per_day,
          days_per_month,
          usage_duration_minutes,
          usage_count,
          usage_frequency,
          label_type,
          power_source,
          is_active
        FROM appliances
      ''').get();

        expect(rows, hasLength(1));

        final row = rows.single;

        expect(row.read<int>('id'), 1);
        expect(row.read<String>('name'), 'Ventilateur test');
        expect(row.read<String>('category'), 'fan');
        expect(row.read<double>('power_watts'), 75.0);
        expect(row.read<int>('quantity'), 1);
        expect(row.read<double>('hours_per_day'), 8.0);
        expect(row.read<int>('days_per_month'), 30);
        expect(row.read<int?>('usage_duration_minutes'), 120);
        expect(row.read<int?>('usage_count'), 2);
        expect(row.read<String?>('usage_frequency'), 'daily');
        expect(row.read<String?>('label_type'), isNull);
        expect(row.read<String?>('power_source'), isNull);
        expect(row.read<bool>('is_active'), isTrue);
      } finally {
        await database.close();

        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      }
    },
  );

  test(
    'version 4 to 5 migration adds energy consumption metrics without changing existing appliances',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'sama_courant_v4_to_v5_',
      );

      final databaseFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}sama_courant.sqlite',
      );

      // ------------------------------------------------------------
      // 1. Création manuelle d'une base correspondant à la version 4
      // ------------------------------------------------------------
      final sqlite = sqlite3.open(databaseFile.path);

      try {
        sqlite.execute('''
        CREATE TABLE appliances (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          power_watts REAL NOT NULL,
          quantity INTEGER NOT NULL,
          hours_per_day REAL NOT NULL,
          days_per_month INTEGER NOT NULL DEFAULT 30,
          usage_duration_minutes INTEGER NULL,
          usage_count INTEGER NULL,
          usage_frequency TEXT NULL,
          label_type TEXT NULL,
          power_source TEXT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

        sqlite.execute('''
        INSERT INTO appliances (
          name,
          category,
          power_watts,
          quantity,
          hours_per_day,
          days_per_month,
          usage_duration_minutes,
          usage_count,
          usage_frequency,
          label_type,
          power_source,
          is_active,
          created_at,
          updated_at
        )
        VALUES (
          'Réfrigérateur test',
          'refrigerator',
          150.0,
          1,
          0.0,
          30,
          1440,
          1,
          'daily',
          'energyLabel',
          'detected',
          1,
          1759050000000,
          1759050000000
        );
      ''');

        sqlite.execute('PRAGMA user_version = 4;');

        final versionBeforeMigration = sqlite
            .select('PRAGMA user_version')
            .single['user_version'];

        expect(versionBeforeMigration, 4);

        final columnsBeforeMigration = sqlite
            .select('PRAGMA table_info(appliances)')
            .map((row) => row['name'] as String)
            .toList();

        // Les colonnes v4 existent déjà.
        expect(columnsBeforeMigration, contains('label_type'));
        expect(columnsBeforeMigration, contains('power_source'));

        // La colonne v5 ne doit pas encore exister.
        expect(
          columnsBeforeMigration,
          isNot(contains('energy_consumption_metrics_json')),
        );
      } finally {
        sqlite.close();
      }

      // ------------------------------------------------------------
      // 2. Ouverture avec AppDatabase version 5
      //    => migration automatique v4 -> v5
      // ------------------------------------------------------------
      final database = AppDatabase.forFile(databaseFile);

      try {
        // Force réellement l'ouverture et l'exécution de la migration.
        await database.customStatement('SELECT 1');

        // ----------------------------------------------------------
        // 3. Vérification de la version
        // ----------------------------------------------------------
        final versionRow = await database
            .customSelect('PRAGMA user_version')
            .getSingle();

        expect(versionRow.read<int>('user_version'), 6);
        expect(database.schemaVersion, 6);

        // ----------------------------------------------------------
        // 4. Vérification de la nouvelle colonne
        // ----------------------------------------------------------
        final columns = await database
            .customSelect('PRAGMA table_info(appliances)')
            .get();

        final columnNames = columns
            .map((row) => row.read<String>('name'))
            .toList();

        expect(columnNames, contains('energy_consumption_metrics_json'));

        // ----------------------------------------------------------
        // 5. Vérification que l'ancien appareil est toujours intact
        // ----------------------------------------------------------
        final rows = await database.customSelect('''
        SELECT
          id,
          name,
          category,
          power_watts,
          quantity,
          hours_per_day,
          days_per_month,
          usage_duration_minutes,
          usage_count,
          usage_frequency,
          label_type,
          power_source,
          energy_consumption_metrics_json,
          is_active
        FROM appliances
      ''').get();

        expect(rows, hasLength(1));

        final row = rows.single;

        expect(row.read<int>('id'), 1);
        expect(row.read<String>('name'), 'Réfrigérateur test');
        expect(row.read<String>('category'), 'refrigerator');
        expect(row.read<double>('power_watts'), 150.0);
        expect(row.read<int>('quantity'), 1);

        expect(row.read<int?>('usage_duration_minutes'), 1440);
        expect(row.read<int?>('usage_count'), 1);
        expect(row.read<String?>('usage_frequency'), 'daily');

        expect(row.read<String?>('label_type'), 'energyLabel');
        expect(row.read<String?>('power_source'), 'detected');

        // Ancien appareil v4 :
        // aucune métrique énergie n'existait encore.
        expect(row.read<String?>('energy_consumption_metrics_json'), isNull);

        expect(row.read<bool>('is_active'), isTrue);
      } finally {
        await database.close();

        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      }
    },
  );
}
