import '../entities/appliance_label_type.dart';

class ApplianceLabelTypeDetector {
  const ApplianceLabelTypeDetector();

  ApplianceLabelType detect(String normalizedText) {
    final technicalScore = _technicalScore(normalizedText);
    final energyScore = _energyScore(normalizedText);

    if (technicalScore == 0 && energyScore == 0) {
      return ApplianceLabelType.unknown;
    }

    if (technicalScore > 0 && energyScore > 0) {
      return ApplianceLabelType.mixed;
    }

    if (energyScore > 0) {
      return ApplianceLabelType.energyLabel;
    }

    return ApplianceLabelType.technicalPlate;
  }

  int _technicalScore(String text) {
    var score = 0;

    final indicators = [
      RegExp(r'\b\d+(?:\.\d+)?\s*w\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*kw\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*v\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*a\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*hz\b'),
      RegExp(r'\bpf\s*\d'),
      RegExp(r'\bpower factor\b'),
    ];

    for (final indicator in indicators) {
      if (indicator.hasMatch(text)) {
        score++;
      }
    }

    return score;
  }

  int _energyScore(String text) {
    var score = 0;

    final indicators = [
      RegExp(r'\b\d+(?:\.\d+)?\s*kwh\b'),
      RegExp(r'\benergy class\b'),
      RegExp(r'\bclasse energetique\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*db\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*l\b'),
      RegExp(r'\b\d+(?:\.\d+)?\s*kg\b'),
    ];

    for (final indicator in indicators) {
      if (indicator.hasMatch(text)) {
        score++;
      }
    }

    return score;
  }
}
