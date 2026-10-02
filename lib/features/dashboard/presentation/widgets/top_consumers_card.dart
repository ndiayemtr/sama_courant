import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/features/dashboard/presentation/utils/appliance_chart_colors.dart';

import '../providers/dashboard_provider.dart';
import '../../../appliances/presentation/models/appliance_visual.dart';

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

                    final visual = ApplianceVisualCatalog.resolve(
                      consumer.applianceType ?? consumer.category!,
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
                                key: ValueKey('top-consumer-visual-$i'),
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: visual.assetPath != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Image.asset(
                                          visual.assetPath!,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Icon(
                                        visual.icon,
                                        size: 28,
                                        color: theme.colorScheme.primary,
                                      ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      consumer.name,

                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          consumption,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          '•',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          cost,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 62),
                            child: LinearProgressIndicator(
                              value: (consumer.percentage / 100).clamp(
                                0.0,
                                1.0,
                              ),
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
