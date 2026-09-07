import '../../features/budget/domain/entities/tariff_tier.dart';

class TariffCalculator {
  TariffCalculator._();

  /// Calcule le coût total d'une consommation en appliquant
  /// progressivement les différentes tranches tarifaires.
  ///
  /// Exemple :
  /// 250 kWh
  /// - tranche 1 : 100 kWh
  /// - tranche 2 : 100 kWh
  /// - tranche 3 : 50 kWh
  ///
  /// Retourne le coût total en FCFA.
  static double calculateCost({
    required double consumptionKwh,
    required List<TariffTier> tiers,
  }) {
    if (consumptionKwh <= 0 || tiers.isEmpty) {
      return 0;
    }

    final sortedTiers = [...tiers]
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));

    double remainingKwh = consumptionKwh;
    double totalCost = 0;

    for (final tier in sortedTiers) {
      if (remainingKwh <= 0) {
        break;
      }

      final tierCapacity = tier.maxKwh == null
          ? double.infinity
          : tier.maxKwh! - tier.minKwh;

      if (tierCapacity <= 0) {
        continue;
      }

      final kwhInTier = remainingKwh < tierCapacity
          ? remainingKwh
          : tierCapacity;

      totalCost += kwhInTier * tier.pricePerKwh;
      remainingKwh -= kwhInTier;
    }

    return totalCost;
  }
}
