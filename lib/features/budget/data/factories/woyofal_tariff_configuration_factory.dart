import '../../domain/entities/billing_mode.dart';
import '../../domain/entities/tariff_configuration.dart';
import '../../domain/entities/tariff_tier.dart';

class WoyofalTariffConfigurationFactory {
  WoyofalTariffConfigurationFactory._();

  static TariffConfiguration dpp2026() {
    return TariffConfiguration(
      name: 'Woyofal DPP 2026',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 150, pricePerKwh: 82.00, tierOrder: 1),
        TariffTier(minKwh: 150, maxKwh: 250, pricePerKwh: 136.49, tierOrder: 2),
        TariffTier(
          minKwh: 250,
          maxKwh: null,
          pricePerKwh: 136.49,
          tierOrder: 3,
        ),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );
  }
}
