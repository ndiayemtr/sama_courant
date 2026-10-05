import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/page_app_bar.dart';
import '../../domain/entities/tariff_calculation_method.dart';
import '../../domain/entities/tariff_configuration.dart';
import '../../domain/entities/tariff_taxable_base.dart';
import '../../domain/entities/tariff_component.dart';
import '../../domain/entities/tariff_tier.dart';

class TariffConfigurationPage extends StatelessWidget {
  final TariffConfiguration configuration;

  const TariffConfigurationPage({super.key, required this.configuration});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final decimal = NumberFormat('0.00', 'fr_FR');
    final number = NumberFormat.decimalPattern('fr_FR');
    final date = DateFormat('dd/MM/yyyy', 'fr_FR');

    final tiers = [...configuration.tiers]
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));

    final components = configuration.components
        .where((component) => component.enabled)
        .toList();

    return Scaffold(
      appBar: pageAppBar(context: context, title: 'Tarification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tarification utilisée pour vos estimations',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            _ActiveConfigurationCard(
              configuration: configuration,
              formattedDate: date.format(configuration.effectiveFrom),
            ),

            const SizedBox(height: 16),

            _EnergyTiersCard(tiers: tiers, decimal: decimal, number: number),

            if (components.isNotEmpty) ...[
              const SizedBox(height: 16),
              _TaxesCard(
                components: components,
                decimal: decimal,
                number: number,
              ),
            ],

            const SizedBox(height: 16),

            const _InformationBanner(),
          ],
        ),
      ),
    );
  }
}

class _ActiveConfigurationCard extends StatelessWidget {
  const _ActiveConfigurationCard({
    required this.configuration,
    required this.formattedDate,
  });

  final TariffConfiguration configuration;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const _LargeIconBox(icon: Icons.receipt_long_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  configuration.isActive
                      ? 'CONFIGURATION ACTIVE'
                      : 'CONFIGURATION INACTIVE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  configuration.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Depuis le $formattedDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (configuration.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD8F7E5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: Color(0xFF00A86B)),
                  SizedBox(width: 7),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF008A57),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EnergyTiersCard extends StatelessWidget {
  const _EnergyTiersCard({
    required this.tiers,
    required this.decimal,
    required this.number,
  });

  final List<TariffTier> tiers;
  final NumberFormat decimal;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionIcon(icon: Icons.bar_chart_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tranches d’énergie',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Détail des tranches et des prix unitaires',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          for (var index = 0; index < tiers.length; index++) ...[
            _TierRow(
              tier: tiers[index],
              decimal: decimal,
              number: number,
              colorIndex: index,
            ),
            if (index < tiers.length - 1)
              Divider(
                height: 24,
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.decimal,
    required this.number,
    required this.colorIndex,
  });

  final TariffTier tier;
  final NumberFormat decimal;
  final NumberFormat number;
  final int colorIndex;

  static const _backgrounds = [
    Color(0xFFE4F0FF),
    Color(0xFFDDF8E8),
    Color(0xFFFFE9D8),
  ];

  static const _foregrounds = [
    Color(0xFF1769E0),
    Color(0xFF009B62),
    Color(0xFFE96500),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final colorSlot = colorIndex % _backgrounds.length;

    final range = tier.maxKwh == null
        ? 'Au-delà de ${number.format(tier.minKwh)} kWh'
        : '${number.format(tier.minKwh)} à '
              '${number.format(tier.maxKwh)} kWh';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 300;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: compact ? 50 : 56,
              height: compact ? 50 : 56,
              decoration: BoxDecoration(
                color: _backgrounds[colorSlot],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${tier.tierOrder}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: _foregrounds[colorSlot],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: compact ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tranche ${tier.tierOrder}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    range,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: compact ? 132 : 150,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${decimal.format(tier.pricePerKwh)} FCFA/kWh',
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaxesCard extends StatelessWidget {
  const _TaxesCard({
    required this.components,
    required this.decimal,
    required this.number,
  });

  final List<TariffComponent> components;
  final NumberFormat decimal;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFECE8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  color: Color(0xFF5144C9),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taxes et composantes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Détail des taxes actuellement intégrées',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          for (var index = 0; index < components.length; index++) ...[
            _TaxComponent(
              component: components[index],
              decimal: decimal,
              number: number,
            ),
            if (index < components.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TaxComponent extends StatelessWidget {
  const _TaxComponent({
    required this.component,
    required this.decimal,
    required this.number,
  });

  final TariffComponent component;
  final NumberFormat decimal;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final value = switch (component.calculationMethod) {
      TariffCalculationMethod.percentage =>
        '${number.format(component.value)} %',
      TariffCalculationMethod.perKwh =>
        '${decimal.format(component.value)} FCFA/kWh',
      TariffCalculationMethod.fixed => '${number.format(component.value)} FCFA',
    };

    final description = switch (component.taxableBase) {
      TariffTaxableBase.excessEnergyCost =>
        'Calculée sur le coût de l’énergie consommée au-delà du seuil.',
      TariffTaxableBase.fees => 'Calculée sur les redevances applicables.',
      TariffTaxableBase.energyAndFees || TariffTaxableBase.subtotal =>
        'Calculée sur l’énergie et les redevances applicables.',
      _ => 'Calculée sur le coût de l’énergie.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (component.thresholdKwh != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Applicable au-delà de '
                        '${number.format(component.thresholdKwh)} kWh',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          component.includedInTariff ? 'Inclus dans le tarif' : description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _InformationBanner extends StatelessWidget {
  const _InformationBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Ces tarifs sont utilisés par Sama Courant pour '
              'calculer vos estimations.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LargeIconBox extends StatelessWidget {
  const _LargeIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.70),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 31, color: colors.primary),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 27, color: colors.primary),
    );
  }
}
