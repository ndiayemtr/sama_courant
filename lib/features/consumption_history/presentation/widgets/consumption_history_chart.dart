import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/consumption_history_point.dart';

class ConsumptionHistoryChart extends StatelessWidget {
  final List<ConsumptionHistoryPoint> points;

  const ConsumptionHistoryChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    final dateFormatter = DateFormat('dd/MM', 'fr_FR');
    final tooltipDateFormatter = DateFormat("dd/MM/yyyy 'à' HH:mm", 'fr_FR');

    final spots = points
        .asMap()
        .entries
        .map(
          (point) => FlSpot(point.key.toDouble(), point.value.consumptionKwh),
        )
        .toList(growable: false);

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final labelStep = points.length <= 4
        ? 1
        : points.length <= 8
        ? 2
        : ((points.length - 1) / 4).ceil();
    final labels = <int, String>{};
    for (var index = 0; index < points.length; index += labelStep) {
      final label = dateFormatter.format(points[index].capturedAt);
      if (labels.isEmpty || labels.values.last != label) {
        labels[index] = label;
      }
    }

    final maxConsumption = points.fold<double>(
      0,
      (maxValue, point) =>
          point.consumptionKwh > maxValue ? point.consumptionKwh : maxValue,
    );

    final maxY = maxConsumption <= 0 ? 1.0 : maxConsumption * 1.15;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Évolution de la consommation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Estimations enregistrées',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (points.length == 1)
              _SinglePointHistory(point: points.first)
            else
              SizedBox(
                height: 210,
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _horizontalInterval(maxY),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          interval: _horizontalInterval(maxY),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                decimalFormatter.format(value),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final label = labels[value.toInt()];
                            if (value != value.toInt() || label == null) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              fitInside: SideTitleFitInsideData(
                                enabled: true,
                                axisPosition: meta.axisPosition,
                                parentAxisSize: meta.parentAxisSize,
                                distanceFromEdge: 0,
                              ),
                              child: Text(
                                label,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (_) =>
                            Theme.of(context).colorScheme.inverseSurface,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final point = points[spot.spotIndex];

                            return LineTooltipItem(
                              '${decimalFormatter.format(point.consumptionKwh)} kWh\n'
                              '${tooltipDateFormatter.format(point.capturedAt)}',
                              TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: points.length > 2,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primaryContainer
                              .withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Consommation mensuelle estimée (kWh)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _horizontalInterval(double maxY) {
    if (maxY <= 10) {
      return 2;
    }

    if (maxY <= 50) {
      return 10;
    }

    if (maxY <= 100) {
      return 20;
    }

    return maxY / 5;
  }
}

class _SinglePointHistory extends StatelessWidget {
  final ConsumptionHistoryPoint point;

  const _SinglePointHistory({required this.point});

  @override
  Widget build(BuildContext context) {
    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    final dateFormatter = DateFormat("dd/MM/yyyy 'à' HH:mm", 'fr_FR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            '${decimalFormatter.format(point.consumptionKwh)} kWh',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormatter.format(point.capturedAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Enregistrez au moins deux états pour visualiser une évolution.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
