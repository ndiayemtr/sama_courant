import 'package:drift/drift.dart';

class ConsumptionSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get capturedAt => dateTime()();

  RealColumn get totalMonthlyConsumptionKwh => real()();

  RealColumn get totalMonthlyCostFcfa => real()();

  IntColumn get activeAppliancesCount => integer()();

  TextColumn get tariffConfigurationName => text().withLength(min: 1)();

  DateTimeColumn get createdAt => dateTime()();
}
