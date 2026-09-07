class EnergyCalculator {
  EnergyCalculator._();

  /// Calcule la consommation énergétique pour une heure.
  ///
  /// Formule :
  /// puissance (W) / 1000
  static double calculateHourlyConsumption({
    required double powerWatts,
    required int quantity,
  }) {
    return (powerWatts * quantity) / 1000;
  }

  /// Calcule la consommation énergétique quotidienne.
  ///
  /// Formule :
  /// (puissance (W) × heures/jour × quantité) / 1000
  static double calculateDailyConsumption({
    required double powerWatts,
    required double hoursPerDay,
    required int quantity,
  }) {
    return (powerWatts * hoursPerDay * quantity) / 1000;
  }

  /// Calcule la consommation énergétique mensuelle.
  ///
  /// Formule :
  /// consommation quotidienne × jours/mois
  static double calculateMonthlyConsumption({
    required double powerWatts,
    required double hoursPerDay,
    required int daysPerMonth,
    required int quantity,
  }) {
    return calculateDailyConsumption(
          powerWatts: powerWatts,
          hoursPerDay: hoursPerDay,
          quantity: quantity,
        ) *
        daysPerMonth;
  }

  /// Calcule la consommation énergétique annuelle.
  ///
  /// Formule :
  /// consommation quotidienne × nombre de jours dans l'année
  static double calculateYearlyConsumption({
    required double powerWatts,
    required double hoursPerDay,
    required int quantity,
    int daysPerYear = 365,
  }) {
    return calculateDailyConsumption(
          powerWatts: powerWatts,
          hoursPerDay: hoursPerDay,
          quantity: quantity,
        ) *
        daysPerYear;
  }
}
