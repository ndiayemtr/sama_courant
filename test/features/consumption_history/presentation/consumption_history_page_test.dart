import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sama_courant/app.dart';
import 'package:sama_courant/core/router/app_router.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'package:sama_courant/features/consumption_history/data/providers/consumption_snapshot_repository_provider.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_snapshot.dart';
import 'package:sama_courant/features/consumption_history/domain/repositories/consumption_snapshot_repository.dart';
import 'package:sama_courant/features/consumption_history/presentation/pages/consumption_history_page.dart';
import 'package:sama_courant/features/consumption_history/presentation/widgets/consumption_history_chart.dart';

import '../../appliances/fakes/fake_appliance_repository.dart';

class HistoryRepository implements ConsumptionSnapshotRepository {
  Future<List<ConsumptionSnapshot>> Function() load = () async => [];
  int calls = 0;
  @override
  Future<List<ConsumptionSnapshot>> getAll() {
    calls++;
    return load();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ConsumptionSnapshot snapshot(int day) => ConsumptionSnapshot(
  id: day,
  capturedAt: DateTime(2026, 9, day, 8, 45),
  createdAt: DateTime(2026, 9, day, 8, 45),
  totalMonthlyConsumptionKwh: 55.5,
  totalMonthlyCostFcfa: 4551,
  activeAppliancesCount: 2,
  tariffConfigurationName: 'Woyofal DPP 2026',
);

Future<void> openHistory(WidgetTester tester, HistoryRepository repository) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          consumptionSnapshotRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ConsumptionHistoryPage()),
      ),
    );

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  testWidgets(
    'period filters share snapshots between chart and list on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();
      final entries = [2, 15, 45]
          .map(
            (days) => ConsumptionSnapshot(
              capturedAt: now.subtract(Duration(days: days)),
              createdAt: now,
              totalMonthlyConsumptionKwh: days.toDouble(),
              totalMonthlyCostFcfa: 100,
              activeAppliancesCount: 1,
              tariffConfigurationName: 'Grille $days',
            ),
          )
          .toList();
      final repository = HistoryRepository()..load = () async => entries;
      await openHistory(tester, repository);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>))
            .selected,
        {30},
      );
      for (final period in [30, 7, 0]) {
        await tester.tap(find.text(period == 0 ? 'Tout' : '$period jours'));
        await tester.pumpAndSettle();
        final expected = period == 7
            ? [2]
            : period == 30
            ? [2, 15]
            : [2, 15, 45];
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('history-visible-count')))
              .data,
          startsWith('${expected.length} état'),
        );
        final points = tester
            .widget<ConsumptionHistoryChart>(
              find.byType(ConsumptionHistoryChart),
            )
            .points;
        expect(points.map((p) => p.consumptionKwh), expected.reversed);
        for (final days in [2, 15, 45]) {
          expect(
            find.text('Grille $days'),
            expected.contains(days) ? findsOneWidget : findsNothing,
          );
        }
        expect(tester.takeException(), isNull);
      }
      expect(repository.calls, 1);
    },
  );

  testWidgets('empty period differs from empty history and Tout restores it', (
    tester,
  ) async {
    final now = DateTime.now();
    final repository = HistoryRepository()
      ..load = () async => [
        ConsumptionSnapshot(
          capturedAt: now.subtract(const Duration(days: 45)),
          createdAt: now,
          totalMonthlyConsumptionKwh: 1,
          totalMonthlyCostFcfa: 1,
          activeAppliancesCount: 1,
          tariffConfigurationName: 'Ancienne grille',
        ),
      ];
    await openHistory(tester, repository);
    await tester.pumpAndSettle();
    expect(
      find.text('Aucun état enregistré sur cette période.'),
      findsOneWidget,
    );
    expect(find.text('Aucun historique enregistré.'), findsNothing);
    expect(find.byType(ConsumptionHistoryChart), findsNothing);
    await tester.tap(find.text('Tout'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsumptionHistoryChart), findsOneWidget);
    expect(find.text('Aucun état enregistré sur cette période.'), findsNothing);
  });
  testWidgets('loading becomes an empty history', (tester) async {
    final pending = Completer<List<ConsumptionSnapshot>>();
    final repository = HistoryRepository()..load = () => pending.future;
    await openHistory(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Aucun historique enregistré.'), findsOneWidget);
    expect(
      find.text(
        'Enregistrez un état depuis le Dashboard pour commencer le suivi.',
      ),
      findsOneWidget,
    );
    expect(repository.calls, 1);
  });

  testWidgets('shows repository order and French values on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = HistoryRepository()
      ..load = () async => [snapshot(11), snapshot(10)];
    await openHistory(tester, repository);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Consommation estimée : 55,50 kWh'), findsNWidgets(2));
    expect(
      find.text(
        'Coût estimé : ${NumberFormat.decimalPattern('fr_FR').format(4551)} FCFA',
      ),
      findsNWidgets(2),
    );
    expect(find.text('2 appareils actifs'), findsNWidgets(2));
    expect(find.text('Woyofal DPP 2026'), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('11/09/2026 à 08:45')).dy,
      lessThan(tester.getTopLeft(find.text('10/09/2026 à 08:45')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('repository error is friendly and retry loads a snapshot', (
    tester,
  ) async {
    final repository = HistoryRepository()
      ..load = () async => throw StateError('private');
    await openHistory(tester, repository);
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger l’historique.'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
    repository.load = () async => [snapshot(11)];
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('11/09/2026 à 08:45'), findsNWidgets(2));
    expect(repository.calls, 2);
  });

  testWidgets('pull to refresh updates an empty list without crashing', (
    tester,
  ) async {
    final repository = HistoryRepository();
    await openHistory(tester, repository);
    await tester.pumpAndSettle();
    repository.load = () async => [snapshot(11)];
    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('11/09/2026 à 08:45'), findsNWidgets(2));
    expect(repository.calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard opens history and reopening reloads snapshots', (
    tester,
  ) async {
    final repository = HistoryRepository();
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consumptionSnapshotRepositoryProvider.overrideWithValue(repository),
          getAppliancesProvider.overrideWithValue(
            GetAppliances(FakeApplianceRepository()),
          ),
        ],
        child: const SamaCourantApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enregistrer l’état actuel'), findsOneWidget);
    await tester.ensureVisible(find.text('Voir l’historique'));
    await tester.tap(find.text('Voir l’historique'));
    await tester.pumpAndSettle();
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Aucun historique enregistré.'), findsOneWidget);
    appRouter.pop();
    await tester.pumpAndSettle();
    repository.load = () async => [snapshot(11)];
    await tester.ensureVisible(find.text('Voir l’historique'));
    await tester.tap(find.text('Voir l’historique'));
    await tester.pumpAndSettle();
    expect(find.text('11/09/2026 à 08:45'), findsNWidgets(2));
    expect(repository.calls, 2);
    appRouter.pop();
    await tester.pumpAndSettle();
  });
}
