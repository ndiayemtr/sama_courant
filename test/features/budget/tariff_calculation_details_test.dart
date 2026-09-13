import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/presentation/widgets/tariff_calculation_details.dart';

void main() {
  for (final kwh in [100.0, 300.0]) {
    testWidgets('real breakdown at $kwh kWh fits mobile', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final configuration = WoyofalTariffConfigurationFactory.dpp2026();
      final result = const TariffEngineImpl().calculate(
        consumptionKwh: kwh,
        configuration: configuration,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TariffCalculationDetails(
                  result: result,
                  configuration: configuration,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('0–150 kWh'), findsOneWidget);
      if (kwh == 300) {
        expect(result.energyCost, closeTo(32773.5, 1e-8));
        expect(result.taxCalculations.single.baseAmount, closeTo(6824.5, 1e-8));
        expect(result.taxes, closeTo(1228.41, 1e-8));
        expect(result.totalCost, closeTo(34001.91, 1e-8));
        expect(find.text('TVA 18 %'), findsOneWidget);
        expect(find.text('Assiette : 6824,50 FCFA'), findsOneWidget);
        expect(find.text('>250 kWh'), findsOneWidget);
        expect(find.text('150,00 kWh × 82,00 FCFA/kWh'), findsOneWidget);
      } else {
        expect(find.text('TVA 18 %'), findsNothing);
        expect(find.text('150–250 kWh'), findsNothing);
        expect(find.text('Aucune charge additionnelle.'), findsOneWidget);
      }
      final total = find.text(
        '${NumberFormat.decimalPattern('fr_FR').format(result.totalCost.round())} FCFA',
      );
      await tester.ensureVisible(total.last);
      expect(total, findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('included charge is informative and disabled charge is hidden', (
    tester,
  ) async {
    final base = WoyofalTariffConfigurationFactory.dpp2026();
    final config = TariffConfiguration(
      name: base.name,
      customerCategory: base.customerCategory,
      billingMode: base.billingMode,
      tiers: base.tiers,
      effectiveFrom: base.effectiveFrom,
      effectiveTo: null,
      isActive: true,
      components: [
        const TariffComponent(
          name: 'Incluse',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: true,
        ),
        const TariffComponent(
          name: 'Désactivée',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 100,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
          enabled: false,
        ),
      ],
    );
    final result = const TariffEngineImpl().calculate(
      consumptionKwh: 100,
      configuration: config,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TariffCalculationDetails(result: result, configuration: config),
        ),
      ),
    );
    expect(find.text('Inclus dans le tarif'), findsOneWidget);
    expect(find.textContaining('Désactivée'), findsNothing);
    expect(result.totalCost, 8200);
    expect(find.text('0 FCFA'), findsOneWidget);
  });
}
