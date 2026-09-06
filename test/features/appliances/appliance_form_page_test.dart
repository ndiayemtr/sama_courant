import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/data/providers/appliance_repository_provider.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/repositories/appliance_repository.dart';
import 'package:sama_courant/features/appliances/presentation/pages/appliance_form_page.dart';

class FakeApplianceRepository implements ApplianceRepository {
  Appliance? createdAppliance;

  @override
  Future<int> create(Appliance appliance) async {
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
    return true;
  }

  @override
  Future<void> delete(int id) async {}
}

Widget createTestWidget(FakeApplianceRepository repository) {
  return ProviderScope(
    overrides: [applianceRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: ApplianceFormPage()),
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

  final saveButton = find.byType(FilledButton, skipOffstage: false);
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
}

void main() {
  group('ApplianceFormPage', () {
    testWidgets('affiche les erreurs lorsque le formulaire est vide', (
      tester,
    ) async {
      final repository = FakeApplianceRepository();

      await tester.pumpWidget(createTestWidget(repository));
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

      await tester.pumpWidget(createTestWidget(repository));
      await tester.pumpAndSettle();

      await enterField(tester, 'Nom de l’appareil', 'Réfrigérateur');
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

      await tester.pumpWidget(createTestWidget(repository));
      await tester.pumpAndSettle();

      await enterField(tester, 'Heures / jour', '25');

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

      await tester.pumpWidget(createTestWidget(repository));
      await tester.pumpAndSettle();

      await enterField(tester, 'Jours / mois', '32');

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

      await tester.pumpWidget(createTestWidget(repository));
      await tester.pumpAndSettle();

      await enterField(tester, 'Nom de l’appareil', 'Réfrigérateur');

      final categoryField = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(categoryField);
      await tester.tap(categoryField);

      await tester.pumpAndSettle();

      await tester.tap(find.text('Cuisine').last);

      await enterField(tester, 'Puissance', '150');
      await enterField(tester, 'Quantité', '1');
      await enterField(tester, 'Heures / jour', '8');
      await enterField(tester, 'Jours / mois', '30');

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
