import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_courant/features/appliances/data/providers/appliance_repository_provider.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/domain/repositories/appliance_repository.dart';
import 'package:sama_courant/features/appliances/presentation/pages/appliance_form_page.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_label_type.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_scan_result.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';

class FakeApplianceRepository implements ApplianceRepository {
  Appliance? createdAppliance;
  bool fail = false;

  @override
  Future<int> create(Appliance appliance) async {
    if (fail) throw StateError('private database details');
    createdAppliance = appliance;
    return 1;
  }

  @override
  Future<List<Appliance>> getAll() async {
    return [];
  }

  @override
  Future<Appliance?> getById(int id) async {
    return null;
  }

  @override
  Future<bool> update(Appliance appliance) async {
    if (fail) throw StateError('private database details');
    return true;
  }

  @override
  Future<void> delete(int id) async {}
}

GoRouter createTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Page précédente'))),
      ),
      GoRoute(
        path: '/appliances/add',
        builder: (context, state) => const ApplianceFormPage(),
      ),
      GoRoute(
        path: '/appliances/edit',
        builder: (context, state) =>
            ApplianceFormPage(appliance: state.extra! as Appliance),
      ),
      GoRoute(
        path: '/appliances/add-from-scan',
        builder: (context, state) =>
            ApplianceFormPage(scanResult: state.extra! as ApplianceScanResult),
      ),
    ],
  );
}

Widget createTestWidget(
  FakeApplianceRepository repository,
  GoRouter router, {
  double textScale = 1,
}) {
  return ProviderScope(
    overrides: [applianceRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}

Future<void> enterField(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label, skipOffstage: false);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

Future<void> tapSave(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pump();

  await tester.drag(find.byType(ListView).first, const Offset(0, -500));
  await tester.pumpAndSettle();

  final saveButton = find.byType(FilledButton);
  await tester.scrollUntilVisible(
    saveButton,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
}

Future<void> setDurationSlider(WidgetTester tester, double value) async {
  final sliders = find.byType(Slider, skipOffstage: false);

  expect(sliders, findsNWidgets(2));

  final durationFinder = sliders.at(0);

  await tester.scrollUntilVisible(
    durationFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.pumpAndSettle();

  final slider = tester.widget<Slider>(durationFinder);

  slider.onChanged!(value);

  await tester.pumpAndSettle();
}

Future<void> setUsageCountSlider(WidgetTester tester, double value) async {
  final sliders = find.byType(Slider, skipOffstage: false);

  expect(sliders, findsNWidgets(2));

  final usageCountFinder = sliders.at(1);

  await tester.scrollUntilVisible(
    usageCountFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.pumpAndSettle();

  final slider = tester.widget<Slider>(usageCountFinder);

  slider.onChanged!(value);

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('validates MVP numeric and name boundaries', (tester) async {
    final repository = FakeApplianceRepository();
    final router = createTestRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(createTestWidget(repository, router));
    router.push('/appliances/add');
    await tester.pumpAndSettle();
    final cases = <String, ({List<String> valid, List<String> invalid})>{
      'Nom': (
        valid: ['Lampe', 'A' * 100],
        invalid: ['', '   ', 'A' * 101, 'A' * 1000],
      ),
      'Puissance': (
        valid: ['0.1', '1000000000'],
        invalid: ['0', 'abc', 'NaN', 'Infinity', '1e309'],
      ),
      'Quantité': (
        valid: ['1', '9223372036854775807'],
        invalid: ['0', '1.5', 'abc', '9223372036854775808'],
      ),
    };
    final acceptedInvalidValues = <String>[];
    for (final entry in cases.entries) {
      final field = find.widgetWithText(
        TextFormField,
        entry.key,
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(
        field,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final validate = tester.widget<TextFormField>(field).validator!;
      for (final value in entry.value.valid) {
        expect(validate(value), isNull, reason: '${entry.key}: $value');
      }
      for (final value in entry.value.invalid) {
        if (validate(value) == null) {
          acceptedInvalidValues.add('${entry.key}: $value');
        }
      }
    }
    expect(acceptedInvalidValues, isEmpty);
  });

  for (final input in [
    (power: '1e308', quantity: '9223372036854775807', overflow: true),
    (power: '2e305', quantity: '1', overflow: false),
    (power: '100', quantity: '9223372036854775807', overflow: false),
  ]) {
    testWidgets('saves only finite monthly consumption $input', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(createTestWidget(repository, router));
      router.push('/appliances/add');
      await tester.pumpAndSettle();
      await enterField(tester, 'Nom', 'Lampe');

      await enterField(tester, 'Puissance', input.power);
      await enterField(tester, 'Quantité', input.quantity);
      await setDurationSlider(tester, 1440);
      await tapSave(tester);
      await tester.pumpAndSettle();
      if (input.overflow) {
        expect(repository.createdAppliance, isNull);
        expect(
          find.text('Impossible d’enregistrer l’appareil. Veuillez réessayer.'),
          findsOneWidget,
        );
      } else {
        expect(repository.createdAppliance, isNotNull);
        expect(
          repository.createdAppliance!.monthlyConsumptionKwh.isFinite,
          isTrue,
        );
      }
      expect(find.textContaining('Infinity'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final edit in [false, true]) {
    for (final fail in [false, true]) {
      testWidgets('form feedback edit=$edit fail=$fail', (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = FakeApplianceRepository()..fail = fail;
        final router = createTestRouter();
        addTearDown(router.dispose);
        await tester.pumpWidget(
          createTestWidget(repository, router, textScale: 1.5),
        );
        router.push(
          edit ? '/appliances/edit' : '/appliances/add',
          extra: edit
              ? Appliance(
                  id: 1,
                  name: 'Lampe',
                  category: 'Cuisine',
                  powerWatts: 100,
                  quantity: 1,
                  hoursPerDay: 8,
                  daysPerMonth: 30,
                  usageDurationMinutes: 480,
                  usageCount: 1,
                  usageFrequency: UsageFrequency.daily,
                  isActive: true,
                  createdAt: DateTime(2026),
                  updatedAt: DateTime(2026),
                )
              : null,
        );
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        if (!edit) {
          await enterField(tester, 'Nom', 'Lampe');

          await enterField(tester, 'Puissance', '100');
          await setDurationSlider(tester, 480);
        }
        await tapSave(tester);
        await tester.pumpAndSettle();
        final message = fail
            ? (edit
                  ? 'Impossible de modifier l’appareil. Veuillez réessayer.'
                  : 'Impossible d’enregistrer l’appareil. Veuillez réessayer.')
            : (edit
                  ? 'Appareil modifié avec succès.'
                  : 'Appareil enregistré avec succès.');
        expect(find.text(message), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
          SnackBarBehavior.floating,
        );
        expect(find.textContaining('private database details'), findsNothing);
        expect(find.textContaining('StateError'), findsNothing);
        if (fail) {
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        expect(find.text('Page précédente'), findsOneWidget);
      });
    }
  }
  group('ApplianceFormPage', () {
    testWidgets('affiche les erreurs lorsque le formulaire est vide', (
      tester,
    ) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await tapSave(tester);

      await tester.pump();

      expect(
        find.text('Le nom de l’appareil est requis.', skipOffstage: false),
        findsOneWidget,
      );

      expect(
        find.text('La puissance est requise.', skipOffstage: false),
        findsOneWidget,
      );

      expect(repository.createdAppliance, isNull);
    });

    testWidgets('refuse une puissance négative', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await enterField(tester, 'Nom', 'Réfrigérateur');
      await enterField(tester, 'Puissance', '-100');

      await tapSave(tester);

      await tester.pump();

      expect(
        find.text(
          'La puissance doit être supérieure à 0 W.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      expect(repository.createdAppliance, isNull);
    });

    testWidgets('le slider durée respecte les bornes prévues', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');
      await tester.pumpAndSettle();

      final sliders = find.byType(Slider, skipOffstage: false);

      expect(sliders, findsNWidgets(2));

      final durationSlider = tester.widget<Slider>(sliders.at(0));

      expect(durationSlider.min, 5);
      expect(durationSlider.max, 1440);
    });

    testWidgets('le slider nombre de fois respecte les bornes prévues', (
      tester,
    ) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');
      await tester.pumpAndSettle();

      final sliders = find.byType(Slider, skipOffstage: false);

      expect(sliders, findsNWidgets(2));

      final usageCountSlider = tester.widget<Slider>(sliders.at(1));

      expect(usageCountSlider.min, 1);
      expect(usageCountSlider.max, 30);
    });

    testWidgets('crée un appareil avec les données saisies', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await enterField(tester, 'Nom', 'Réfrigérateur');

      await enterField(tester, 'Puissance', '150');
      await enterField(tester, 'Quantité', '1');
      await setDurationSlider(tester, 480);
      await setUsageCountSlider(tester, 1);

      await tapSave(tester);

      await tester.pumpAndSettle();

      expect(repository.createdAppliance, isNotNull);

      final appliance = repository.createdAppliance!;

      expect(appliance.name, 'Réfrigérateur');
      expect(appliance.category, 'Autre');
      expect(appliance.powerWatts, 150);
      expect(appliance.quantity, 1);
      expect(appliance.usageDurationMinutes, 480);
      expect(appliance.usageCount, 1);
      expect(appliance.usageFrequency, UsageFrequency.daily);
      expect(appliance.usesNewUsageModel, isTrue);

      expect(appliance.hoursPerDay, 0);
      expect(appliance.daysPerMonth, 30);
      expect(appliance.isActive, isTrue);
    });

    testWidgets(
      'préremplit le formulaire depuis le scan et conserve les métadonnées',
      (tester) async {
        final repository = FakeApplianceRepository();
        final router = createTestRouter();

        addTearDown(router.dispose);

        const scanResult = ApplianceScanResult(
          rawOcrText: '''
BOSCH
MODEL KGN36
150 W
216 kWh/annum
''',
          brand: 'Bosch',
          model: 'KGN36',
          applianceType: 'refrigerator',
          powerWatts: 150,
          powerSource: PowerSource.detected,
          confidenceLevel: ConfidenceLevel.high,
          labelType: ApplianceLabelType.energyLabel,
          energyConsumptionMetrics: [
            EnergyConsumptionMetric(
              valueKwh: 216,
              basis: EnergyConsumptionBasis.perYear,
            ),
          ],
        );

        await tester.pumpWidget(createTestWidget(repository, router));

        router.push('/appliances/add-from-scan', extra: scanResult);

        await tester.pumpAndSettle();

        // ----------------------------------------------------------
        // 1. Vérifier le préremplissage visuel
        // ----------------------------------------------------------

        final nameField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Nom', skipOffstage: false),
        );

        expect(nameField.controller?.text, 'Réfrigérateur Bosch KGN36');

        final powerField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Puissance', skipOffstage: false),
        );

        expect(powerField.controller?.text, '150.0');

        // ----------------------------------------------------------
        // 3. Enregistrer l'appareil
        // ----------------------------------------------------------

        await tapSave(tester);
        await tester.pumpAndSettle();

        expect(repository.createdAppliance, isNotNull);

        final created = repository.createdAppliance!;

        // ----------------------------------------------------------
        // 4. Vérifier les données visibles
        // ----------------------------------------------------------

        expect(repository.createdAppliance!.name, 'Réfrigérateur Bosch KGN36');
        expect(created.category, 'refrigerator');
        expect(created.powerWatts, 150);

        // ----------------------------------------------------------
        // 5. Vérifier les métadonnées invisibles du scan
        // ----------------------------------------------------------

        expect(created.labelType, ApplianceLabelType.energyLabel);

        expect(created.powerSource, PowerSource.detected);

        expect(created.energyConsumptionMetrics, hasLength(1));

        expect(created.energyConsumptionMetrics.single.valueKwh, 216);

        expect(
          created.energyConsumptionMetrics.single.basis,
          EnergyConsumptionBasis.perYear,
        );
      },
    );
  });

  testWidgets('formulaire reste responsive à 320 px avec texte à 150%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeApplianceRepository();
    final router = createTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      createTestWidget(repository, router, textScale: 1.5),
    );

    router.push('/appliances/add');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final listView = find.byType(ListView).first;

    // Descend jusqu'à la section Utilisation.
    for (var i = 0; i < 5; i++) {
      if (find.byType(Slider).evaluate().length == 2) {
        break;
      }

      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }

    expect(find.byType(Slider), findsNWidgets(2));

    // Continue légèrement pour atteindre la fréquence si nécessaire.
    for (var i = 0; i < 3; i++) {
      if (find
          .byType(DropdownButtonFormField<UsageFrequency>)
          .evaluate()
          .isNotEmpty) {
        break;
      }

      await tester.drag(listView, const Offset(0, -250));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }

    expect(
      find.byType(DropdownButtonFormField<UsageFrequency>),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
}
