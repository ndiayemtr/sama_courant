import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/dashboard_provider.dart';

class ConsumptionDistributionCard extends StatelessWidget {
  final DashboardSummary summary;

  const ConsumptionDistributionCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = [
      colors.primary,
      colors.tertiary,
      colors.secondary,
      colors.primaryContainer,
      colors.tertiaryContainer,
      colors.secondaryContainer,
    ];
    final percentage = NumberFormat('0.0', 'fr_FR');
    final decimal = NumberFormat('0.00', 'fr_FR');
    final shares = summary.consumptionShares;
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition de la consommation',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text('Ce mois-ci', style: theme.textTheme.bodySmall),
            if (shares.isEmpty) ...[
              const SizedBox(height: 12),
              const Text('Aucune consommation à afficher.'),
              const SizedBox(height: 4),
              const Text(
                'Ajoutez ou activez un appareil pour voir sa répartition.',
              ),
            ] else ...[
              const SizedBox(height: 4),
              SizedBox(
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ExcludeSemantics(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 56,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                          pieTouchData: PieTouchData(enabled: false),
                          sections: [
                            for (var i = 0; i < shares.length; i++)
                              if (shares[i].consumptionKwh > 0)
                                PieChartSectionData(
                                  value: shares[i].consumptionKwh,
                                  color: palette[i],
                                  radius: 28,
                                  showTitle: false,
                                ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              decimal.format(summary.consumptionKwh),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('kWh/mois', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < shares.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: palette[i],
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shares[i].name,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percentage.format(shares[i].percentage)} %',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
