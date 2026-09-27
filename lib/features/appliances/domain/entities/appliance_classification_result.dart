import 'confidence_level.dart';

class ApplianceClassificationResult {
  final String? category;
  final ConfidenceLevel confidenceLevel;
  final int score;
  final List<String> matchedKeywords;

  const ApplianceClassificationResult({
    required this.category,
    required this.confidenceLevel,
    required this.score,
    this.matchedKeywords = const [],
  });

  bool get isRecognized => category != null;
}
