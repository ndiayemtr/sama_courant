import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/appliances.dart';
import 'tables/consumption_snapshots.dart';
import 'tables/tariff_configurations.dart';
import 'tables/tariff_tiers.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Appliances, TariffConfigurations, TariffTiers, ConsumptionSnapshots],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  AppDatabase.forFile(File file)
    : super(NativeDatabase.createInBackground(file));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2 && to >= 2) {
        await migrator.createTable(consumptionSnapshots);
      }

      if (from < 3 && to >= 3) {
        await migrator.addColumn(appliances, appliances.usageDurationMinutes);

        await migrator.addColumn(appliances, appliances.usageCount);

        await migrator.addColumn(appliances, appliances.usageFrequency);
      }

      if (from < 4 && to >= 4) {
        await migrator.addColumn(appliances, appliances.labelType);
        await migrator.addColumn(appliances, appliances.powerSource);
      }

      if (from < 5 && to >= 5) {
        await migrator.addColumn(
          appliances,
          appliances.energyConsumptionMetricsJson,
        );
      }

      if (from < 6 && to >= 6) {
        await migrator.addColumn(appliances, appliances.applianceType);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(p.join(directory.path, 'sama_courant.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
