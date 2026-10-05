import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/presentation/widgets/appliance_calculation_details.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier_calculation.dart';

void main() {
  for (final width in [320.0, 390.0, 800.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('calcul lisible à $width et texte $scale', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        // Supplied values deliberately remain independent: the UI must not
        // recompute tier costs, totals, or the appliance allocation.
        const result = TariffCalculationResult(
          consumptionKwh: 188.63,
          energyCost: 17573,
          fees: 0,
          taxes: 0,
          totalCost: 17573,
          feeCalculations: [],
          taxCalculations: [],
          tierCalculations: [
            TariffTierCalculation(
              tierOrder: 1,
              consumedKwh: 150,
              pricePerKwh: 82,
              cost: 12300,
            ),
            TariffTierCalculation(
              tierOrder: 2,
              consumedKwh: 38.63,
              pricePerKwh: 136.49,
              cost: 5273,
            ),
            TariffTierCalculation(
              tierOrder: 3,
              consumedKwh: 0,
              pricePerKwh: 136.49,
              cost: 0,
            ),
          ],
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
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ApplianceCalculationDetails(
                  result: result,
                  configuration: WoyofalTariffConfigurationFactory.dpp2026(),
                  householdConsumptionKwh: 188.63,
                  monthlyConsumptionKwh: 12.52,
                  contributionPercentage: 6.6,
                  monthlyCostFcfa: 1167,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final text in [
          'Tarif global du foyer (188,63 kWh)',
          "Détail des tranches d'énergie",
          'Tranche 0 – 150 kWh',
          '150,00 kWh × 82,00 FCFA/kWh',
          '12 300 FCFA',
          'Tranche 150 – 250 kWh',
          '38,63 kWh × 136,49 FCFA/kWh',
          '5 273 FCFA',
          'Taxes et redevances',
          '0 FCFA',
          'Total estimé du foyer',
          'Répartition pour cet appareil',
          '12,52 kWh',
          'Part de consommation',
          '6,6 %',
          'Coût estimé de cet appareil',
          '1 167 FCFA',
        ]) {
          expect(find.text(text), findsOneWidget);
        }
        expect(find.text('17 573 FCFA'), findsNWidgets(2));
        // Both total groups and the tier cards share a precise right edge,
        // including highlighted rows and the stacked accessibility layout.
        final values = [
          find.text('17 573 FCFA').first,
          find.text('17 573 FCFA').last,
          find.text('0 FCFA'),
          find.text('12,52 kWh'),
          find.text('6,6 %'),
          find.text('1 167 FCFA'),
          find.text('12 300 FCFA'),
          find.text('5 273 FCFA'),
        ];
        final rightEdge = tester.getRect(values.first).right;
        for (final value in values) {
          expect(tester.getRect(value).right, closeTo(rightEdge, 0.01));
          expect(tester.widget<Text>(value).textAlign, TextAlign.right);
        }
        expect(find.text('Tranche > 250 kWh'), findsNothing);
        expect(find.byType(DataTable), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('1 167 FCFA'));
        await tester.pumpAndSettle();
        expect(find.text('1 167 FCFA').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
