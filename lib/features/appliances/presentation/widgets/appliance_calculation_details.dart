import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../budget/domain/entities/tariff_calculation_method.dart';
import '../../../budget/domain/entities/tariff_calculation_result.dart';
import '../../../budget/domain/entities/tariff_configuration.dart';

/// Formats existing calculation results without recalculating any amounts.
class ApplianceCalculationDetails extends StatelessWidget {
  const ApplianceCalculationDetails({
    super.key,
    required this.result,
    required this.configuration,
    required this.householdConsumptionKwh,
    required this.monthlyConsumptionKwh,
    required this.contributionPercentage,
    required this.monthlyCostFcfa,
  });

  final TariffCalculationResult result;
  final TariffConfiguration configuration;
  final double householdConsumptionKwh;
  final double monthlyConsumptionKwh;
  final double contributionPercentage;
  final double monthlyCostFcfa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decimal = NumberFormat('0.00', 'fr_FR');
    final number = NumberFormat.decimalPattern('fr_FR');
    String money(double value) => '${number.format(value.round())} FCFA';
    String setting(double value, TariffCalculationMethod method) =>
        switch (method) {
          TariffCalculationMethod.percentage => '${number.format(value)} %',
          TariffCalculationMethod.perKwh => '${decimal.format(value)} FCFA/kWh',
          TariffCalculationMethod.fixed => money(value),
        };
    final components = [
      ...result.feeCalculations,
      ...result.taxCalculations,
    ].where((component) => component.enabled).toList();
    final included = configuration.components.where(
      (component) =>
          component.enabled &&
          component.includedInTariff &&
          !components.any(
            (detail) =>
                detail.includedInTariff && detail.name == component.name,
          ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tarif global du foyer (${decimal.format(householdConsumptionKwh)} kWh)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Détail des tranches d'énergie",
            style: theme.textTheme.titleSmall,
          ),
          for (final calculation in result.tierCalculations.where(
            (tier) => tier.consumedKwh > 0,
          ))
            Builder(
              builder: (context) {
                final matches = configuration.tiers.where(
                  (tier) => tier.tierOrder == calculation.tierOrder,
                );
                final tier = matches.isEmpty ? null : matches.first;
                final range = tier == null
                    ? 'Tranche ${calculation.tierOrder}'
                    : tier.maxKwh == null
                    ? 'Tranche > ${number.format(tier.minKwh)} kWh'
                    : 'Tranche ${number.format(tier.minKwh)} – ${number.format(tier.maxKwh)} kWh';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            range,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final amountWidth = (constraints.maxWidth * 0.34)
                                  .clamp(100.0, 125.0)
                                  .toDouble();

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${decimal.format(calculation.consumedKwh)} kWh × '
                                      '${decimal.format(calculation.pricePerKwh)} FCFA/kWh',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: amountWidth,
                                    child: Text(
                                      money(calculation.cost),
                                      textAlign: TextAlign.right,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          _AmountLine(
            label: 'Sous-total énergie',
            value: money(result.energyCost),
          ),
          for (final component in components)
            _AmountLine(
              label:
                  '${component.name} ${setting(component.value, component.calculationMethod)}',
              description: component.baseAmount == null
                  ? null
                  : 'Assiette : ${decimal.format(component.baseAmount)} ${component.calculationMethod == TariffCalculationMethod.perKwh ? 'kWh' : 'FCFA'}',
              value: component.includedInTariff
                  ? 'Inclus dans le tarif'
                  : money(component.amount),
            ),
          for (final component in included)
            _AmountLine(
              label:
                  '${component.name} ${setting(component.value, component.calculationMethod)}',
              value: 'Inclus dans le tarif',
            ),
          _AmountLine(
            label: 'Taxes et redevances',
            value: money(result.totalCharges),
          ),
          _AmountLine(
            label: 'Total estimé du foyer',
            value: money(result.totalCost),
            highlighted: true,
          ),
          const Divider(height: 24),
          Text(
            'Répartition pour cet appareil',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          _AmountLine(
            label: 'Consommation de l’appareil',
            value: '${decimal.format(monthlyConsumptionKwh)} kWh',
          ),
          _AmountLine(
            label: 'Part de consommation',
            value:
                '${NumberFormat('0.0', 'fr_FR').format(contributionPercentage)} %',
            accent: true,
          ),
          _AmountLine(
            label: 'Coût estimé de cet appareil',
            value: money(monthlyCostFcfa),
            highlighted: true,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.value,
    this.description,
    this.highlighted = false,
    this.accent = false,
  });
  final String label;
  final String value;
  final String? description;
  final bool highlighted;
  final bool accent;

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labelWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: highlighted ? FontWeight.w700 : null,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(description!, style: theme.textTheme.bodySmall),
        ],
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: highlighted ? 10 : 4,
      ),
      decoration: BoxDecoration(
        color: highlighted ? theme.colorScheme.surfaceContainerLow : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final valueWidth = (constraints.maxWidth * 0.38)
              .clamp(100.0, 132.0)
              .toDouble();

          // Sécurité uniquement pour des largeurs réellement très petites.
          if (constraints.maxWidth < 220) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent ? theme.colorScheme.primary : null,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: 12),
              SizedBox(
                width: valueWidth,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent ? theme.colorScheme.primary : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
