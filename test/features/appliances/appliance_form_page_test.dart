import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_courant/features/appliances/data/providers/appliance_repository_provider.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/repositories/appliance_repository.dart';
import 'package:sama_courant/features/appliances/presentation/pages/appliance_form_page.dart';

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
      'Heures/j': (
        valid: ['0.1', '24'],
        invalid: ['0', '25', 'abc', 'NaN', 'Infinity'],
      ),
      'Jours/mois': (valid: ['1', '31'], invalid: ['0', '32', 'abc', '1.5']),
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
    (power: '1e308', quantity: '1', overflow: true),
    (power: '2e306', quantity: '1', overflow: false),
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
      final category = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(category);
      await tester.pumpAndSettle();
      await tester.tap(category);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cuisine').last);
      await enterField(tester, 'Puissance', input.power);
      await enterField(tester, 'Quantité', input.quantity);
      await enterField(tester, 'Heures/j', '24');
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
          final category = find.byType(DropdownButtonFormField<String>);
          await tester.ensureVisible(category);
          await tester.tap(category);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cuisine').last);
          await enterField(tester, 'Puissance', '100');
          await enterField(tester, 'Heures/j', '8');
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

      expect(find.text('Le nom de l’appareil est requis.'), findsOneWidget);

      expect(find.text('La puissance est requise.'), findsOneWidget);

      expect(
        find.text('Les heures d’utilisation sont requises.'),
        findsOneWidget,
      );

      expect(find.text('Veuillez sélectionner une catégorie.'), findsOneWidget);

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
        find.text('La puissance doit être supérieure à 0 W.'),
        findsOneWidget,
      );

      expect(repository.createdAppliance, isNull);
    });

    testWidgets('refuse une durée supérieure à 24 heures', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await enterField(tester, 'Heures/j', '25');

      await tapSave(tester);

      await tester.pump();

      expect(
        find.text('Les heures doivent être comprises entre 0 et 24.'),
        findsOneWidget,
      );

      expect(repository.createdAppliance, isNull);
    });

    testWidgets('refuse un nombre de jours supérieur à 31', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await enterField(tester, 'Jours/mois', '32');

      await tapSave(tester);

      await tester.pump();

      expect(
        find.text('Les jours doivent être compris entre 1 et 31.'),
        findsOneWidget,
      );

      expect(repository.createdAppliance, isNull);
    });

    testWidgets('crée un appareil avec les données saisies', (tester) async {
      final repository = FakeApplianceRepository();
      final router = createTestRouter();

      await tester.pumpWidget(createTestWidget(repository, router));

      router.push('/appliances/add');

      await tester.pumpAndSettle();

      await enterField(tester, 'Nom', 'Réfrigérateur');

      final categoryField = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(categoryField);
      await tester.tap(categoryField);

      await tester.pumpAndSettle();

      await tester.tap(find.text('Cuisine').last);

      await enterField(tester, 'Puissance', '150');
      await enterField(tester, 'Quantité', '1');
      await enterField(tester, 'Heures/j', '8');
      await enterField(tester, 'Jours/mois', '30');

      await tapSave(tester);

      await tester.pumpAndSettle();

      expect(repository.createdAppliance, isNotNull);

      final appliance = repository.createdAppliance!;

      expect(appliance.name, 'Réfrigérateur');
      expect(appliance.category, 'Cuisine');
      expect(appliance.powerWatts, 150);
      expect(appliance.quantity, 1);
      expect(appliance.hoursPerDay, 8);
      expect(appliance.daysPerMonth, 30);
      expect(appliance.isActive, isTrue);
    });
  });
}
