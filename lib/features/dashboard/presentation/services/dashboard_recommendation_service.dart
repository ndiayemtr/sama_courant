import 'package:intl/intl.dart';
import '../../../appliances/domain/entities/appliance.dart';

enum RecommendationPriority { high, medium, low }

class DashboardRecommendation {
  final String title;
  final String message;
  final RecommendationPriority priority;
  const DashboardRecommendation(this.title, this.message, this.priority);
}

class DashboardRecommendationService {
  const DashboardRecommendationService();

  List<DashboardRecommendation> generate({
    required List<Appliance> appliances,
    required double totalConsumptionKwh,
  }) {
    final active = appliances.where((a) => a.isActive).toList();
    if (active.isEmpty) {
      return const [
        DashboardRecommendation(
          'Pour commencer',
          'Ajoutez ou activez un appareil pour recevoir des conseils.',
          RecommendationPriority.low,
        ),
      ];
    }
    if (totalConsumptionKwh <= 0) {
      return const [
        DashboardRecommendation(
          'Consommation nulle',
          'Vérifiez le temps d’utilisation de vos appareils.',
          RecommendationPriority.low,
        ),
      ];
    }
    // Original position breaks ties deterministically, including duplicate names.
    final ordered = active.asMap().entries.toList()
      ..sort((a, b) {
        final comparison = b.value.monthlyConsumptionKwh.compareTo(
          a.value.monthlyConsumptionKwh,
        );
        return comparison != 0 ? comparison : a.key.compareTo(b.key);
      });
    final sorted = ordered.map((entry) => entry.value).toList();
    final percentage = NumberFormat('0.0', 'fr_FR');
    final number = NumberFormat('0.#', 'fr_FR');
    double share(Appliance a) =>
        a.monthlyConsumptionKwh / totalConsumptionKwh * 100;
    final recommendations = <DashboardRecommendation>[];
    final first = sorted.first;
    if (share(first) >= 70) {
      recommendations.add(
        DashboardRecommendation(
          first.name,
          '${percentage.format(share(first))} % de votre consommation. '
          'Vérifiez son temps d’utilisation.',
          RecommendationPriority.high,
        ),
      );
    } else if (sorted.length >= 2 && share(first) + share(sorted[1]) >= 80) {
      recommendations.add(
        DashboardRecommendation(
          'Deux appareils prioritaires',
          '${first.name} et ${sorted[1].name} : '
              '${percentage.format(share(first) + share(sorted[1]))} % du total. '
              'Vérifiez leur temps d’utilisation.',
          RecommendationPriority.high,
        ),
      );
    }
    // Significant groups: at least 30% of the household's active consumption.
    for (final a in sorted) {
      if (a.quantity > 1 && share(a) >= 30) {
        recommendations.add(
          DashboardRecommendation(
            a.name,
            '${a.quantity} unités • ${percentage.format(share(a))} % du total. '
            'Vérifiez si elles doivent toutes fonctionner.',
            RecommendationPriority.medium,
          ),
        );
      }
    }
    for (final a in sorted) {
      if (a.hoursPerDay >= 12 && a.monthlyConsumptionKwh > 0) {
        recommendations.add(
          DashboardRecommendation(
            a.name,
            '${number.format(a.hoursPerDay)} h/jour. '
            'Réduire cette durée peut diminuer la consommation.',
            RecommendationPriority.low,
          ),
        );
      }
    }
    if (recommendations.isEmpty) {
      recommendations.add(
        const DashboardRecommendation(
          'Répartition équilibrée',
          'Votre consommation est bien répartie.',
          RecommendationPriority.low,
        ),
      );
    }
    return List.unmodifiable(recommendations.take(3));
  }
}
