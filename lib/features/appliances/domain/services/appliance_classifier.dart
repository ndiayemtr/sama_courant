import '../constants/appliance_keywords.dart';
import '../entities/appliance_classification_result.dart';
import '../entities/confidence_level.dart';

class ApplianceClassifier {
  const ApplianceClassifier();

  ApplianceClassificationResult classify(String normalizedText) {
    final scores = <String, int>{};
    final matches = <String, List<String>>{};

    void applyKeywords(Map<String, List<String>> source, int weight) {
      for (final entry in source.entries) {
        for (final keyword in entry.value) {
          if (_containsKeyword(normalizedText, keyword)) {
            scores.update(
              entry.key,
              (value) => value + weight,
              ifAbsent: () => weight,
            );

            matches.putIfAbsent(entry.key, () => []);
            if (!matches[entry.key]!.contains(keyword)) {
              matches[entry.key]!.add(keyword);
            }
          }
        }
      }
    }

    applyKeywords(strongKeywords, 5);
    applyKeywords(technicalIndicators, 2);
    applyKeywords(weakKeywords, 1);

    if (scores.isEmpty) {
      return const ApplianceClassificationResult(
        category: null,
        confidenceLevel: ConfidenceLevel.low,
        score: 0,
      );
    }

    final highestScore = scores.values.reduce(
      (current, next) => current > next ? current : next,
    );

    if (highestScore < 3) {
      return ApplianceClassificationResult(
        category: null,
        confidenceLevel: ConfidenceLevel.low,
        score: highestScore,
      );
    }

    final bestCategories = scores.entries
        .where((entry) => entry.value == highestScore)
        .map((entry) => entry.key)
        .toList();

    if (bestCategories.length != 1) {
      return ApplianceClassificationResult(
        category: null,
        confidenceLevel: ConfidenceLevel.low,
        score: highestScore,
      );
    }

    final category = bestCategories.single;

    return ApplianceClassificationResult(
      category: category,
      confidenceLevel: _confidenceFromScore(highestScore),
      score: highestScore,
      matchedKeywords: List.unmodifiable(matches[category] ?? const []),
    );
  }

  bool _containsKeyword(String text, String keyword) {
    final escaped = RegExp.escape(keyword);

    final pattern = RegExp(r'(^|[^a-z0-9])' + escaped + r'([^a-z0-9]|$)');

    return pattern.hasMatch(text);
  }

  ConfidenceLevel _confidenceFromScore(int score) {
    if (score >= 5) {
      return ConfidenceLevel.high;
    }

    if (score >= 3) {
      return ConfidenceLevel.medium;
    }

    return ConfidenceLevel.low;
  }
}
