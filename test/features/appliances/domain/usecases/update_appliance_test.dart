import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/update_appliance.dart';

import '../../fakes/fake_appliance_repository.dart';

void main() {
  late FakeApplianceRepository repository;
  late UpdateAppliance useCase;

  setUp(() {
    repository = FakeApplianceRepository();
    useCase = UpdateAppliance(repository);
  });

  test('updates an existing appliance', () async {
    final now = DateTime.now();

    final id = await repository.create(
      Appliance(
        name: 'Réfrigérateur',
        category: 'Cuisine',
        powerWatts: 150,
        quantity: 1,
        hoursPerDay: 10,
        daysPerMonth: 30,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final updatedAppliance = Appliance(
      id: id,
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 180,
      quantity: 1,
      hoursPerDay: 12,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: DateTime.now(),
    );

    final result = await useCase(updatedAppliance);

    expect(result, isTrue);

    final updated = await repository.getById(id);

    expect(updated, isNotNull);
    expect(updated!.powerWatts, 180);
    expect(updated.hoursPerDay, 12);
  });

  test('returns false when appliance does not exist', () async {
    final now = DateTime.now();

    final appliance = Appliance(
      id: 999,
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 180,
      quantity: 1,
      hoursPerDay: 12,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final result = await useCase(appliance);

    expect(result, isFalse);
  });
}
