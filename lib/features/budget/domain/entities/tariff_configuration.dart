import 'billing_mode.dart';
import 'tariff_component.dart';
import 'tariff_tier.dart';

class TariffConfiguration {
  final int? id;
  final String name;
  final String customerCategory;
  final BillingMode billingMode;
  final List<TariffTier> tiers;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final List<TariffComponent> components;

  const TariffConfiguration({
    this.id,
    required this.name,
    required this.customerCategory,
    required this.billingMode,
    required this.tiers,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.isActive,
    required this.components,
  });
}
