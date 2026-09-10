import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              Text(
                'Comparaison au plus gros consommateur',
                style: theme.textTheme.bodySmall,
              ),
              for (var i = 0; i < consumers.length; i++)
                Padding(
                  key: ValueKey('top-consumer-$i'),
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final name = Text(
                            consumers[i].name,
                            style: theme.textTheme.bodyMedium,
                          );
                          final consumption =
                              '${decimal.format(consumers[i].consumptionKwh)} kWh';
                          final cost =
                              '${fcfa.format(consumers[i].allocatedCostFcfa.round())} FCFA';
                          final valueStyle = theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600);
                          final namePainter = TextPainter(
                            text: TextSpan(
                              text: consumers[i].name,
                              style: theme.textTheme.bodyMedium,
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout();
                          final valuePainter = TextPainter(
                            text: TextSpan(
                              text: '$consumption / $cost',
                              style: valueStyle,
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout();
                          final fits =
                              namePainter.width + 12 + valuePainter.width <=
                              constraints.maxWidth;
                          namePainter.dispose();
                          valuePainter.dispose();
                          if (fits) {
                            return Row(
                              children: [
                                Expanded(child: name),
                                const SizedBox(width: 12),
                                Text(
                                  '$consumption / $cost',
                                  style: valueStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              name,
                              const SizedBox(height: 2),
                              Text('$consumption • $cost', style: valueStyle),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: maximum <= 0
                            ? 0
                            : consumers[i].consumptionKwh / maximum,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        semanticsLabel:
                            '${consumers[i].name} : consommation relative au plus gros consommateur',
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
