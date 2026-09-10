import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/repositories/appliance_repository.dart';
import 'package:sama_courant/features/appliances/domain/usecases/create_appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/delete_appliance.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'package:sama_courant/features/appliances/domain/usecases/update_appliance.dart';
import 'package:sama_courant/features/appliances/presentation/pages/appliances_page.dart';
import 'package:sama_courant/features/appliances/presentation/widgets/appliance_card.dart';

class TestApplianceRepository implements ApplianceRepository {
  List<Appliance> appliances;

  TestApplianceRepository({this.appliances = const []});

  @override
  Future<List<Appliance>> getAll() async {
    return appliances;
  }

  @override
  Future<Appliance?> getById(int id) async {
    for (final appliance in appliances) {
      if (appliance.id == id) {
        return appliance;
      }
    }

    return null;
  }

  @override
  Future<int> create(Appliance appliance) async {
    return 1;
  }

  @override
  Future<bool> update(Appliance appliance) async {
    return true;
  }

  @override
  Future<void> delete(int id) async {}
}

class ErrorApplianceRepository implements ApplianceRepository {
  @override
  Future<List<Appliance>> getAll() async {
    throw Exception('Erreur de chargement');
  }

  @override
  Future<Appliance?> getById(int id) async {
    return null;
  }

  @override
  Future<int> create(Appliance appliance) async {
    return 1;
  }

  @override
  Future<bool> update(Appliance appliance) async {
    return true;
  }

  @override
  Future<void> delete(int id) async {}
}

class PendingApplianceRepository extends TestApplianceRepository {
  final Completer<List<Appliance>> loadCompleter = Completer();

  @override
  Future<List<Appliance>> getAll() => loadCompleter.future;
}

class RetryApplianceRepository extends TestApplianceRepository {
  bool failed = false;

  @override
  Future<List<Appliance>> getAll() async {
    if (!failed) {
      failed = true;
      throw Exception('Erreur temporaire');
    }
    return [createTestAppliance()];
  }
}

Appliance createTestAppliance() {
  final now = DateTime.now();

  return Appliance(
    id: 1,
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
}

ProviderContainer createContainer(ApplianceRepository repository) {
  return ProviderContainer(
    overrides: [
      createApplianceProvider.overrideWithValue(CreateAppliance(repository)),
      getAppliancesProvider.overrideWithValue(GetAppliances(repository)),
      updateApplianceProvider.overrideWithValue(UpdateAppliance(repository)),
      deleteApplianceProvider.overrideWithValue(DeleteAppliance(repository)),
    ],
  );
}

void main() {
  testWidgets('retry clears loading error after successful reload', (
    tester,
  ) async {
    final container = createContainer(RetryApplianceRepository());
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Réfrigérateur'), findsOneWidget);
    expect(find.text('Une erreur est survenue'), findsNothing);
  });

  testWidgets('appliance card keeps actions and French values on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var details = false;
    var edited = false;
    var deleted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ApplianceCard(
              appliance: createTestAppliance(),
              monthlyCostFcfa: 3690,
              onViewTariffDetails: () => details = true,
              onEdit: () => edited = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('1,50 kWh'), findsOneWidget);
    expect(find.text('45,00 kWh'), findsOneWidget);
    await tester.tap(find.text('Part mensuelle estimée'));
    await tester.tap(find.text('Modifier'));
    await tester.tap(find.text('Supprimer'));
    expect(details && edited && deleted, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('displays appliances when data is available', (tester) async {
    final repository = TestApplianceRepository(
      appliances: [createTestAppliance()],
    );

    final container = createContainer(repository);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mes appareils'), findsOneWidget);
    expect(find.text('Réfrigérateur'), findsOneWidget);
    expect(find.text('1,50 kWh'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ApplianceCard),
        matching: find.text('45,00 kWh'),
      ),
      findsOneWidget,
    );

    container.dispose();
  });

  testWidgets('displays empty state when there are no appliances', (
    tester,
  ) async {
    final repository = TestApplianceRepository();

    final container = createContainer(repository);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Aucun appareil enregistré'), findsOneWidget);

    expect(find.text('Ajouter un appareil'), findsOneWidget);

    container.dispose();
  });

  testWidgets('displays error state when loading fails', (tester) async {
    final repository = ErrorApplianceRepository();

    final container = createContainer(repository);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Une erreur est survenue'), findsOneWidget);

    expect(find.textContaining('Erreur de chargement'), findsOneWidget);

    expect(find.text('Réessayer'), findsOneWidget);

    container.dispose();
  });

  testWidgets('displays loading state', (tester) async {
    final repository = PendingApplianceRepository();

    final container = createContainer(repository);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.loadCompleter.complete(const []);
    await tester.pumpAndSettle();

    container.dispose();
  });
}
