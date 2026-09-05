import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/create_appliance.dart';

import '../../fakes/fake_appliance_repository.dart';

void main() {
  late FakeApplianceRepository repository;
  late CreateAppliance useCase;

  setUp(() {
    repository = FakeApplianceRepository();
    useCase = CreateAppliance(repository);
  });

  test('creates an appliance and returns its id', () async {
    final now = DateTime.now();

    final appliance = Appliance(
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

    final id = await useCase(appliance);

    expect(id, 1);

    final created = await repository.getById(id);

    expect(created, isNotNull);
    expect(created!.name, 'Réfrigérateur');
    expect(created.powerWatts, 150);
  });
}
