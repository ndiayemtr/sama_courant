import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/app.dart';
import 'package:sama_courant/core/router/app_router.dart';
import 'package:sama_courant/features/dashboard/presentation/widgets/top_consumers_card.dart';
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
  testWidgets('analysis summary remains readable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openDashboard(tester, [
      appliance('Réfrigérateur de la cuisine', 500),
      appliance('Ventilateur', 100),
    ]);
    final text = find.byKey(const ValueKey('analysis-summary'));
    expect(find.text('Analyse rapide'), findsOneWidget);
    expect(
      tester.widget<Text>(text).data,
      'Votre consommation est très concentrée sur Réfrigérateur de la cuisine, qui représente 83,3 % du total.',
    );
    await tester.ensureVisible(text);
    expect(tester.getRect(text).right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 800.0]) {
    testWidgets('top consumers displays allocated FCFA at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openDashboard(tester, [
        appliance('Réfrigérateur', 150),
        appliance('Ventilateur', 30),
        appliance('Inactif', 9999, active: false),
      ]);
      final first = find.byKey(const ValueKey('top-consumer-0'));
      final second = find.byKey(const ValueKey('top-consumer-1'));
      final separator = width == 320 ? '•' : '/';
      final fcfa = NumberFormat.decimalPattern('fr_FR');
      expect(
        find.descendant(
          of: first,
          matching: find.text('45,00 kWh $separator ${fcfa.format(3690)} FCFA'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: second,
          matching: find.text('9,00 kWh $separator ${fcfa.format(738)} FCFA'),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(second);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'top consumers ranks five active appliances with relative bars on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openDashboard(tester, [
        for (var i = 1; i <= 7; i++) appliance('Appareil $i', i * 100),
        appliance('Inactif', 9999, active: false),
      ]);
      final card = find.byType(TopConsumersCard);
      expect(
        find.descendant(
          of: card,
          matching: find.byType(LinearProgressIndicator),
        ),
        findsNWidgets(5),
      );
      for (var i = 0; i < 5; i++) {
        final row = find.byKey(ValueKey('top-consumer-$i'));
        expect(
          find.descendant(of: row, matching: find.text('Appareil ${7 - i}')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: row,
            matching: find.textContaining(
              '${NumberFormat('0.00', 'fr_FR').format((7 - i) * 30)} kWh',
            ),
          ),
          findsOneWidget,
        );
        final bar = tester.widget<LinearProgressIndicator>(
          find.descendant(
            of: row,
            matching: find.byType(LinearProgressIndicator),
          ),
        );
        expect(bar.value, closeTo((7 - i) / 7, 1e-9));
      }
      expect(
        find.descendant(of: card, matching: find.text('Autres')),
        findsNothing,
      );
      expect(
        find.descendant(of: card, matching: find.text('Inactif')),
        findsNothing,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('top-consumer-4')));
      expect(tester.takeException(), isNull);
    },
  );

  for (final watts in [100.0, 999999.0]) {
    testWidgets('Dashboard values share the right edge on mobile ($watts W)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openDashboard(tester, [
        appliance('Appareil avec un nom long', watts),
      ]);
      final summary = find.byWidgetPredicate((widget) => widget is Card).at(0);
      final texts = find.descendant(of: summary, matching: find.byType(Text));
      final valueTexts = texts.evaluate().where(
        (element) =>
            [
              '1',
              '${NumberFormat('0.00', 'fr_FR').format(watts * 0.3)} kWh',
            ].contains((element.widget as Text).data) ||
            ((element.widget as Text).data?.endsWith(' FCFA') ?? false),
      );
      final rightEdge = tester.getRect(summary).right - 12;
      expect(valueTexts.length, 3);
      for (final element in valueTexts) {
        final finder = find.byWidget(element.widget);
        expect(tester.getRect(finder).right, closeTo(rightEdge, 0.1));
        expect((element.widget as Text).textAlign, TextAlign.right);
      }
      final percentage = find.text('≈ 100,0 % du total');
      expect(tester.getRect(percentage).right, closeTo(rightEdge, 0.1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('donut tap and legend tap select consumption details', (
    tester,
  ) async {
    await openDashboard(tester, [
      appliance('Grand', 900),
      appliance('Petit', 100),
    ]);
    final chartFinder = find.byType(PieChart);
    final details = find.byKey(const ValueKey('consumption-selection'));
    expect(details, findsNothing);
    expect(find.text('300,00'), findsOneWidget);
    final initial = tester.widget<PieChart>(chartFinder).data.sections;
    expect(initial.map((section) => section.radius), [20, 20]);
    await tester.ensureVisible(chartFinder);
    await tester.tapAt(tester.getCenter(chartFinder) + const Offset(54, 0));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: details, matching: find.text('Grand')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('270,00 kWh/mois')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('90,0 %')),
      findsOneWidget,
    );
    expect(tester.widget<PieChart>(chartFinder).data.sections.first.radius, 26);
    final legend = find.byKey(const ValueKey('consumption-legend-1'));
    await tester.ensureVisible(legend);
    expect(tester.getSize(legend).height, greaterThanOrEqualTo(48));
    await tester.tap(legend);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: details, matching: find.text('Petit')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('30,00 kWh/mois')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('10,0 %')),
      findsOneWidget,
    );
    final selected = tester.widget<PieChart>(chartFinder).data.sections;
    expect(selected.map((section) => section.radius), [20, 26]);
    expect(
      selected.map((section) => section.color),
      initial.map((section) => section.color),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Others legend selects the grouped consumption', (tester) async {
    await openDashboard(tester, [
      for (var i = 1; i <= 8; i++) appliance('Appareil $i', i * 100),
    ]);
    final legend = find.byKey(const ValueKey('consumption-legend-5'));
    await tester.ensureVisible(legend);
    await tester.tap(legend);
    await tester.pumpAndSettle();
    final details = find.byKey(const ValueKey('consumption-selection'));
    expect(
      find.descendant(of: details, matching: find.text('Autres')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('180,00 kWh/mois')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: details, matching: find.text('16,7 %')),
      findsOneWidget,
    );
    expect(
      tester.widget<PieChart>(find.byType(PieChart)).data.sections.last.radius,
      26,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('single appliance donut remains readable on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openDashboard(tester, [
      appliance('Réfrigérateur de la cuisine', 100),
    ]);
    expect(find.text('100,0 %'), findsOneWidget);
    expect(find.text('30,00'), findsOneWidget);
    expect(
      tester.widget<PieChart>(find.byType(PieChart)).data.sections,
      hasLength(1),
    );
    await tester.ensureVisible(find.text('100,0 %'));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Mes appareils'));
    await tester.tap(find.text('Mes appareils'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier'), findsOneWidget);
  });

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
    expect(find.text('Aucune consommation à afficher.'), findsOneWidget);
    expect(find.text('Aucun appareil actif à comparer.'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
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
      expect(find.text('Climatiseur'), findsNWidgets(3));
      expect(find.text('270,00 kWh/mois'), findsOneWidget);
      expect(find.text('≈ 90,0 % du total'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));
      expect(find.text('90,0 %'), findsOneWidget);
      expect(find.text('10,0 %'), findsOneWidget);
      final chart = tester.widget<PieChart>(find.byType(PieChart));
      expect(chart.data.sections.map((section) => section.value), [270, 30]);
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
    expect(find.text('Aucune consommation à afficher.'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
    expect(find.text('—'), findsOneWidget);
    await tester.ensureVisible(find.text('Mes appareils'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard handles an active appliance with zero consumption', (
    tester,
  ) async {
    await openDashboard(tester, [appliance('Lampe', 0)]);
    expect(find.text('≈ 0,0 % du total'), findsOneWidget);
    expect(find.text('Aucune consommation à comparer.'), findsOneWidget);
    expect(find.text('Aucune consommation à afficher.'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
    expect(find.text('0 FCFA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
