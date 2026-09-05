import 'package:drift/drift.dart';

class TariffTiers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tariffConfigurationId => integer()();

  RealColumn get minKwh => real()();

  RealColumn get maxKwh => real().nullable()();

  RealColumn get pricePerKwh => real()();

  IntColumn get tierOrder => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
