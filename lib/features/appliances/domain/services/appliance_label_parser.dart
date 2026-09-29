// extraction de W, kW, V, A et Hz.
import 'package:sama_courant/features/appliances/domain/entities/capacity_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/numeric_range.dart';
import '../entities/energy_consumption_basis.dart';
import '../entities/energy_consumption_metric.dart';

class ApplianceLabelParser {
  const ApplianceLabelParser();
  double? extractPowerWatts(String text) {
    final pattern = RegExp(r'(?:^|[^0-9.-])(\d+(?:\.\d+)?)\s*(kw|w)\b');

    final matches = pattern.allMatches(text).toList();

    if (matches.isEmpty) {
      return null;
    }

    final hasSecondaryPowerIndicator = [
      'deshielo',
      'defrost',
      'degivrage',
      'heater',
      'heating',
      'chauffage',
      'resistance',
      'resistencia',
      'standby',
      'veille',
    ].any(text.contains);

    final hasPrimaryPowerIndicator = [
      'rated power',
      'rated input',
      'power input',
      'input power',
      'nominal power',
      'puissance nominale',
      'puissance absorbee',
      'potencia nominal',
      'potencia de entrada',
    ].any(text.contains);

    if (matches.length == 1 &&
        hasSecondaryPowerIndicator &&
        !hasPrimaryPowerIndicator) {
      return null;
    }

    _PowerCandidate? bestCandidate;

    for (final match in matches) {
      final rawValue = double.tryParse(match.group(1)!);
      final unit = match.group(2);

      if (rawValue == null || !rawValue.isFinite || rawValue <= 0) {
        continue;
      }

      final watts = unit == 'kw' ? rawValue * 1000 : rawValue;

      final context = _powerContext(text, match.start, match.end);

      final score = _powerContextScore(context);

      final candidate = _PowerCandidate(watts: watts, score: score);

      if (bestCandidate == null || candidate.score > bestCandidate.score) {
        bestCandidate = candidate;
      }
    }

    if (bestCandidate == null) {
      return null;
    }

    // Une puissance identifiée uniquement dans un contexte secondaire
    // ne doit pas devenir la puissance principale de l'appareil.
    if (bestCandidate.score < 0) {
      return null;
    }

    return bestCandidate.watts;
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
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+|por\s+|\s+)'
        r'(?:year|yr|annum|an|annee|ano)\b',
      ),
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s+(?:per|par|por)\s+'
        r'(?:year|yr|annum|an|annee|ano)\b',
      ),
      RegExp(
        r'annual\s+(?:energy\s+)?consumption\s*'
        r'(\d+(?:\.\d+)?)\s*kwh\b',
      ),
      RegExp(
        r'consommation\s+annuelle\s*'
        r'(\d+(?:\.\d+)?)\s*kwh\b',
      ),
      RegExp(
        r'consumo\s+de\s+energia(?:\s+en\s+operacion)?\s*'
        r'[:=]?\s*(\d+(?:\.\d+)?)\s*kwh\b',
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
      // Anglais — formes précises d'abord.
      // Ex. "MODEL NO.: AC-GEN-4500S"
      RegExp(
        r'\bmodel\b\s+(?:no|number)\b\.?\s*[:#-]?\s*'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),

      // Ex. "Model Code: UE55F6400ANXZF"
      RegExp(
        r'\bmodel\b\s+code\b\s*[:#-]?\s*'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),

      // Ex. "Model: UESSFG400A" ou "model rt38".
      RegExp(
        r'\bmodel\b\s*[:#-]?\s+'
        r'(?!no\b|number\b|code\b)'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),

      // Français.
      RegExp(
        r'\bmodele\b\s+(?:no|numero)\b\.?\s*[:#-]?\s*'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
      RegExp(
        r'\bmodele\b\s*[:#-]?\s+'
        r'(?!no\b|numero\b)'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),

      // Espagnol.
      RegExp(
        r'\bmodelo\b\s+(?:no|numero)\b\.?\s*[:#-]?\s*'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
      RegExp(
        r'\bmodelo\b\s*[:#-]?\s+'
        r'(?!no\b|numero\b)'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),

      // Référence explicite uniquement.
      RegExp(
        r'\breference\b\s*[:#-]?\s+'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
      RegExp(
        r'\bref\b\s*[:#-]?\s+'
        r'([a-z0-9][a-z0-9._/-]{1,})\b',
      ),
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

    const knownBrands = [
      'samsung',
      'lg',
      'hisense',
      'haier',
      'bosch',
      'beko',
      'whirlpool',
      'electrolux',
      'midea',
      'sharp',
      'panasonic',
      'philips',
      'sony',
      'tcl',
      'daikin',
      // Marques majeures / Premium
      'miele',
      'siemens',
      'aeg',
      'smeg',
      'gorenje',
      'candy',
      'indesit',
      'hotpoint',
      'zanussi',
      'rowenta',
      // Traitement de l'air & Chauffage (Climatiseurs, chauffe-eau)
      'mitsubishi',
      'carrier',
      'gree',
      'toshiba',
      'fujitsu',
      'atlantic',
      'saunier duval',
      'chaffoteaux',
      // Petit électroménager courant (Cuisine / Entretien)
      'moulinex',
      'tefal',
      'braun',
      'kenwood',
      'delonghi',
      'krups',
      'dyson',
      'taurus',
    ];

    for (final brand in knownBrands) {
      final pattern = RegExp(
        r'(^|[^a-z0-9])' + RegExp.escape(brand) + r'([^a-z0-9]|$)',
      );

      if (pattern.hasMatch(text)) {
        return brand;
      }
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

        final alreadyExists = metrics.any(
          (metric) => metric.valueKwh == value && metric.basis == basis,
        );

        if (alreadyExists) {
          continue;
        }

        metrics.add(EnergyConsumptionMetric(valueKwh: value, basis: basis));
      }
    }

    // kWh/an, kWh/year, kWh/annum...
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/|per\s+|par\s+|por\s+)'
        r'(?:year|yr|annum|an|annee|ano)\b',
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

    // Ex. "consumo de energia en operacion 355 kWh"
    addMatches(
      RegExp(
        r'(?:consumo\s+de\s+energia(?:\s+en\s+operacion)?)\s*'
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

  String _powerContext(String text, int matchStart, int matchEnd) {
    const charsBefore = 40;

    final start = matchStart - charsBefore < 0 ? 0 : matchStart - charsBefore;

    return text.substring(start, matchEnd);
  }

  int _powerContextScore(String context) {
    var score = 0;

    const primaryIndicators = [
      'rated power',
      'rated input',
      'power input',
      'input power',
      'nominal power',
      'puissance nominale',
      'puissance absorbee',
      'potencia nominal',
      'potencia de entrada',

      // --- Variantes en Français (avec et sans accents pour l'OCR) ---
      'puissance',
      'puissance absorbée',
      'puissance d\'entrée',
      'puissance max',
      'puissance maximum',
      'p. nominale',
      'p. absorbée',
      'p. absorbee',
      'puissance de raccordement',

      // --- Variantes en Anglais ---
      'power rating',
      'max power',
      'maximum power',
      'input rating',
      'total input',
      'power consum', // Coupe pour matcher "power consumption" ou "power consumed"
      'consumption power',

      // --- Variantes en Espagnol / Portugais ---
      'potência nominal',
      'potência máxima',
      'potencia maxima',
      'potência de entrada',
      'potencia absorbida',
      'consumo nominal',

      // --- Abréviations techniques universelles (Plaques signalétiques) ---
      'tot. power',
      'tot. input',
      'input pwr',
      'rated pwr',
      'p.max',
      'pmax',
      'p.nom',
      'pnom',
    ];

    const secondaryIndicators = [
      'deshielo',
      'defrost',
      'degivrage',
      'heater',
      'heating',
      'chauffage',
      'resistance',
      'resistencia',
      'standby',
      'veille',
    ];

    for (final indicator in primaryIndicators) {
      if (context.contains(indicator)) {
        score += 10;
      }
    }

    for (final indicator in secondaryIndicators) {
      if (context.contains(indicator)) {
        score -= 20;
      }
    }

    return score;
  }
}

class _PowerCandidate {
  final double watts;
  final int score;

  const _PowerCandidate({required this.watts, required this.score});
}
