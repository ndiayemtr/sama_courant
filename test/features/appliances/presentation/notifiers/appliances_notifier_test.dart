import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/usecases/create_appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/delete_appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'package:sama_courant/features/appliances/domain/usecases/update_appliance.dart';
import 'package:sama_courant/features/appliances/presentation/providers/appliances_provider.dart';

import '../../fakes/fake_appliance_repository.dart';

void main() {
  late FakeApplianceRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeApplianceRepository();

    container = ProviderContainer(
      overrides: [
        createApplianceProvider.overrideWithValue(CreateAppliance(repository)),
        getAppliancesProvider.overrideWithValue(GetAppliances(repository)),
        updateApplianceProvider.overrideWithValue(UpdateAppliance(repository)),
        deleteApplianceProvider.overrideWithValue(DeleteAppliance(repository)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Appliance createTestAppliance({
    String name = 'Réfrigérateur',
    double powerWatts = 150,
    double hoursPerDay = 10,
  }) {
    final now = DateTime.now();

    return Appliance(
      name: name,
      category: 'Cuisine',
      powerWatts: powerWatts,
      quantity: 1,
      hoursPerDay: hoursPerDay,
      daysPerMonth: 30,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('loads appliances successfully', () async {
    await repository.create(createTestAppliance());

    final notifier = container.read(appliancesProvider.notifier);

    await notifier.loadAppliances();

    final state = container.read(appliancesProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.appliances, hasLength(1));
    expect(state.appliances.first.name, 'Réfrigérateur');
  });

  test('creates an appliance and refreshes the state', () async {
    final notifier = container.read(appliancesProvider.notifier);

    await notifier.createAppliance(
      createTestAppliance(name: 'Télévision', powerWatts: 100, hoursPerDay: 5),
    );

    final state = container.read(appliancesProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.appliances, hasLength(1));
    expect(state.appliances.first.name, 'Télévision');
  });

  test('updates an appliance and refreshes the state', () async {
    final id = await repository.create(createTestAppliance());

    final notifier = container.read(appliancesProvider.notifier);

    final now = DateTime.now();

    await notifier.updateAppliance(
      Appliance(
        id: id,
        name: 'Réfrigérateur',
        category: 'Cuisine',
        powerWatts: 180,
        quantity: 1,
        hoursPerDay: 12,
        daysPerMonth: 30,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final state = container.read(appliancesProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.appliances, hasLength(1));
    expect(state.appliances.first.powerWatts, 180);
    expect(state.appliances.first.hoursPerDay, 12);
  });

  test('deletes an appliance and refreshes the state', () async {
    final id = await repository.create(createTestAppliance());

    final notifier = container.read(appliancesProvider.notifier);

    await notifier.deleteAppliance(id);

    final state = container.read(appliancesProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.appliances, isEmpty);
  });
}
