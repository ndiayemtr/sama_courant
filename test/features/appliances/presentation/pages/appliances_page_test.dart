import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
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

class FailedDeleteRepository extends TestApplianceRepository {
  FailedDeleteRepository() : super(appliances: [createTestAppliance()]);
  @override
  Future<void> delete(int id) async =>
      throw StateError('private deletion failure');
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
  testWidgets(
    'startup add options open once and the existing add button still works',
    (tester) async {
      final container = createContainer(
        TestApplianceRepository(appliances: [createTestAppliance()]),
      );
      addTearDown(container.dispose);
      Future<void> showPage({bool dark = false}) => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: dark ? ThemeData.dark() : ThemeData.light(),
            home: const AppliancesPage(openAddOptionsOnStart: true),
          ),
        ),
      );
      await showPage();
      await tester.pumpAndSettle();
      expect(find.text('Scanner une étiquette'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      Navigator.of(tester.element(find.text('Scanner une étiquette'))).pop();
      await tester.pumpAndSettle();
      await showPage(dark: true);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Scanner une étiquette'), findsOneWidget);
      expect(find.text('Ajouter manuellement'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  setUpAll(() => initializeDateFormatting('fr_FR'));
  for (final scale in [1.0, 1.5]) {
    testWidgets('la carte ouvre le détail tarifaire à 320 px, texte $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createContainer(
        TestApplianceRepository(appliances: [createTestAppliance()]),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const AppliancesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Réfrigérateur'));
      await tester.pumpAndSettle();
      expect(find.text('COÛT ESTIMÉ / MOIS'), findsOneWidget);
      expect(find.text('Woyofal DPP 2026'), findsOneWidget);
      expect(find.text('Tarif global du foyer (45,00 kWh)'), findsNothing);
      await tester.ensureVisible(find.text('Comment ce montant est calculé ?'));
      await tester.tap(find.text('Comment ce montant est calculé ?'));
      await tester.pumpAndSettle();
      expect(find.text('Tarif global du foyer (45,00 kWh)'), findsOneWidget);
      await tester.ensureVisible(find.text('Coût estimé de cet appareil'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
      await tester.ensureVisible(find.text('Comment ce montant est calculé ?'));
      await tester.tap(find.text('Comment ce montant est calculé ?'));
      await tester.pumpAndSettle();
      expect(find.text('Tarif global du foyer (45,00 kWh)'), findsNothing);
      expect(find.text('COÛT ESTIMÉ / MOIS'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Fermer'));
      await tester.tap(find.byTooltip('Fermer'));
      await tester.pumpAndSettle();
      expect(find.text('COÛT ESTIMÉ / MOIS'), findsNothing);
      expect(find.byTooltip('Actions'), findsOneWidget);
      final cardCost = find.descendant(
        of: find.byType(ApplianceCard),
        matching: find.text('Coût estimé'),
      );
      await tester.ensureVisible(cardCost);
      await tester.pumpAndSettle();
      await tester.ensureVisible(cardCost);
      await tester.pumpAndSettle();
      await tester.tap(cardCost);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
      expect(find.text('COÛT ESTIMÉ / MOIS'), findsOneWidget);
      expect(find.text('Tarif global du foyer (45,00 kWh)'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Fermer'));
      await tester.tap(find.byTooltip('Fermer'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('failed deletion never reports success or technical details', (
    tester,
  ) async {
    final container = createContainer(FailedDeleteRepository());
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Appareil supprimé avec succès.'), findsNothing);
    expect(find.textContaining('private deletion failure'), findsNothing);
    expect(
      find.text('Impossible de terminer la suppression. Veuillez réessayer.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Réfrigérateur'), findsOneWidget);
  });
  testWidgets('delete confirmation shows floating success', (tester) async {
    final container = createContainer(
      TestApplianceRepository(appliances: [createTestAppliance()]),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppliancesPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Appareil supprimé avec succès.'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
      SnackBarBehavior.floating,
    );
  });
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

    await tester.pumpAndSettle();

    // Informations principales.
    expect(find.text('Réfrigérateur'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('10 h/jour'), findsOneWidget);
    expect(find.text('30 j/mois'), findsOneWidget);
    expect(find.text('45,00 kWh'), findsOneWidget);
    expect(find.text('Coût estimé'), findsOneWidget);
    expect(find.textContaining('FCFA'), findsOneWidget);

    // Les actions ne sont plus directement visibles.
    expect(find.text('Modifier'), findsNothing);
    expect(find.text('Supprimer'), findsNothing);

    // Détail tarifaire.
    await tester.tap(find.text('Coût estimé'));
    await tester.pump();

    expect(details, isTrue);

    // Ouvrir le menu d'actions.
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Modifier'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);

    // Modifier.
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    expect(edited, isTrue);

    // Le popup se ferme après sélection :
    // il faut donc le rouvrir pour tester Supprimer.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer'), findsOneWidget);

    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);

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
    expect(find.text('10 h/jour'), findsOneWidget);
    expect(find.text('30 j/mois'), findsOneWidget);
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

    expect(find.text('Impossible de charger les appareils.'), findsOneWidget);
    expect(find.textContaining('Erreur de chargement'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);

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

  testWidgets('appliance card displays new usage model correctly', (
    tester,
  ) async {
    final appliance = Appliance(
      id: 2,
      name: 'Fer à repasser',
      category: 'Cuisine',
      powerWatts: 1600,
      quantity: 1,

      // Legacy conservé mais non utilisé pour le calcul principal.
      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 30,
      usageCount: 2,
      usageFrequency: UsageFrequency.weekly,

      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplianceCard(appliance: appliance, monthlyCostFcfa: 600),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fer à repasser'), findsOneWidget);

    expect(find.text('Utilisation'), findsOneWidget);

    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('2 fois / semaine'), findsOneWidget);

    expect(find.text('Conso/mois'), findsOneWidget);

    expect(find.text('6,93 kWh'), findsOneWidget);

    expect(find.text('Conso / jour'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('carte appareil reste lisible à 320 px avec texte à 150%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appliance = Appliance(
      id: 2,
      name: 'Fer à repasser',
      category: 'Cuisine',
      powerWatts: 1600,
      quantity: 1,

      // Legacy conservé uniquement pour compatibilité.
      hoursPerDay: 0,
      daysPerMonth: 30,

      usageDurationMinutes: 30,
      usageCount: 2,
      usageFrequency: UsageFrequency.weekly,

      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          );
        },
        home: Scaffold(
          body: SingleChildScrollView(
            child: ApplianceCard(
              appliance: appliance,
              monthlyCostFcfa: 600,
              isMostConsuming: true,
              contributionPercentage: 100,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fer à repasser'), findsOneWidget);
    expect(find.text('Utilisation'), findsOneWidget);
    expect(find.text('Coût estimé'), findsOneWidget);
    expect(find.text('Plus énergivore'), findsOneWidget);
    expect(find.text('100,0 % du total'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final usageRect = tester.getRect(find.text('Utilisation'));
    final consumptionRect = tester.getRect(find.text('Conso/mois'));
    final costRect = tester.getRect(find.text('Coût estimé'));
    expect(usageRect.top, consumptionRect.top);
    expect(consumptionRect.top, costRect.top);
    expect(usageRect.right, lessThan(consumptionRect.left));
    expect(consumptionRect.right, lessThan(costRect.left));
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('2 fois / semaine'), findsOneWidget);
    expect(find.text('Conso/mois'), findsOneWidget);
    expect(find.text('6,93 kWh'), findsOneWidget);

    expect(find.text('Conso / jour'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('le bouton Ajouter ne recouvre pas la dernière carte à 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appliance = Appliance(
      id: 2,
      name: 'Fer à repasser',
      category: 'Cuisine',
      powerWatts: 1600,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 30,
      usageCount: 2,
      usageFrequency: UsageFrequency.weekly,
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final repository = TestApplianceRepository(appliances: [appliance]);

    final container = createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const AppliancesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);

    for (var i = 0; i < 6; i++) {
      if (find.byType(ApplianceCard).evaluate().isNotEmpty) {
        break;
      }

      await tester.drag(listView, const Offset(0, -250));

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }

    expect(find.byType(ApplianceCard), findsOneWidget);

    await tester.fling(listView, const Offset(0, -1000), 2000);

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final cardRect = tester.getRect(find.byType(ApplianceCard));

    final fabRect = tester.getRect(find.byType(FloatingActionButton));

    expect(cardRect.bottom, lessThanOrEqualTo(fabRect.top));
  });
}
