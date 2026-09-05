import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';

import '../../fakes/fake_appliance_repository.dart';

void main() {
  late FakeApplianceRepository repository;
  late GetAppliances useCase;

  setUp(() {
    repository = FakeApplianceRepository();
    useCase = GetAppliances(repository);
  });

  test('returns all appliances', () async {
    final now = DateTime.now();

    await repository.create(
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

    await repository.create(
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

    final appliances = await useCase();

    expect(appliances, hasLength(2));
    expect(appliances[0].name, 'Réfrigérateur');
    expect(appliances[1].name, 'Télévision');
  });
}
