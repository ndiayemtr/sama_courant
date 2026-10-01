import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/presentation/widgets/appliance_card.dart';

void main() {
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
    expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
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
}
