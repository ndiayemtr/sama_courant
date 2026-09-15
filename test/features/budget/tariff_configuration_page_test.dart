import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/presentation/pages/tariff_configuration_page.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('official configuration is readable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: TariffConfigurationPage(
          configuration: WoyofalTariffConfigurationFactory.dpp2026(),
        ),
      ),
    );
    expect(find.text('Woyofal DPP 2026'), findsOneWidget);
    expect(find.text('Depuis le 01/01/2026'), findsOneWidget);
    for (final label in [
      'Tranche 1',
      'Tranche 2',
      'Tranche 3',
      '0 à 150 kWh',
      '150 à 250 kWh',
      'Au-delà de 250 kWh',
      '82,00 FCFA/kWh',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('136,49 FCFA/kWh'), findsNWidgets(2));
    expect(find.text('TVA'), findsOneWidget);
    expect(find.text('18 %'), findsOneWidget);
    expect(find.text('Applicable au-delà de 250 kWh'), findsOneWidget);
    final basis = find.text(
      'Calculée sur le coût de l’énergie consommée au-delà du seuil.',
    );
    await tester.ensureVisible(basis);
    await tester.pumpAndSettle();
    expect(basis, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disabled components are hidden and included components identified',
    (tester) async {
      final base = WoyofalTariffConfigurationFactory.dpp2026();
      final configuration = TariffConfiguration(
        name: 'Configuration de test',
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
            name: 'Masquée',
            type: TariffComponentType.fee,
            calculationMethod: TariffCalculationMethod.fixed,
            value: 100,
            unit: 'FCFA',
            taxableBase: null,
            includedInTariff: false,
            enabled: false,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TariffConfigurationPage(configuration: configuration),
        ),
      );
      expect(find.text('Configuration de test'), findsOneWidget);
      expect(find.text('Incluse'), findsOneWidget);
      expect(find.text('Inclus dans le tarif'), findsOneWidget);
      expect(find.text('0,70 FCFA/kWh'), findsOneWidget);
      expect(find.text('Masquée'), findsNothing);
      expect(find.text('100 FCFA'), findsNothing);
    },
  );
}
