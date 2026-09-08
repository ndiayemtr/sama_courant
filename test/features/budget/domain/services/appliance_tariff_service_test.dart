import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';
import 'package:sama_courant/features/budget/domain/services/appliance_tariff_service.dart';

void main() {
  test('should calculate monthly cost from appliance consumption', () {
    const engine = TariffEngineImpl();

    const service = ApplianceTariffService(tariffEngine: engine);

    final appliance = Appliance(
      id: 1,
      name: 'Réfrigérateur',
      category: 'Cuisine',
      powerWatts: 100,
      quantity: 1,
      hoursPerDay: 10,
      daysPerMonth: 30,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final configuration = TariffConfiguration(
      name: 'Configuration test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = service.calculateMonthlyCost(
      appliance: appliance,
      configuration: configuration,
    );

    // 100 W × 10 h × 30 jours / 1000 = 30 kWh
    expect(result.consumptionKwh, 30);

    // 30 kWh × 82 FCFA = 2460 FCFA
    expect(result.energyCost, 2460);
    expect(result.fees, 0);
    expect(result.taxes, 0);
    expect(result.totalCost, 2460);
  });

  test('should preserve tariff breakdown', () {
    const engine = TariffEngineImpl();

    const service = ApplianceTariffService(tariffEngine: engine);

    final appliance = Appliance(
      name: 'Télévision',
      category: 'Salon',
      powerWatts: 100,
      quantity: 1,
      hoursPerDay: 5,
      daysPerMonth: 30,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final configuration = TariffConfiguration(
      name: 'Configuration test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 10, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 10, maxKwh: null, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = service.calculateMonthlyCost(
      appliance: appliance,
      configuration: configuration,
    );

    // 100 W × 5 h × 30 jours / 1000 = 15 kWh
    expect(result.consumptionKwh, 15);

    expect(result.tierCalculations.length, 2);

    expect(result.tierCalculations[0].consumedKwh, 10);
    expect(result.tierCalculations[0].cost, 820);

    expect(result.tierCalculations[1].consumedKwh, 5);
    expect(result.tierCalculations[1].cost, 682.45);

    expect(result.energyCost, 1502.45);
    expect(result.totalCost, 1502.45);
  });
}
