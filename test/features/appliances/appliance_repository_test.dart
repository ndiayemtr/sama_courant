import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/core/database/app_database.dart';
import 'package:sama_courant/features/appliances/data/repositories/drift_appliance_repository.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart'
    as domain;

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftApplianceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftApplianceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('CRUD Appliance', () async {
    final now = DateTime.now();

    final appliance = domain.Appliance(
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 10,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    // CREATE
    final id = await repository.create(appliance);

    expect(id, greaterThan(0));

    // READ
    final created = await repository.getById(id);

    expect(created, isNotNull);
    expect(created!.name, 'Réfrigérateur');
    expect(created.powerWatts, 150);
    expect(created.quantity, 1);

    // UPDATE
    // UPDATE
    final newUpdatedAt = created.createdAt.add(const Duration(minutes: 1));

    final updatedAppliance = domain.Appliance(
      id: id,
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 180,
      quantity: 1,
      hoursPerDay: 12,
      daysPerMonth: 30,
      isActive: true,
      createdAt: created.createdAt,
      updatedAt: newUpdatedAt,
    );

    final updated = await repository.update(updatedAppliance);

    expect(updated, isTrue);

    final updatedResult = await repository.getById(id);

    expect(updatedResult, isNotNull);
    expect(updatedResult!.powerWatts, 180);
    expect(updatedResult.hoursPerDay, 12);

    expect(updatedResult.createdAt, created.createdAt);
    expect(updatedResult.updatedAt, newUpdatedAt);

    // timestamps
    expect(updatedResult.createdAt, created.createdAt);
    expect(updatedResult.updatedAt, newUpdatedAt);
  });

  test('update returns false when appliance id is null', () async {
    final now = DateTime(2026, 1, 1);

    final appliance = domain.Appliance(
      name: 'Ventilateur',
      category: 'Confort',
      powerWatts: 60,
      quantity: 1,
      hoursPerDay: 8,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repository.update(appliance);

    expect(result, isFalse);
  });

  test('getById returns null for unknown id', () async {
    final result = await repository.getById(999);

    expect(result, isNull);
  });
}
