import '../entities/tariff_tier.dart';
import '../entities/tariff_tier_calculation.dart';

class TierCalculator {
  const TierCalculator();

  List<TariffTierCalculation> calculate({
    required double consumptionKwh,
    required List<TariffTier> tiers,
  }) {
    if (consumptionKwh <= 0 || tiers.isEmpty) {
      return [];
    }

    final sortedTiers = [...tiers]
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));

    var remainingKwh = consumptionKwh;
    final calculations = <TariffTierCalculation>[];

    for (final tier in sortedTiers) {
      if (remainingKwh <= 0) {
        break;
      }

      final tierMaxKwh = tier.maxKwh;

      final availableKwh = tierMaxKwh == null
          ? remainingKwh
          : tierMaxKwh - tier.minKwh;

      if (availableKwh <= 0) {
        continue;
      }

      final consumedKwh = remainingKwh < availableKwh
          ? remainingKwh
          : availableKwh;

      calculations.add(
        TariffTierCalculation(
          tierOrder: tier.tierOrder,
          consumedKwh: consumedKwh,
          pricePerKwh: tier.pricePerKwh,
          cost: consumedKwh * tier.pricePerKwh,
        ),
      );

      remainingKwh -= consumedKwh;
    }

    return calculations;
  }
}
