import '../entities/tariff_configuration.dart';

class TariffConfigurationValidator {
  const TariffConfigurationValidator();

  List<String> validate(TariffConfiguration configuration) {
    final errors = <String>[];

    if (configuration.name.trim().isEmpty) {
      errors.add('Le nom de la configuration est obligatoire.');
    }

    if (configuration.customerCategory.trim().isEmpty) {
      errors.add('La catégorie client est obligatoire.');
    }

    if (configuration.tiers.isEmpty) {
      errors.add('La configuration doit contenir au moins une tranche.');
      return errors;
    }

    final sortedTiers = [...configuration.tiers]
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));

    for (var index = 0; index < sortedTiers.length; index++) {
      final tier = sortedTiers[index];

      if (tier.tierOrder <= 0) {
        errors.add('L\'ordre de la tranche doit être supérieur à zéro.');
      }

      if (tier.minKwh < 0) {
        errors.add('Le seuil minimum d\'une tranche ne peut pas être négatif.');
      }

      if (tier.maxKwh != null && tier.maxKwh! <= tier.minKwh) {
        errors.add('Le seuil maximum doit être supérieur au seuil minimum.');
      }

      if (tier.pricePerKwh < 0) {
        errors.add('Le prix par kWh ne peut pas être négatif.');
      }

      if (index > 0) {
        final previousTier = sortedTiers[index - 1];

        if (tier.tierOrder == previousTier.tierOrder) {
          errors.add('Deux tranches ne peuvent pas avoir le même ordre.');
        }

        if (previousTier.maxKwh != null && tier.minKwh != previousTier.maxKwh) {
          errors.add('Les tranches tarifaires doivent être continues.');
        }
      }
    }

    return errors;
  }

  bool isValid(TariffConfiguration configuration) {
    return validate(configuration).isEmpty;
  }
}
