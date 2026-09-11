import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/consumption_snapshot.dart' as domain;
import '../../domain/repositories/consumption_snapshot_repository.dart';

class DriftConsumptionSnapshotRepository
    implements ConsumptionSnapshotRepository {
  final AppDatabase database;

  DriftConsumptionSnapshotRepository(this.database);

  @override
  Future<List<domain.ConsumptionSnapshot>> getAll() async {
    final rows =
        await (database.select(database.consumptionSnapshots)..orderBy([
              (table) => OrderingTerm.desc(table.capturedAt),
              (table) => OrderingTerm.desc(table.id),
            ]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<domain.ConsumptionSnapshot?> getById(int id) async {
    final row = await (database.select(
      database.consumptionSnapshots,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<domain.ConsumptionSnapshot?> getLatest() async {
    final row =
        await (database.select(database.consumptionSnapshots)
              ..orderBy([
                (table) => OrderingTerm.desc(table.capturedAt),
                (table) => OrderingTerm.desc(table.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create(domain.ConsumptionSnapshot snapshot) {
    return database
        .into(database.consumptionSnapshots)
        .insert(_toCompanion(snapshot));
  }

  domain.ConsumptionSnapshot _toEntity(ConsumptionSnapshot row) {
    return domain.ConsumptionSnapshot(
      id: row.id,
      capturedAt: row.capturedAt,
      totalMonthlyConsumptionKwh: row.totalMonthlyConsumptionKwh,
      totalMonthlyCostFcfa: row.totalMonthlyCostFcfa,
      activeAppliancesCount: row.activeAppliancesCount,
      tariffConfigurationName: row.tariffConfigurationName,
      createdAt: row.createdAt,
    );
  }

  ConsumptionSnapshotsCompanion _toCompanion(
    domain.ConsumptionSnapshot snapshot,
  ) {
    return ConsumptionSnapshotsCompanion(
      id: snapshot.id == null ? const Value.absent() : Value(snapshot.id!),
      capturedAt: Value(snapshot.capturedAt),
      totalMonthlyConsumptionKwh: Value(snapshot.totalMonthlyConsumptionKwh),
      totalMonthlyCostFcfa: Value(snapshot.totalMonthlyCostFcfa),
      activeAppliancesCount: Value(snapshot.activeAppliancesCount),
      tariffConfigurationName: Value(snapshot.tariffConfigurationName),
      createdAt: Value(snapshot.createdAt),
    );
  }
}
