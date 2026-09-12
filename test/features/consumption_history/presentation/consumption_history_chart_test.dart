import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sama_courant/features/consumption_history/domain/entities/consumption_history_point.dart';
import 'package:sama_courant/features/consumption_history/presentation/widgets/consumption_history_chart.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  for (final count in [2, 4, 6, 8, 15]) {
    testWidgets('$count snapshots have limited date labels on mobile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final points = List.generate(
        count,
        (i) => ConsumptionHistoryPoint(
          capturedAt: DateTime(2026, 9, 11 + i, 9, 26),
          consumptionKwh: 55.5 + i,
          costFcfa: 0,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ConsumptionHistoryChart(points: points)),
        ),
      );
      await tester.pumpAndSettle();
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.lineBarsData.single.spots.length, count);
      expect(data.minY, 0);
      expect(data.lineBarsData.single.dotData.show, isTrue);
      expect(data.lineBarsData.single.belowBarData.show, isTrue);
      final labels = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d{2}/\d{2}$').hasMatch(widget.data ?? ''),
      );
      expect(
        labels,
        findsNWidgets(
          count <= 4
              ? count
              : count <= 8
              ? (count / 2).ceil()
              : 4,
        ),
      );
      final bar = data.lineBarsData.single;
      final tooltip = data.lineTouchData.touchTooltipData.getTooltipItems([
        LineBarSpot(bar, 0, bar.spots.first),
      ]).single!;
      expect(tooltip.text, '55,50 kWh\n11/09/2026 à 09:26');
      expect(data.lineTouchData.touchTooltipData.fitInsideHorizontally, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('same-day captures keep every point with one date label', (
    tester,
  ) async {
    final points = List.generate(
      4,
      (i) => ConsumptionHistoryPoint(
        capturedAt: DateTime(2026, 9, 11, 9, 26 + i),
        consumptionKwh: 55.5 + i,
        costFcfa: 0,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ConsumptionHistoryChart(points: points)),
      ),
    );
    await tester.pumpAndSettle();
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(find.text('11/09'), findsOneWidget);
    final bar = data.lineBarsData.single;
    expect(bar.spots.length, 4);
    expect(
      data.lineTouchData.touchTooltipData
          .getTooltipItems([LineBarSpot(bar, 0, bar.spots.last)])
          .single!
          .text,
      '58,50 kWh\n11/09/2026 à 09:29',
    );
    expect(tester.takeException(), isNull);
  });
}
