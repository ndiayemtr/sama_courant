import 'dart:convert';

import '../../domain/entities/energy_consumption_basis.dart';
import '../../domain/entities/energy_consumption_metric.dart';

class EnergyConsumptionMetricCodec {
  const EnergyConsumptionMetricCodec();

  String encode(List<EnergyConsumptionMetric> metrics) {
    return jsonEncode(
      metrics
          .map(
            (metric) => {
              'valueKwh': metric.valueKwh,
              'basis': metric.basis.name,
            },
          )
          .toList(),
    );
  }

  List<EnergyConsumptionMetric> decode(String? json) {
    if (json == null || json.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json);

    if (decoded is! List) {
      return const [];
    }

    final metrics = <EnergyConsumptionMetric>[];

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      final value = item['valueKwh'];
      final basisName = item['basis'];

      if (value is! num || basisName is! String) {
        continue;
      }

      EnergyConsumptionBasis basis;

      try {
        basis = EnergyConsumptionBasis.values.byName(basisName);
      } on ArgumentError {
        continue;
      }

      final valueKwh = value.toDouble();

      if (!valueKwh.isFinite || valueKwh <= 0) {
        continue;
      }

      metrics.add(EnergyConsumptionMetric(valueKwh: valueKwh, basis: basis));
    }

    return metrics;
  }
}
