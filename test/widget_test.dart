import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/app.dart';
import 'package:sama_courant/core/router/app_router.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'features/appliances/fakes/fake_appliance_repository.dart';

Appliance appliance(String name, double watts, {bool active = true}) =>
    Appliance(
      name: name,
      category: 'Maison',
      powerWatts: watts,
      quantity: 1,
      hoursPerDay: 10,
      daysPerMonth: 30,
      isActive: active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Future<void> openDashboard(
  WidgetTester tester,
  List<Appliance> appliances,
) async {
  final repository = FakeApplianceRepository();
  appRouter.go('/');
  for (final appliance in appliances) {
    await repository.create(appliance);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getAppliancesProvider.overrideWithValue(GetAppliances(repository)),
      ],
      child: const SamaCourantApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Dashboard with no appliances shows zero KPI and navigation', (
    tester,
  ) async {
    await openDashboard(tester, []);
    expect(find.text('Sama Courant'), findsOneWidget);
    expect(find.text('Bienvenue ⚡'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('0,00 kWh'), findsOneWidget);
    expect(find.text('0 FCFA'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    await tester.ensureVisible(find.text('Mes appareils'));
    await tester.tap(find.text('Mes appareils'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun appareil enregistré'), findsOneWidget);
  });

  testWidgets(
    'Dashboard aggregates active appliances and selects largest consumption',
    (tester) async {
      await openDashboard(tester, [
        appliance('Lampe', 100),
        appliance('Climatiseur', 900),
        appliance('Chauffage inactif', 2000, active: false),
      ]);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('300,00 kWh'), findsOneWidget);
      // 150 × 82 + 150 × 136.49: progressive household cost.
      expect(
        find.text('${NumberFormat.decimalPattern('fr_FR').format(32774)} FCFA'),
        findsOneWidget,
      );
      expect(find.text('Climatiseur'), findsOneWidget);
      expect(find.text('270,00 kWh/mois'), findsOneWidget);
      expect(find.text('≈ 90,0 % du total'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Chauffage inactif'), findsNothing);
    },
  );

  testWidgets('Dashboard excludes all inactive appliances on narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openDashboard(tester, [appliance('Chauffage', 2000, active: false)]);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('0,00 kWh'), findsOneWidget);
    expect(find.text('0 FCFA'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    await tester.ensureVisible(find.text('Mes appareils'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard handles an active appliance with zero consumption', (
    tester,
  ) async {
    await openDashboard(tester, [appliance('Lampe', 0)]);
    expect(find.text('≈ 0,0 % du total'), findsOneWidget);
    expect(find.text('0 FCFA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
