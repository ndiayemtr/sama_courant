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
      appBar: AppBar(title: const Text('Tarification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Voici la tarification utilisée pour estimer votre consommation et votre coût.',
            ),
            const SizedBox(height: 12),
            _Section(
              title: configuration.isActive
                  ? 'Configuration active'
                  : 'Configuration inactive',
              children: [
                Text(
                  configuration.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Date d’application : ${date.format(configuration.effectiveFrom)}',
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
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (components.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                              'Assiette : ${switch (component.taxableBase) {
                                TariffTaxableBase.excessEnergyCost => 'coût de l’énergie excédentaire',
                                TariffTaxableBase.fees => 'redevances',
                                TariffTaxableBase.energyAndFees || TariffTaxableBase.subtotal => 'énergie et redevances',
                                _ => 'coût de l’énergie',
                              }}',
                            ),
                          if (component.includedInTariff)
                            const Text('Inclus dans le tarif'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Les estimations de Sama Courant sont calculées à partir de cette configuration tarifaire.',
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
