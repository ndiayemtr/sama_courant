import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/core/presentation/utils/appliance_colors.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/presentation/widgets/appliance_card.dart';

void main() {
  for (final width in [320.0, 360.0, 390.0, 800.0]) {
    testWidgets('accents stables et absence de débordement à $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final theme = ThemeData(useMaterial3: true);
      for (final id in [7, 12, null]) {
        // Le badge présente déjà un overflow mobile (tests de page existants).
        for (final highlighted in width == 800 ? [false, true] : [false]) {
          final appliance = Appliance(
            id: id,
            name: 'Ancien appareil au nom long',
            category: 'Cuisine',
            powerWatts: 100,
            quantity: 1,
            hoursPerDay: 2,
            daysPerMonth: 30,
            isActive: true,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          );
          final color = ApplianceChartColors.forApplianceId(id, appliance.name);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ApplianceCard(
                    appliance: appliance,
                    monthlyCostFcfa: 1000,
                    contributionPercentage: 42,
                    isMostConsuming: highlighted,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final entry in {
            Icons.schedule_outlined: theme.colorScheme.primary,
            Icons.bolt: Colors.green,
            Icons.monetization_on: Colors.orange,
            Icons.electrical_services_outlined: color,
          }.entries) {
            expect(
              tester.widget<Icon>(find.byIcon(entry.key)).color,
              entry.value,
            );
          }
          final progress = tester.widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
          expect(progress.valueColor?.value, color);
          expect(progress.value, 0.42);
          expect(find.text('1 000 FCFA'), findsOneWidget);
          expect(
            tester.widget<Text>(find.text('1 000 FCFA')).style?.color,
            Colors.orange,
          );
          for (final value in ['2 h/jour', '6,00 kWh']) {
            expect(
              tester.widget<Text>(find.text(value)).style?.color,
              theme.colorScheme.onSurface,
            );
          }
          if (highlighted) {
            expect(
              tester.widget<Icon>(find.byIcon(Icons.bar_chart)).color,
              theme.colorScheme.onErrorContainer,
            );
            expect(find.text('Plus énergivore'), findsOneWidget);
          }
        }
      }
    });
  }

  testWidgets('affiche le libellé français du type technique', (tester) async {
    final appliance = Appliance(
      name: 'Bosch KGN36',
      category: 'refrigerator',
      powerWatts: 150,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 480,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplianceCard(appliance: appliance, monthlyCostFcfa: 5000),
        ),
      ),
    );

    expect(find.text('Réfrigérateur'), findsOneWidget);
    expect(find.text('refrigerator'), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/appliances/refrigerator.jpg',
    );
  });

  testWidgets('préserve une catégorie legacy inconnue', (tester) async {
    final appliance = Appliance(
      name: 'Ancien appareil',
      category: 'Cuisine',
      powerWatts: 100,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 60,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplianceCard(appliance: appliance, monthlyCostFcfa: 1000),
        ),
      ),
    );

    expect(find.text('Cuisine'), findsOneWidget);
    expect(find.byIcon(Icons.electrical_services_outlined), findsOneWidget);
  });

  testWidgets('utilise applianceType en priorité sur la catégorie', (
    tester,
  ) async {
    final appliance = Appliance(
      name: 'Samsung UE55F6400AW',
      category: 'Autre',
      applianceType: 'television',
      powerWatts: 75,
      quantity: 1,
      hoursPerDay: 0,
      daysPerMonth: 30,
      usageDurationMinutes: 334,
      usageCount: 1,
      usageFrequency: UsageFrequency.daily,
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplianceCard(appliance: appliance, monthlyCostFcfa: 1027),
        ),
      ),
    );

    expect(find.text('Téléviseur'), findsOneWidget);
    expect(find.text('Autre'), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/appliances/television.jpg',
    );
  });
}
