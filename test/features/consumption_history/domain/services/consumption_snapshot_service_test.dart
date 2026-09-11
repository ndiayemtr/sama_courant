import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/services/tariff_engine.dart';
import 'package:sama_courant/features/budget/domain/services/appliance_tariff_service.dart';
import 'package:sama_courant/features/budget/domain/providers/appliance_tariff_service_provider.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart';
import 'package:sama_courant/features/consumption_history/domain/repositories/consumption_snapshot_repository.dart';
import 'package:sama_courant/features/consumption_history/domain/services/consumption_snapshot_service.dart';
import 'package:sama_courant/features/consumption_history/domain/providers/consumption_snapshot_service_provider.dart';
import 'package:sama_courant/features/consumption_history/data/providers/consumption_snapshot_repository_provider.dart';

class RecordingRepository implements ConsumptionSnapshotRepository {
  final saved = <ConsumptionSnapshot>[];
  @override
  Future<int> create(ConsumptionSnapshot snapshot) async {
    saved.add(snapshot);
    return 42;
  }

  @override
  Future<List<ConsumptionSnapshot>> getAll() async => saved;
  @override
  Future<ConsumptionSnapshot?> getLatest() async => saved.lastOrNull;
  @override
  Future<ConsumptionSnapshot?> getById(int id) async => null;
}

class RecordingEngine implements TariffEngine {
  final consumptions = <double>[];
  final configurations = <TariffConfiguration>[];
  @override
  TariffCalculationResult calculate({
    required double consumptionKwh,
    required TariffConfiguration configuration,
  }) {
    consumptions.add(consumptionKwh);
    configurations.add(configuration);
    return const TariffEngineImpl().calculate(
      consumptionKwh: consumptionKwh,
      configuration: configuration,
    );
  }
}

Appliance appliance(double watts, {bool active = true, int quantity = 1}) =>
    Appliance(
      name: 'Appareil',
      category: 'Maison',
      powerWatts: watts,
      quantity: quantity,
      hoursPerDay: 10,
      daysPerMonth: 30,
      isActive: active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  late RecordingRepository repository;
  late RecordingEngine engine;
  late ConsumptionSnapshotService service;
  final configuration = WoyofalTariffConfigurationFactory.dpp2026();
  setUp(() {
    repository = RecordingRepository();
    engine = RecordingEngine();
    service = ConsumptionSnapshotService(
      repository: repository,
      tariffService: ApplianceTariffService(tariffEngine: engine),
    );
  });

  for (final inactiveOnly in [false, true]) {
    test(
      'captures zero totals without active appliances (inactive only: $inactiveOnly)',
      () async {
        expect(
          await service.capture(
            appliances: inactiveOnly ? [appliance(1000, active: false)] : [],
            configuration: configuration,
          ),
          42,
        );
        final saved = repository.saved.single;
        expect(saved.totalMonthlyConsumptionKwh, 0);
        expect(saved.totalMonthlyCostFcfa, 0);
        expect(saved.activeAppliancesCount, 0);
        expect(engine.consumptions, isEmpty);
      },
    );
  }

  test(
    'captures a single active appliance and preserves supplied capture date',
    () async {
      final captured = DateTime.utc(2025, 1, 2, 3, 4);
      final before = DateTime.now();
      final id = await service.capture(
        appliances: [appliance(150)],
        configuration: configuration,
        capturedAt: captured,
      );
      final saved = repository.saved.single;
      expect(id, 42);
      expect(saved.id, isNull);
      expect(saved.capturedAt, captured);
      expect(saved.createdAt.isBefore(before), isFalse);
      expect(saved.createdAt.isAfter(DateTime.now()), isFalse);
      expect(saved.totalMonthlyConsumptionKwh, 45);
      expect(saved.totalMonthlyCostFcfa, 3690);
      expect(saved.activeAppliancesCount, 1);
      expect(saved.tariffConfigurationName, configuration.name);
    },
  );

  test(
    'calculates progressive household cost once and excludes inactive appliances',
    () async {
      await service.capture(
        appliances: [
          appliance(500, quantity: 2),
          appliance(100),
          appliance(9000, active: false),
        ],
        configuration: configuration,
      );
      final saved = repository.saved.single;
      expect(engine.consumptions, [330]);
      expect(engine.configurations.single, same(configuration));
      expect(saved.totalMonthlyConsumptionKwh, 330);
      expect(saved.totalMonthlyCostFcfa, closeTo(36868.2, 1e-8));
      expect(saved.activeAppliancesCount, 2);
      expect(saved.capturedAt, saved.createdAt);
      expect(saved.tariffConfigurationName, configuration.name);
    },
  );

  test('active zero consumption remains valid', () async {
    await service.capture(
      appliances: [appliance(0)],
      configuration: configuration,
    );
    expect(repository.saved.single.totalMonthlyCostFcfa, 0);
    expect(repository.saved.single.activeAppliancesCount, 1);
    expect(engine.consumptions, [0]);
  });

  test(
    'service provider resolves with overridden dependencies without capturing automatically',
    () async {
      final container = ProviderContainer(
        overrides: [
          consumptionSnapshotRepositoryProvider.overrideWithValue(repository),
          applianceTariffServiceProvider.overrideWithValue(
            ApplianceTariffService(tariffEngine: engine),
          ),
        ],
      );
      addTearDown(container.dispose);
      final provided = container.read(consumptionSnapshotServiceProvider);
      expect(repository.saved, isEmpty);
      expect(engine.consumptions, isEmpty);
      expect(
        await provided.capture(
          appliances: [appliance(100)],
          configuration: configuration,
        ),
        42,
      );
      expect(repository.saved, hasLength(1));
      expect(engine.consumptions, [30]);
    },
  );
}
