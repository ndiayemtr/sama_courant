import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/dashboard_provider.dart';

class ConsumptionDistributionCard extends StatefulWidget {
  final DashboardSummary summary;

  const ConsumptionDistributionCard({super.key, required this.summary});

  @override
  State<ConsumptionDistributionCard> createState() =>
      _ConsumptionDistributionCardState();
}

class _ConsumptionDistributionCardState
    extends State<ConsumptionDistributionCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant ConsumptionDistributionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A refreshed distribution can reorder or remove the selected appliance.
    if (oldWidget.summary.consumptionShares !=
        widget.summary.consumptionShares) {
      _selectedIndex = null;
    }
  }

  void _select(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

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
    final shares = widget.summary.consumptionShares;
    final selected = _selectedIndex == null ? null : shares[_selectedIndex!];
    // fl_chart indexes only the rendered (positive) sections.
    final visibleIndices = [
      for (var i = 0; i < shares.length; i++)
        if (shares[i].consumptionKwh > 0) i,
    ];
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
                height: 128,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ExcludeSemantics(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 60,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (event is! FlTapUpEvent) return;
                              final index =
                                  response?.touchedSection?.touchedSectionIndex;
                              if (index != null &&
                                  index >= 0 &&
                                  index < visibleIndices.length) {
                                _select(visibleIndices[index]);
                              }
                            },
                          ),
                          sections: [
                            for (final i in visibleIndices)
                              PieChartSectionData(
                                value: shares[i].consumptionKwh,
                                color: palette[i],
                                radius: _selectedIndex == i ? 22 : 16,
                                showTitle: false,
                              ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 120),
                      ),
                    ),
                    IgnorePointer(
                      child: SizedBox(
                        width: 72,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                decimal.format(widget.summary.consumptionKwh),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text('kWh/mois', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected != null)
                Semantics(
                  liveRegion: true,
                  child: Padding(
                    key: const ValueKey('consumption-selection'),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodySmall!,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 1,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Sélection :'),
                          Text(
                            selected.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Text('•'),
                          Text(
                            '${decimal.format(selected.consumptionKwh)} kWh/mois',
                          ),
                          const Text('•'),
                          Text('${percentage.format(selected.percentage)} %'),
                        ],
                      ),
                    ),
                  ),
                ),
              for (var i = 0; i < shares.length; i++)
                Semantics(
                  button: true,
                  selected: _selectedIndex == i,
                  child: InkWell(
                    key: ValueKey('consumption-legend-$i'),
                    onTap: () => _select(i),
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: palette[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                shares[i].name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: _selectedIndex == i
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.format(shares[i].percentage)} %',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedIndex == i) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.check, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
