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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(consumptionSnapshots);
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
