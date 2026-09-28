// extraction de W, kW, V, A et Hz.
import 'package:sama_courant/features/appliances/domain/entities/capacity_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/numeric_range.dart';
import '../entities/energy_consumption_basis.dart';
import '../entities/energy_consumption_metric.dart';

class ApplianceLabelParser {
  const ApplianceLabelParser();
  double? extractPowerWatts(String text) {
    final match = RegExp(
      r'(?:^|[^0-9.-])(\d+(?:\.\d+)?)\s*(kw|w)\b',
    ).firstMatch(text);

    if (match == null) {
      return null;
    }

    final value = double.tryParse(match.group(1)!);
    final unit = match.group(2);

    if (value == null) {
      return null;
    }

    if (unit == 'kw') {
      return value * 1000;
    }

    return value;
  }

  double? extractVoltageVolts(String text) {
    return _extractValue(text, RegExp(r'(?:^|[^0-9.-])(\d+(?:\.\d+)?)\s*v\b'));
  }

  double? extractCurrentAmps(String text) {
    return _extractValue(text, RegExp(r'(?:^|[^0-9.-])(\d+(?:\.\d+)?)\s*a\b'));
  }

  double? extractFrequencyHz(String text) {
    return _extractValue(text, RegExp(r'(?:^|[^0-9.-])(\d+(?:\.\d+)?)\s*hz\b'));
  }

  double? _extractValue(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);

    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  NumericRange? extractVoltageRange(String text) {
    return _extractRange(
      text,
      RegExp(r'(?:^|[^0-9.])(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*v\b'),
    );
  }

  NumericRange? extractCurrentRange(String text) {
    return _extractRange(
      text,
      RegExp(r'(?:^|[^0-9.])(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*a\b'),
    );
  }

  List<double> extractFrequencyOptions(String text) {
    final match = RegExp(
      r'(?:^|[^0-9.])(\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)\s*hz\b',
    ).firstMatch(text);

    if (match == null) {
      return const [];
    }

    final first = double.tryParse(match.group(1)!);
    final second = double.tryParse(match.group(2)!);

    if (first == null || second == null) {
      return const [];
    }

    return [first, second];
  }

  NumericRange? _extractRange(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);

    if (match == null) {
      return null;
    }

    final first = double.tryParse(match.group(1)!);
    final second = double.tryParse(match.group(2)!);

    if (first == null || second == null) {
      return null;
    }

    return NumericRange(
      min: first < second ? first : second,
      max: first > second ? first : second,
    );
  }

  double? extractPowerFactor(String text) {
    final patterns = [
      RegExp(r'\bpower\s*factor\s*[:=]?\s*(\d+(?:\.\d+)?)\b'),
      RegExp(r'\bpf\s*[:=]?\s*(\d+(?:\.\d+)?)\b'),
      RegExp(r'\bcos\s*(?:phi)?\s*[:=]?\s*(\d+(?:\.\d+)?)\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match == null) {
        continue;
      }

      final value = double.tryParse(match.group(1)!);

      if (value != null && value > 0 && value <= 1) {
        return value;
      }
    }

    return null;
  }

  double? extractAnnualConsumptionKwh(String text) {
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*kwh\s*/\s*(?:year|yr|an|annee)\b'),
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s+(?:per|par)\s+'
        r'(?:year|yr|an|annee)\b',
      ),
      RegExp(
        r'annual\s+(?:energy\s+)?consumption\s*'
        r'(\d+(?:\.\d+)?)\s*kwh\b',
      ),
      RegExp(
        r'consommation\s+annuelle\s*'
        r'(\d+(?:\.\d+)?)\s*kwh\b',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match == null) {
        continue;
      }

      final value = double.tryParse(match.group(1)!);

      if (value != null && value > 0 && value.isFinite) {
        return value;
      }
    }

    return null;
  }

  String? extractCapacity(String text) {
    final patterns = [
      // Climatisation.
      RegExp(r'\b(\d+(?:\.\d+)?)\s*btu(?:/h)?\b'),

      // Réfrigérateur, chauffe-eau, etc.
      RegExp(r'\b(\d+(?:\.\d+)?)\s*(?:l|liter|litre|litres)\b'),

      // Machine à laver, sèche-linge, etc.
      RegExp(r'\b(\d+(?:\.\d+)?)\s*kg\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        return match.group(0);
      }
    }

    return null;
  }

  String? extractModel(String text) {
    final patterns = [
      RegExp(
        r'\bmodel\b\s*(?:no|number)?\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
      RegExp(
        r'\bmodele\b\s*(?:no|numero)?\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
      RegExp(r'\breference\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
      RegExp(r'\bref\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match == null) {
        continue;
      }

      final model = match.group(1)?.trim();

      if (model == null || model.length < 2) {
        continue;
      }

      return model;
    }

    return null;
  }

  String? extractBrand(String text) {
    final patterns = [
      RegExp(r'\bbrand\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
      RegExp(r'\bmarque\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
      RegExp(r'\bmanufacturer\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
      RegExp(r'\bfabricant\b\s*[:#-]?\s*([a-z0-9][a-z0-9._/-]{1,})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match == null) {
        continue;
      }

      final brand = match.group(1)?.trim();

      if (brand == null || brand.length < 2) {
        continue;
      }

      return brand;
    }

    return null;
  }

  List<EnergyConsumptionMetric> extractEnergyConsumptionMetrics(String text) {
    final metrics = <EnergyConsumptionMetric>[];

    void addMatches(RegExp pattern, EnergyConsumptionBasis basis) {
      for (final match in pattern.allMatches(text)) {
        final value = double.tryParse(match.group(1)!);

        if (value == null || !value.isFinite || value <= 0) {
          continue;
        }

        metrics.add(EnergyConsumptionMetric(valueKwh: value, basis: basis));
      }
    }

    // kWh/an, kWh/year, kWh/annum...
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+)'
        r'(?:year|yr|annum|an|annee)\b',
      ),
      EnergyConsumptionBasis.perYear,
    );

    // Ex. "annual consumption 216 kWh"
    addMatches(
      RegExp(
        r'(?:annual\s+(?:energy\s+)?consumption|'
        r'consommation\s+annuelle)\s*'
        r'[:=]?\s*(\d+(?:\.\d+)?)\s*kwh\b',
      ),
      EnergyConsumptionBasis.perYear,
    );

    // kWh/100 cycles
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+)'
        r'100\s*cycles?\b',
      ),
      EnergyConsumptionBasis.per100Cycles,
    );

    // kWh/1000 h
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+)'
        r'1000\s*(?:h|hours?|heures?)\b',
      ),
      EnergyConsumptionBasis.per1000Hours,
    );

    // kWh/cycle
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+)'
        r'cycles?\b',
      ),
      EnergyConsumptionBasis.perCycle,
    );

    return List.unmodifiable(metrics);
  }

  List<CapacityMetric> extractCapacities(String text) {
    final capacities = <CapacityMetric>[];

    final patterns = <RegExp, String>{
      RegExp(r'\b(\d+(?:\.\d+)?)\s*btu(?:/h)?\b'): 'btu',
      RegExp(r'\b(\d+(?:\.\d+)?)\s*(?:l|liter|litre|litres)\b'): 'l',
      RegExp(r'\b(\d+(?:\.\d+)?)\s*kg\b'): 'kg',
    };

    for (final entry in patterns.entries) {
      for (final match in entry.key.allMatches(text)) {
        final value = double.tryParse(match.group(1)!);

        if (value == null || !value.isFinite || value <= 0) {
          continue;
        }

        capacities.add(CapacityMetric(value: value, unit: entry.value));
      }
    }

    return List.unmodifiable(capacities);
  }
}
