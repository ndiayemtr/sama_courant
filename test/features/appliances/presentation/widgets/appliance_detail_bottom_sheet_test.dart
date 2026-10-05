import 'package:sama_courant/features/appliances/presentation/widgets/appliance_calculation_details.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/presentation/widgets/appliance_detail_bottom_sheet.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 1.5]) {
      for (final active in [true, false]) {
        testWidgets('détail $width texte $scale actif $active', (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final appliance = Appliance(
            id: 7,
            name: 'Réfrigérateur familial grand modèle',
            category: 'refrigerator',
            powerWatts: 100,
            quantity: 1,
            hoursPerDay: 2,
            daysPerMonth: 30,
            isActive: active,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          );
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => ApplianceDetailBottomSheet.show(
                      context,
                      ApplianceDetailBottomSheet(
                        appliance: appliance,
                        monthlyCostFcfa: 1234,
                        monthlyConsumptionKwh: 6,
                        contributionPercentage: 25,
                        householdConsumptionKwh: 24,
                        householdCostFcfa: 4936,
                        tariffName: 'Woyofal DPP 2026',
                        tariffCategory: 'Domestique petite puissance',
                        effectiveFrom: DateTime(2026, 1, 1),
                        tariffConfiguration:
                            WoyofalTariffConfigurationFactory.dpp2026(),
                        householdResult: const TariffCalculationResult(
                          consumptionKwh: 24,
                          energyCost: 4936,
                          fees: 0,
                          taxes: 0,
                          totalCost: 4936,
                          tierCalculations: [],
                          feeCalculations: [],
                          taxCalculations: [],
                        ),
                      ),
                    ),
                    child: const Text('Ouvrir'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Ouvrir'));
          await tester.pumpAndSettle();
          expect(find.byType(ApplianceDetailBottomSheet), findsOneWidget);
          expect(find.byType(ApplianceCalculationDetails), findsNothing);
          expect(find.byIcon(Icons.expand_more), findsOneWidget);
          final initialRoute = ModalRoute.of(
            tester.element(find.byType(ApplianceDetailBottomSheet)),
          );
          for (final text in [
            appliance.name,
            active ? 'Actif' : 'Inactif',
            '1 234 FCFA',
            '6,00 kWh / mois',
            '25,0 %',
            '24,00 kWh',
            '4 936 FCFA',
            'Woyofal DPP 2026',
            'Catégorie : Domestique petite puissance',
            'Applicable depuis le 01/01/2026',
            'Comment ce montant est calculé ?',
            'Voir le détail des tranches et du calcul',
            'Le coût de cet appareil est estimé selon sa part dans la consommation mensuelle totale du foyer.',
          ]) {
            expect(find.text(text), findsOneWidget);
          }
          expect(
            tester
                .widget<LinearProgressIndicator>(
                  find.byType(LinearProgressIndicator),
                )
                .value,
            .25,
          );
          expect(find.byType(Chip), findsNothing);
          expect(
            tester.getSize(find.byType(Image)).width,
            greaterThanOrEqualTo(78),
          );
          if (width == 390 && scale == 1) {
            // The tariff and the start of the calculation action are visible
            // without scrolling on a normal mobile screen.
            expect(
              tester
                  .getBottomLeft(find.text('Applicable depuis le 01/01/2026'))
                  .dy,
              lessThan(800),
            );
            expect(
              tester
                  .getTopLeft(find.text('Comment ce montant est calculé ?'))
                  .dy,
              lessThan(800),
            );
          }
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
            find.text('Comment ce montant est calculé ?'),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Comment ce montant est calculé ?'));
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.expand_less), findsOneWidget);
          expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
          expect(
            ModalRoute.of(
              tester.element(find.byType(ApplianceCalculationDetails)),
            ),
            same(initialRoute),
          );
          expect(
            find.descendant(
              of: find.byType(ApplianceDetailBottomSheet),
              matching: find.byType(ApplianceCalculationDetails),
            ),
            findsOneWidget,
          );
          await tester.ensureVisible(find.text('Coût estimé de cet appareil'));
          await tester.pumpAndSettle();
          expect(
            find.text('Coût estimé de cet appareil').hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
            find.text('Comment ce montant est calculé ?'),
          );
          await tester.tap(find.text('Comment ce montant est calculé ?'));
          await tester.pumpAndSettle();
          expect(find.byType(ApplianceCalculationDetails), findsNothing);
          expect(find.byIcon(Icons.expand_more), findsOneWidget);
          expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
          await tester.ensureVisible(
            find.text(
              'Le coût de cet appareil est estimé selon sa part dans la consommation mensuelle totale du foyer.',
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byTooltip('Fermer'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Fermer'));
          await tester.pumpAndSettle();
          expect(find.byType(ApplianceDetailBottomSheet), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
