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

  /// Calcule la consommation électrique mensuelle d'un ensemble d'appareils en kilowattheures (kWh).
  ///
  /// [powerWatts] La puissance d'un appareil en Watts.
  /// [usageDurationMinutes] La durée d'une seule session d'utilisation en minutes.
  /// [usageCount] Le nombre de fois que l'appareil est utilisé par période de fréquence (ex: 2 fois par jour).
  /// [monthlyFrequencyMultiplier] Le coefficient multiplicateur pour ramener la fréquence à un mois (ex: 30 pour une fréquence quotidienne, 4.33 pour une fréquence hebdomadaire).
  /// [quantity] Le nombre total d'appareils identiques.
  static double calculateMonthlyConsumptionFromUsage({
    required double powerWatts,
    required int usageDurationMinutes,
    required int usageCount,
    required double monthlyFrequencyMultiplier,
    required int quantity,
  }) {
    final durationHours = usageDurationMinutes / 60.0;

    return (powerWatts *
            durationHours *
            usageCount *
            monthlyFrequencyMultiplier *
            quantity) /
        1000;
  }
}
