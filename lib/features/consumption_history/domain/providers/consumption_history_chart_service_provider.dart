import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/consumption_history_chart_service.dart';

final consumptionHistoryChartServiceProvider =
    Provider<ConsumptionHistoryChartService>((ref) {
      return const ConsumptionHistoryChartService();
    });
