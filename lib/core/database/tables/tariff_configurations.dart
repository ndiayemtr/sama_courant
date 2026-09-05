import 'package:drift/drift.dart';

class TariffConfigurations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  DateTimeColumn get effectiveFrom => dateTime()();

  DateTimeColumn get effectiveTo => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
