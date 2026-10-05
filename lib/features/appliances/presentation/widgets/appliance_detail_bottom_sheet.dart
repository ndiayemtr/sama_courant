import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/core/presentation/utils/appliance_colors.dart';

import '../../domain/entities/appliance.dart';
import '../models/appliance_visual.dart';
import 'appliance_calculation_details.dart';
import '../../../budget/domain/entities/tariff_calculation_result.dart';
import '../../../budget/domain/entities/tariff_configuration.dart';

/// Presentation only: all consumption, cost and tariff values come from the page.
class ApplianceDetailBottomSheet extends StatefulWidget {
  const ApplianceDetailBottomSheet({
    super.key,
    required this.appliance,
    required this.monthlyCostFcfa,
    required this.monthlyConsumptionKwh,
    required this.contributionPercentage,
    required this.householdConsumptionKwh,
    required this.householdCostFcfa,
    required this.tariffName,
    required this.tariffCategory,
    this.effectiveFrom,
    this.effectiveTo,
    required this.householdResult,
    required this.tariffConfiguration,
    this.initiallyExpanded = false,
  });

  final Appliance appliance;
  final double monthlyCostFcfa;
  final double monthlyConsumptionKwh;
  final double contributionPercentage;
  final double householdConsumptionKwh;
  final double householdCostFcfa;
  final String tariffName;
  final String tariffCategory;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final TariffCalculationResult householdResult;
  final TariffConfiguration tariffConfiguration;
  final bool initiallyExpanded;

  static Future<void> show(
    BuildContext context,
    ApplianceDetailBottomSheet sheet,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  State<ApplianceDetailBottomSheet> createState() =>
      _ApplianceDetailBottomSheetState();
}

class _ApplianceDetailBottomSheetState
    extends State<ApplianceDetailBottomSheet> {
  late bool isCalculationExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final appliance = widget.appliance;
    final monthlyCostFcfa = widget.monthlyCostFcfa;
    final monthlyConsumptionKwh = widget.monthlyConsumptionKwh;
    final contributionPercentage = widget.contributionPercentage;
    final householdConsumptionKwh = widget.householdConsumptionKwh;
    final householdCostFcfa = widget.householdCostFcfa;
    final tariffName = widget.tariffName;
    final tariffCategory = widget.tariffCategory;
    final effectiveFrom = widget.effectiveFrom;
    final effectiveTo = widget.effectiveTo;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visual = ApplianceVisualCatalog.resolve(
      appliance.applianceType ?? appliance.category,
    );
    final accent = ApplianceChartColors.forApplianceId(
      appliance.id,
      appliance.name,
    );
    final decimal = NumberFormat('0.00', 'fr_FR');
    final money = NumberFormat.decimalPattern('fr_FR');
    final percentage =
        '${NumberFormat('0.0', 'fr_FR').format(contributionPercentage)} %';
    final date = DateFormat('dd/MM/yyyy', 'fr_FR');

    final softBlue = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.08),
      colors.surface,
    );

    Widget circle(IconData icon, {bool filled = false}) => Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colors.primary : softBlue,
      ),
      child: Icon(
        icon,
        size: 18,
        color: filled ? colors.onPrimary : colors.primary,
      ),
    );

    Widget block(Widget child, {bool tinted = false}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tinted ? softBlue : colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );

    Widget pill(IconData icon, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    Widget householdRow(IconData icon, String label, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        circle(icon),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = constraints.maxWidth < 300 ? 90.0 : 96.0;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
                      padding: const EdgeInsets.all(6),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: visual.assetPath == null
                          ? Icon(visual.icon, color: accent, size: 42)
                          : Image.asset(visual.assetPath!, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appliance.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Keep one metadata line when space allows; wrap at large text sizes.
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  visual.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 7,
                                      color: appliance.isActive
                                          ? Colors.green
                                          : colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        appliance.isActive
                                            ? 'Actif'
                                            : 'Inactif',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: appliance.isActive
                                                  ? Colors.green
                                                  : colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerHighest,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            block(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COÛT ESTIMÉ / MOIS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${money.format(monthlyCostFcfa.round())} FCFA',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.10),
                        ),
                        child: Icon(
                          Icons.payments_outlined,
                          color: colors.primary,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      pill(
                        Icons.bolt,
                        '${decimal.format(monthlyConsumptionKwh)} kWh / mois',
                      ),
                      pill(Icons.pie_chart_outline, '$percentage du foyer'),
                    ],
                  ),
                ],
              ),
              tinted: true,
            ),
            const SizedBox(height: 8),
            block(
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Part dans votre consommation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: Text(
                          percentage,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (contributionPercentage / 100).clamp(0.0, 1.0),
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(8),
                    color: accent,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            block(
              Column(
                children: [
                  householdRow(
                    Icons.bolt_outlined,
                    'Consommation du foyer',
                    '${decimal.format(householdConsumptionKwh)} kWh',
                  ),
                  Divider(
                    height: 17,
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  householdRow(
                    Icons.payments_outlined,
                    'Coût total estimé du foyer',
                    '${money.format(householdCostFcfa.round())} FCFA',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            block(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  circle(Icons.receipt_long_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tariffName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Catégorie : $tariffCategory',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (effectiveFrom != null)
                          Text(
                            effectiveTo == null
                                ? 'Applicable depuis le ${date.format(effectiveFrom)}'
                                : 'Applicable du ${date.format(effectiveFrom)} au ${date.format(effectiveTo)}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              tinted: true,
            ),
            const SizedBox(height: 8),
            Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(
                  () => isCalculationExpanded = !isCalculationExpanded,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      circle(Icons.calculate_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comment ce montant est calculé ?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Voir le détail des tranches et du calcul',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isCalculationExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: isCalculationExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ApplianceCalculationDetails(
                        result: widget.householdResult,
                        configuration: widget.tariffConfiguration,
                        householdConsumptionKwh: householdConsumptionKwh,
                        monthlyConsumptionKwh: monthlyConsumptionKwh,
                        contributionPercentage: contributionPercentage,
                        monthlyCostFcfa: monthlyCostFcfa,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            block(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  circle(Icons.info_outline, filled: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Le coût de cet appareil est estimé selon sa part dans la consommation mensuelle totale du foyer.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              tinted: true,
            ),
          ],
        ),
      ),
    );
  }
}
