import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/tariff_calculation_result.dart';
import '../../domain/entities/tariff_calculation_method.dart';
import '../../domain/entities/tariff_configuration.dart';

/// Displays a calculation and the configuration used to produce it.
class TariffCalculationDetails extends StatelessWidget {
  final TariffCalculationResult result;
  final TariffConfiguration configuration;
  const TariffCalculationDetails({
    super.key,
    required this.result,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
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
    ].where((c) => c.enabled).toList();
    final included = configuration.components.where(
      (c) => c.enabled && c.includedInTariff,
    );
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détail du calcul',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text('Énergie', style: titleStyle),
        for (final calculation in result.tierCalculations.where(
          (t) => t.consumedKwh > 0,
        ))
          Builder(
            builder: (context) {
              final matches = configuration.tiers.where(
                (t) => t.tierOrder == calculation.tierOrder,
              );
              final tier = matches.isEmpty ? null : matches.first;
              final range = tier == null
                  ? 'Tranche ${calculation.tierOrder}'
                  : tier.maxKwh == null
                  ? '>${number.format(tier.minKwh)} kWh'
                  : '${number.format(tier.minKwh)}–${number.format(tier.maxKwh)} kWh';
              return _DetailRow(
                label: range,
                description:
                    '${decimal.format(calculation.consumedKwh)} kWh × ${decimal.format(calculation.pricePerKwh)} FCFA/kWh',
                value: money(calculation.cost),
              );
            },
          ),
        const SizedBox(height: 8),
        Text('Taxes et redevances', style: titleStyle),
        if (components.isEmpty && included.isEmpty)
          const Text('Aucune charge additionnelle.'),
        for (final component in components)
          _DetailRow(
            label:
                '${component.name} ${setting(component.value, component.calculationMethod)}',
            description: component.baseAmount == null
                ? null
                : 'Assiette : ${decimal.format(component.baseAmount)} ${component.calculationMethod == TariffCalculationMethod.perKwh ? 'kWh' : 'FCFA'}',
            value: component.includedInTariff
                ? 'Inclus dans le tarif'
                : money(component.amount),
          ),
        for (final component in included.where(
          (c) => !components.any((d) => d.includedInTariff && d.name == c.name),
        ))
          _DetailRow(
            label:
                '${component.name} ${setting(component.value, component.calculationMethod)}',
            value: 'Inclus dans le tarif',
          ),
        const Divider(),
        _DetailRow(
          label: 'Sous-total énergie',
          value: money(result.energyCost),
        ),
        _DetailRow(
          label: 'Taxes / redevances',
          value: money(result.totalCharges),
        ),
        _DetailRow(
          label: 'Total estimé',
          value: money(result.totalCost),
          emphasize: true,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? description;
  final String value;
  final bool emphasize;
  const _DetailRow({
    required this.label,
    required this.value,
    this.description,
    this.emphasize = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              if (description != null)
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
