/// Instantané d'une estimation issue des appareils actifs configurés.
/// Ne représente pas une mesure réelle de compteur.
class ConsumptionSnapshot {
  final int? id;

  /// Date et heure de capture de l'estimation.
  final DateTime capturedAt;
  final double totalMonthlyConsumptionKwh;
  final double totalMonthlyCostFcfa;
  final int activeAppliancesCount;
  final String tariffConfigurationName;

  /// Date de création technique du snapshot, distincte de la capture.
  final DateTime createdAt;

  const ConsumptionSnapshot({
    this.id,
    required this.capturedAt,
    required this.totalMonthlyConsumptionKwh,
    required this.totalMonthlyCostFcfa,
    required this.activeAppliancesCount,
    required this.tariffConfigurationName,
    required this.createdAt,
  });
}
