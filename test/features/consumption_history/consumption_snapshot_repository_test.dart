import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sama_courant/core/database/app_database.dart';
import 'package:sama_courant/core/database/database_provider.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart'
    as domain;
import 'package:sama_courant/features/consumption_history/data/repositories/drift_consumption_snapshot_repository.dart';
import 'package:sama_courant/features/consumption_history/data/providers/consumption_snapshot_repository_provider.dart';

void main() {
  late AppDatabase database;
  late DriftConsumptionSnapshotRepository repository;
  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftConsumptionSnapshotRepository(database);
  });
  tearDown(() async => database.close());

  domain.ConsumptionSnapshot snapshot(int day, {int? id}) =>
      domain.ConsumptionSnapshot(
        id: id,
        capturedAt: DateTime(2026, 9, day, 10, 30, 15),
        totalMonthlyConsumptionKwh: 55.5,
        totalMonthlyCostFcfa: 4551.75,
        activeAppliancesCount: 3,
        tariffConfigurationName: 'Woyofal DPP 2026',
        createdAt: DateTime(2026, 10, 1, 11, 5, 20),
      );

  test('empty repository returns an empty list and null lookups', () async {
    expect(await repository.getAll(), isEmpty);
    expect(await repository.getLatest(), isNull);
    expect(await repository.getById(99), isNull);
  });

  test('creation generates an id and maps all values and dates', () async {
    final original = snapshot(11);
    final id = await repository.create(original);
    expect(id, greaterThan(0));
    expect(original.id, isNull);
    final row = (await repository.getById(id))!;
    expect(row.id, id);
    expect(row.capturedAt, original.capturedAt);
    expect(row.createdAt, original.createdAt);
    expect(row.totalMonthlyConsumptionKwh, 55.5);
    expect(row.totalMonthlyCostFcfa, 4551.75);
    expect(row.activeAppliancesCount, 3);
    expect(row.tariffConfigurationName, 'Woyofal DPP 2026');
    expect(await repository.getById(id + 1), isNull);
  });

  test('creation preserves an explicit id', () async {
    expect(await repository.create(snapshot(11, id: 42)), 42);
    expect((await repository.getById(42))?.id, 42);
  });

  test(
    'reads by capture time descending regardless of insertion order',
    () async {
      final newest = await repository.create(snapshot(13));
      final oldest = await repository.create(snapshot(10));
      final middle = await repository.create(snapshot(11));
      expect((await repository.getAll()).map((row) => row.id), [
        newest,
        middle,
        oldest,
      ]);
      expect((await repository.getLatest())?.id, newest);
    },
  );

  test('equal capture times use descending id consistently', () async {
    final first = await repository.create(snapshot(11));
    final second = await repository.create(snapshot(11));
    expect((await repository.getAll()).map((row) => row.id), [second, first]);
    expect((await repository.getLatest())?.id, second);
  });

  test('repository provider uses the supplied database', () async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final provided = container.read(consumptionSnapshotRepositoryProvider);
    final id = await provided.create(snapshot(11));
    expect((await repository.getById(id))?.id, id);
  });
}
