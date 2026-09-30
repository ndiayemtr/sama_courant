// extraction de W, kW, V, A et Hz.
import 'package:sama_courant/features/appliances/domain/entities/capacity_metric.dart';
import 'package:sama_courant/features/appliances/domain/entities/numeric_range.dart';
import '../entities/energy_consumption_basis.dart';
import '../entities/energy_consumption_metric.dart';

class ApplianceLabelParser {
  const ApplianceLabelParser();

  static final _secondaryPowerIndicator = RegExp(
    r'\b(defrost|deshielo|degivrage|heater|heating|chauffage|resistance|resistencia|standby|veille)\b',
  );
  static final _primaryPowerIndicator = RegExp(
    r'\b(rated power|rated input|power input|input power|nominal power|power consumption|power rating|input rating|total input|typical power|max power|maximum power|puissance nominale|puissance absorbee|potencia nominal|potencia de entrada|potencia absorbida|consumo nominal)\b',
  );

  // Rated > typical > unqualified > maximum. Secondary loads are excluded.
  double? extractPowerWatts(String text) {
    final candidates =
        extractPowerCandidates(text).where((c) => c.score >= 0).toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    if (candidates.isEmpty) return null;
    final best = candidates.first;
    if (candidates.any((c) => c.score == best.score && c.watts != best.watts)) {
      return null;
    }
    return best.watts;
  }

  List<PowerCandidate> extractPowerCandidates(String text) {
    final matches = RegExp(
      r'(?<![0-9.-])(\d+(?:\.\d+)?)\s*(kw|w)\b',
    ).allMatches(text).toList();
    // ML Kit can emit a column of labels before a column of values. With
    // exactly one wattage and no primary label, a remote secondary label is
    // enough to reject that wattage, but not to infer a main power value.
    final remoteSecondaryLines =
        matches.length == 1 && !_primaryPowerIndicator.hasMatch(text)
        ? text.split('\n').where(_secondaryPowerIndicator.hasMatch).toList()
        : const <String>[];
    final candidates = <PowerCandidate>[];
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final value = double.tryParse(match.group(1)!);
      if (value == null || !value.isFinite || value <= 0) continue;
      final previousEnd = i == 0 ? 0 : matches[i - 1].end;
      final lineStart = text.lastIndexOf('\n', match.start) + 1;
      final start = lineStart > previousEnd ? lineStart : previousEnd;
      final nextLine = text.indexOf('\n', match.end);
      final lineEnd = nextLine < 0 ? text.length : nextLine;
      final nextStart = i + 1 < matches.length
          ? matches[i + 1].start
          : text.length;
      var context = text.substring(start, match.end);
      if (nextStart >= lineEnd) {
        context += ' ${text.substring(match.end, lineEnd)}';
      }
      // A separate adjacent label can describe a bare wattage line.
      if (_powerContextScore(context) == 10 &&
          text.substring(lineStart, match.start).trim().isEmpty) {
        if (nextLine >= 0) {
          final following = text.substring(nextLine + 1).split('\n').first;
          if (!RegExp(r'\d').hasMatch(following)) context += ' $following';
        }
        if (lineStart > 0) {
          final preceding = text.substring(0, lineStart - 1).split('\n').last;
          if (!RegExp(r'\d').hasMatch(preceding)) {
            context = '$preceding $context';
          }
        }
      }
      if (remoteSecondaryLines.isNotEmpty) {
        context = '$context\n${remoteSecondaryLines.join('\n')}';
      }
      candidates.add(
        PowerCandidate(
          watts: match.group(2) == 'kw' ? value * 1000 : value,
          context: context.trim(),
          score: _powerContextScore(context),
        ),
      );
    }
    return List.unmodifiable(candidates);
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
    for (final metric in extractEnergyConsumptionMetrics(text)) {
      if (metric.basis == EnergyConsumptionBasis.perYear) {
        return metric.valueKwh;
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
    // Match labels separately from values so an empty/invalid candidate cannot
    // swallow another label. Prefer values explicitly on the same OCR line.
    final labels = [
      RegExp(r'\bmod[e3]l(?:e|o)?[ \t]+code\b'),
      RegExp(r'\bmod[e3]l(?:e|o)?\b(?![ \t]+(?:code|no|number|numero)\b)'),
      RegExp(r'\bmod[e3]l(?:e|o)?[ \t]+(?:no|number|numero)\b'),
      RegExp(r'\b(?:reference|ref)\b'),
    ];
    final valuePattern = RegExp(
      r'^[ \t]*\.?[ \t]*[:#-]?[ \t]*([a-z0-9][a-z0-9._/-]+)\b',
    );
    const reservedLabels = {
      'version',
      'serial',
      'type',
      'model',
      'modele',
      'modelo',
      'mod3l',
      'code',
      'number',
      'numero',
      'no',
      'sin',
      's/n',
      'sn',
      'reference',
      'ref',
    };

    for (final label in labels) {
      for (final match in label.allMatches(text)) {
        final valueMatch = valuePattern.firstMatch(text.substring(match.end));
        final model = valueMatch?.group(1);
        if (model == null) continue;
        final word = model.replaceAll(RegExp(r'[._/-]+$'), '');
        if (word.length < 2 || reservedLabels.contains(word)) continue;
        return model;
      }
      if (label == labels.first) {
        final preceding = _extractPrecedingModelCode(text, reservedLabels);
        if (preceding != null) return preceding;
      }
    }
    return _extractSequentialModel(text, labels, reservedLabels);
  }

  String? _extractPrecedingModelCode(String text, Set<String> reservedLabels) {
    final lines = text.split('\n').map((line) => line.trim()).toList();
    final emptyModelCode = RegExp(
      r'^mod[e3]l(?:e|o)?[ \t]+code[ \t]*\.?[ \t]*[:#]?[ \t]*$',
    );
    final precedingLabel = RegExp(
      r'^(?:model|modele|modelo|mod3l|serial|s/n|sn|sin|type|version|'
      r'reference|ref|voltage|volts|amps|watts|power|frequency|pressure|capacity)'
      r'\b.*$',
    );
    final candidates = <String>{};
    for (var i = 1; i < lines.length; i++) {
      if (!emptyModelCode.hasMatch(lines[i])) continue;
      final value = lines[i - 1];
      if (!_isPlausibleIdentityValue(value, reservedLabels) ||
          !RegExp(r'[a-z]').hasMatch(value) ||
          precedingLabel.hasMatch(value)) {
        continue;
      }
      // Do not steal a value from a preceding label or a grouped value run.
      if (i > 1 &&
          (precedingLabel.hasMatch(lines[i - 2]) ||
              _isPlausibleIdentityValue(lines[i - 2], reservedLabels))) {
        continue;
      }
      // Two neighbouring alphanumeric values give no reliable direction.
      if (i + 1 < lines.length &&
          _isPlausibleIdentityValue(lines[i + 1], reservedLabels) &&
          RegExp(r'[a-z]').hasMatch(lines[i + 1])) {
        continue;
      }
      candidates.add(value);
    }
    return candidates.length == 1 ? candidates.single : null;
  }

  bool _isPlausibleIdentityValue(String value, Set<String> reservedLabels) {
    final measurement = RegExp(
      r'^(?:ac|dc)?\d+(?:[._/-]\d+)*(?:vac|vdc|v|a|ma|w|kw|wh|kwh|hz|khz|'
      r'psi|psig|pa|kpa|mpa|bar|c|f|k|btu|btu/h|l|ml|kg|g|uf|ah)(?:ac|dc)?$',
    );
    return RegExp(r'^[a-z0-9][a-z0-9._/-]+$').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value) &&
        !reservedLabels.contains(value) &&
        !measurement.hasMatch(value) &&
        !RegExp(r'^r-?\d+[a-z]?$').hasMatch(value);
  }

  String? _extractSequentialModel(
    String text,
    List<RegExp> modelLabels,
    Set<String> reservedLabels,
  ) {
    final lines = text.split('\n').map((line) => line.trim()).toList();
    final identityLabel = RegExp(
      r'^(?:mod[e3]l(?:e|o)?(?:[ \t]+(?:code|no|number|numero))?'
      r'|serial(?:[ \t]+(?:no|number|numero))?|s/n|sn|sin'
      r'|type(?:[ \t]+no)?|version(?:[ \t]+no)?|reference|ref)'
      r'[ \t]*\.?[ \t]*[:#]?[ \t]*$',
    );
    bool plausible(String value) =>
        _isPlausibleIdentityValue(value, reservedLabels);

    final candidates = <String>{};
    for (var i = 0; i < lines.length; i++) {
      if (!identityLabel.hasMatch(lines[i])) continue;
      final start = i;
      while (i < lines.length && identityLabel.hasMatch(lines[i])) {
        i++;
      }
      final count = i - start;
      // Never slide past a missing or invalid value, or use part of a run.
      if (count < 2 || i + count > lines.length) continue;
      final values = lines.sublist(i, i + count);
      if (!values.every(plausible)) continue;
      if (i + count < lines.length && plausible(lines[i + count])) continue;
      final modelOffsets = <int>[
        for (var offset = 0; offset < count; offset++)
          if (modelLabels.any((label) => label.hasMatch(lines[start + offset])))
            offset,
      ];
      if (modelOffsets.length != 1) continue;
      final value = values[modelOffsets.single];
      // Numeric serials are valid slots, but never speculative models.
      if (RegExp(r'[a-z]').hasMatch(value)) candidates.add(value);
    }
    return candidates.length == 1 ? candidates.single : null;
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
        r'(?:/\s*|per\s+|par\s+|por\s+|\s+)'
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

    // kWh/100 cycles
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/\s*|per\s+|par\s+)'
        r'100\s*cycles?\b',
      ),
      EnergyConsumptionBasis.per100Cycles,
    );

    // kWh/1000 h
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/\s*|per\s+|par\s+)'
        r'1000\s*(?:h|hours?|heures?)\b',
      ),
      EnergyConsumptionBasis.per1000Hours,
    );

    // kWh/cycle
    addMatches(
      RegExp(
        r'(\d+(?:\.\d+)?)\s*kwh\s*'
        r'(?:/\s*|per\s+|par\s+)'
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

  int _powerContextScore(String context) {
    if (_secondaryPowerIndicator.hasMatch(context)) {
      return -1;
    }
    if (RegExp(r'\b(typical|typique)\b').hasMatch(context)) return 20;
    if (RegExp(r'\b(max|maximum|maxima|pmax)\b').hasMatch(context)) return 5;
    if (RegExp(
      r'\b(rated power|rated input|power input|input power|nominal power|power consumption|power consumed|consumption power|watts|puissance|p\. nominale|p\. absorbee|tot\. power|tot\. input|input pwr|rated pwr|p\.nom|pnom|potencia nominal|potencia de entrada|power rating|input rating|total input|potencia absorbida|consumo nominal)\b',
    ).hasMatch(context)) {
      return 30;
    }
    return 10;
  }
}

class PowerCandidate {
  final double watts;
  final String context;
  final int score;

  const PowerCandidate({
    required this.watts,
    required this.context,
    required this.score,
  });
}
