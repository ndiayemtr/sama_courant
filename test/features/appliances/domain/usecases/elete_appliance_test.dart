import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/delete_appliance.dart';

import '../../fakes/fake_appliance_repository.dart';

void main() {
  late FakeApplianceRepository repository;
  late DeleteAppliance useCase;

  setUp(() {
    repository = FakeApplianceRepository();
    useCase = DeleteAppliance(repository);
  });

  test('deletes an existing appliance', () async {
    final now = DateTime.now();

    final id = await repository.create(
      Appliance(
        name: 'Télévision',
        category: 'Multimédia',
        powerWatts: 100,
        quantity: 1,
        hoursPerDay: 5,
        daysPerMonth: 30,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(await repository.getById(id), isNotNull);

    await useCase(id);

    expect(await repository.getById(id), isNull);
  });
}
