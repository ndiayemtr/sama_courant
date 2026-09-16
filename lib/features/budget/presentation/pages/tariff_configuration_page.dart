import '../../../../core/widgets/page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/tariff_configuration.dart';
import '../../domain/entities/tariff_calculation_method.dart';
import '../../domain/entities/tariff_taxable_base.dart';

class TariffConfigurationPage extends StatelessWidget {
  final TariffConfiguration configuration;
  const TariffConfigurationPage({super.key, required this.configuration});

  @override
  Widget build(BuildContext context) {
    final decimal = NumberFormat('0.00', 'fr_FR');
    final number = NumberFormat.decimalPattern('fr_FR');
    final date = DateFormat('dd/MM/yyyy', 'fr_FR');
    final tiers = [...configuration.tiers]
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));
    final components = configuration.components
        .where((c) => c.enabled)
        .toList();
    return Scaffold(
      appBar: pageAppBar(context: context, title: 'Tarification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tarification utilisée pour vos estimations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _Section(
              title: configuration.isActive
                  ? 'Configuration active'
                  : 'Configuration inactive',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        configuration.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (configuration.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  'Depuis le ${date.format(configuration.effectiveFrom)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (configuration.effectiveTo != null)
                  Text(
                    'Fin d’application : ${date.format(configuration.effectiveTo!)}',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Tranches',
              children: [
                for (final tier in tiers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tranche ${tier.tierOrder}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Text(
                                tier.maxKwh == null
                                    ? 'Au-delà de ${number.format(tier.minKwh)} kWh'
                                    : '${number.format(tier.minKwh)} à ${number.format(tier.maxKwh)} kWh',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${decimal.format(tier.pricePerKwh)} FCFA/kWh',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (tier != tiers.last) const Divider(height: 10),
                      ],
                    ),
                  ),
              ],
            ),
            if (components.isNotEmpty) ...[
              const SizedBox(height: 10),
              _Section(
                title: 'Taxes et composantes',
                children: [
                  for (final component in components)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  component.name,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(switch (component
                                    .calculationMethod) {
                                  TariffCalculationMethod.percentage =>
                                    '${number.format(component.value)} %',
                                  TariffCalculationMethod.perKwh =>
                                    '${decimal.format(component.value)} FCFA/kWh',
                                  TariffCalculationMethod.fixed =>
                                    '${number.format(component.value)} FCFA',
                                }, textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          if (component.thresholdKwh != null)
                            Text(
                              'Applicable au-delà de ${number.format(component.thresholdKwh)} kWh',
                            ),
                          if (component.calculationMethod ==
                              TariffCalculationMethod.percentage)
                            Text(
                              switch (component.taxableBase) {
                                TariffTaxableBase.excessEnergyCost =>
                                  'Calculée sur le coût de l’énergie consommée au-delà du seuil.',
                                TariffTaxableBase.fees =>
                                  'Calculée sur les redevances applicables.',
                                TariffTaxableBase.energyAndFees ||
                                TariffTaxableBase.subtotal =>
                                  'Calculée sur l’énergie et les redevances applicables.',
                                _ => 'Calculée sur le coût de l’énergie.',
                              },
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          if (component.includedInTariff)
                            const Text('Inclus dans le tarif'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ces tarifs sont utilisés par Sama Courant pour calculer vos estimations.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card.filled(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}
