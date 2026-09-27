// extraction de W, kW, V, A et Hz.
class ApplianceLabelParser {
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
}
