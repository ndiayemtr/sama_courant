import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/appliance.dart' as domain;
import '../../domain/repositories/appliance_repository.dart';

class DriftApplianceRepository implements ApplianceRepository {
  final AppDatabase database;

  DriftApplianceRepository(this.database);

  @override
  Future<List<domain.Appliance>> getAll() async {
    final rows = await database.select(database.appliances).get();

    return rows.map(_toEntity).toList();
  }

  @override
  Future<domain.Appliance?> getById(int id) async {
    final row = await (database.select(
      database.appliances,
    )..where((table) => table.id.equals(id))).getSingleOrNull();

    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> create(domain.Appliance appliance) {
    return database.into(database.appliances).insert(_toCompanion(appliance));
  }

  @override
  Future<bool> update(domain.Appliance appliance) async {
    if (appliance.id == null) {
      return false;
    }

    return database
        .update(database.appliances)
        .replace(_toCompanion(appliance));
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(
      database.appliances,
    )..where((table) => table.id.equals(id))).go();
  }

  domain.Appliance _toEntity(Appliance row) {
    return domain.Appliance(
      id: row.id,
      name: row.name,
      category: row.category,
      powerWatts: row.powerWatts,
      quantity: row.quantity,
      hoursPerDay: row.hoursPerDay,
      daysPerMonth: row.daysPerMonth,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AppliancesCompanion _toCompanion(domain.Appliance appliance) {
    return AppliancesCompanion(
      id: appliance.id == null ? const Value.absent() : Value(appliance.id!),
      name: Value(appliance.name),
      category: Value(appliance.category),
      powerWatts: Value(appliance.powerWatts),
      quantity: Value(appliance.quantity),
      hoursPerDay: Value(appliance.hoursPerDay),
      daysPerMonth: Value(appliance.daysPerMonth),
      isActive: Value(appliance.isActive),
      createdAt: Value(appliance.createdAt),
      updatedAt: Value(appliance.updatedAt),
    );
  }
}
