import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/features/dashboard/presentation/utils/appliance_chart_colors.dart';
import '../utils/appliance_chart_colors.dart';

import '../providers/dashboard_provider.dart';

class TopConsumersCard extends StatelessWidget {
  final DashboardSummary summary;

  const TopConsumersCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decimal = NumberFormat('0.00', 'fr_FR');
    final fcfa = NumberFormat.decimalPattern('fr_FR');
    // The distribution already contains the sorted top five, followed by Others.
    final consumers = summary.consumptionShares.take(5).toList();
    final maximum = consumers.isEmpty ? 0.0 : consumers.first.consumptionKwh;
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top consommateurs', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (consumers.isEmpty) ...[
              Text(
                summary.activeCount == 0
                    ? 'Aucun appareil actif à comparer.'
                    : 'Aucune consommation à comparer.',
              ),
            ] else ...[
              for (var i = 0; i < consumers.length; i++)
                Builder(
                  builder: (context) {
                    final consumer = consumers[i];
                    final color = ApplianceChartColors.forApplianceId(
                      consumer.applianceId,
                      consumer.name,
                    );

                    final consumption =
                        '${decimal.format(consumer.consumptionKwh)} kWh';

                    final cost =
                        '${fcfa.format(consumer.allocatedCostFcfa.round())} FCFA';

                    return Padding(
                      key: ValueKey('top-consumer-$i'),
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                key: ValueKey('top-consumer-color-$i'),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  consumer.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              children: [
                                Text(
                                  consumption,
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text('•', style: theme.textTheme.bodySmall),
                                Text(
                                  cost,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: LinearProgressIndicator(
                              value: maximum <= 0
                                  ? 0
                                  : consumer.consumptionKwh / maximum,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(6),
                              color: color,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              semanticsLabel:
                                  '${consumer.name} : consommation relative au plus gros consommateur',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
