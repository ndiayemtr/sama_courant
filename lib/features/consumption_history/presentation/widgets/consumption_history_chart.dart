import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/consumption_history_point.dart';

class ConsumptionHistoryChart extends StatefulWidget {
  final List<ConsumptionHistoryPoint> points;

  const ConsumptionHistoryChart({super.key, required this.points});

  @override
  State<ConsumptionHistoryChart> createState() =>
      _ConsumptionHistoryChartState();
}

class _ConsumptionHistoryChartState extends State<ConsumptionHistoryChart> {
  bool _showCost = true;
  List<ConsumptionHistoryPoint> get points => widget.points;
  double _value(ConsumptionHistoryPoint point) =>
      _showCost ? point.costFcfa : point.consumptionKwh;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final decimalFormatter = _showCost
        ? NumberFormat.decimalPattern('fr_FR')
        : NumberFormat('0.00', 'fr_FR');
    final unit = _showCost ? 'FCFA' : 'kWh';
    String formatted(double value) =>
        decimalFormatter.format(_showCost ? value.round() : value);
    final dateFormatter = DateFormat('dd/MM', 'fr_FR');
    final tooltipDateFormatter = DateFormat("dd/MM/yyyy 'à' HH:mm", 'fr_FR');

    final spots = points
        .asMap()
        .entries
        .map((point) => FlSpot(point.key.toDouble(), _value(point.value)))
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
      (maxValue, point) => _value(point) > maxValue ? _value(point) : maxValue,
    );

    final rawMaxY = maxConsumption <= 0 ? 1.0 : maxConsumption * 1.15;
    final yInterval = _horizontalInterval(rawMaxY);

    final maxY = math.max(yInterval, (rawMaxY / yInterval).ceil() * yInterval);

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
                    'Évolution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, label: Text('Coût')),
                ButtonSegment(value: false, label: Text('Consommation')),
              ],
              selected: {_showCost},
              onSelectionChanged: (selection) =>
                  setState(() => _showCost = selection.single),
            ),
            const SizedBox(height: 12),
            if (points.length == 1)
              _SinglePointHistory(
                point: points.first,
                formattedValue: '${formatted(_value(points.first))} $unit',
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        maxX: maxX,
                        minY: 0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
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
                              reservedSize: _showCost ? 64 : 46,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    formatted(value),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchSpotThreshold: 24,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipColor: (_) =>
                                Theme.of(context).colorScheme.inverseSurface,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final point = points[spot.spotIndex];

                                return LineTooltipItem(
                                  '${formatted(_value(point))} $unit\n'
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
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Touchez un point pour voir le détail',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  double _horizontalInterval(double maxY) {
    final target = maxY / 5;
    final magnitude = math
        .pow(10, (math.log(target) / math.ln10).floor())
        .toDouble();
    final scaled = target / magnitude;
    final step = scaled <= 1
        ? 1
        : scaled <= 2
        ? 2
        : scaled <= 5
        ? 5
        : 10;
    return math.max(_showCost ? 1.0 : 0.01, step * magnitude);
  }
}

class _SinglePointHistory extends StatelessWidget {
  final ConsumptionHistoryPoint point;
  final String formattedValue;

  const _SinglePointHistory({
    required this.point,
    required this.formattedValue,
  });

  @override
  Widget build(BuildContext context) {
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
            formattedValue,
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
