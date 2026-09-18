import 'dart:io';
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

  test('appliance persists after database restart', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'sama_courant_persistence_test_',
    );

    final dbFile = File('${tempDir.path}/sama_courant.sqlite');

    final createdAt = DateTime(2026, 9, 18, 10, 0);
    final updatedAt = DateTime(2026, 9, 18, 10, 0);

    var firstDatabase = AppDatabase.forFile(dbFile);
    var firstRepository = DriftApplianceRepository(firstDatabase);

    final id = await firstRepository.create(
      domain.Appliance(
        name: 'Réfrigérateur',
        category: 'Cuisine',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 10,
        daysPerMonth: 30,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    await firstDatabase.close();

    final secondDatabase = AppDatabase.forFile(dbFile);
    final secondRepository = DriftApplianceRepository(secondDatabase);

    final persisted = await secondRepository.getById(id);

    expect(persisted, isNotNull);
    expect(persisted!.id, id);
    expect(persisted.name, 'Réfrigérateur');
    expect(persisted.category, 'Cuisine');
    expect(persisted.powerWatts, 150);
    expect(persisted.quantity, 1);
    expect(persisted.hoursPerDay, 10);
    expect(persisted.daysPerMonth, 30);
    expect(persisted.isActive, isTrue);
    expect(persisted.createdAt, createdAt);
    expect(persisted.updatedAt, updatedAt);

    await secondDatabase.close();
    await tempDir.delete(recursive: true);
  });
}
