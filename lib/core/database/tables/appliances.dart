import 'package:drift/drift.dart';

class Appliances extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get category => text().withLength(min: 1, max: 50)();

  RealColumn get powerWatts => real()();

  IntColumn get quantity => integer().withDefault(const Constant(1))();

  RealColumn get hoursPerDay => real()();

  IntColumn get daysPerMonth => integer().withDefault(const Constant(30))();

  IntColumn get usageDurationMinutes => integer().nullable()();

  IntColumn get usageCount => integer().nullable()();

  TextColumn get usageFrequency => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get labelType => text().nullable()();

  TextColumn get powerSource => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
