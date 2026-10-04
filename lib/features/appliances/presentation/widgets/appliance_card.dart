import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/core/presentation/utils/appliance_colors.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';
import 'package:sama_courant/features/appliances/presentation/models/appliance_visual.dart';

import '../../domain/entities/appliance.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final double monthlyCostFcfa;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewTariffDetails;
  final bool isMostConsuming;
  final double contributionPercentage;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.monthlyCostFcfa,
    this.onEdit,
    this.onDelete,
    this.onViewTariffDetails,
    this.isMostConsuming = false,
    this.contributionPercentage = 0,
  });

  @override
  Widget build(BuildContext context) {
    final applianceColor = ApplianceChartColors.forApplianceId(
      appliance.id,
      appliance.name,
    );
    final fcfaFormatter = NumberFormat.decimalPattern('fr_FR');
    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    final usageDisplay = _buildUsageDisplay(appliance);
    final theme = Theme.of(context);

    final visual = ApplianceVisualCatalog.resolve(
      appliance.applianceType ?? appliance.category,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: visual.assetPath != null
                      ? Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            visual.assetPath!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(visual.icon, size: 34, color: applianceColor),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliance.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (isMostConsuming) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 16,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Plus énergivore',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),

                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            visual.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            avatar: Icon(
                              appliance.isActive
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              size: 18,
                              color: appliance.isActive
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            label: Text(
                              appliance.isActive ? 'Actif' : 'Inactif',
                            ),
                            backgroundColor: appliance.isActive
                                ? theme.colorScheme.secondaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'x${appliance.quantity}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    PopupMenuButton<_ApplianceAction>(
                      tooltip: 'Actions',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (action) {
                        switch (action) {
                          case _ApplianceAction.edit:
                            onEdit?.call();
                            break;
                          case _ApplianceAction.delete:
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: _ApplianceAction.edit,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 12),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _ApplianceAction.delete,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 34,
                    child: _MetricItem(
                      icon: Icons.schedule_outlined,
                      label: 'Utilisation',
                      primaryValue: usageDisplay.primary,
                      secondaryValue: usageDisplay.secondary,
                      iconColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 30,
                    child: _MetricItem(
                      icon: Icons.bolt,
                      label: 'Conso/mois',
                      primaryValue:
                          '${decimalFormatter.format(appliance.monthlyConsumptionKwh)} kWh',
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 36,
                    child: InkWell(
                      onTap: onViewTariffDetails,
                      borderRadius: BorderRadius.circular(8),
                      child: _MetricItem(
                        icon: Icons.payments_outlined,
                        label: 'Coût estimé',
                        primaryValue:
                            '${fcfaFormatter.format(monthlyCostFcfa.round())} FCFA',
                        iconColor: Colors.orange,
                        valueColor: Colors.orange,
                        showChevron: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _ContributionBar(
              percentage: contributionPercentage,
              color: applianceColor,
            ),
          ],
        ),
      ),
    );
  }

  _UsageDisplay _buildUsageDisplay(Appliance appliance) {
    if (!appliance.usesNewUsageModel) {
      return _buildLegacyUsageDisplay(appliance);
    }

    final duration = _formatDuration(appliance.usageDurationMinutes!);
    final count = appliance.usageCount!;
    final frequency = _frequencyLabel(appliance.usageFrequency!);

    return _UsageDisplay(
      primary: duration,
      secondary: '$count fois $frequency',
    );
  }

  _UsageDisplay _buildLegacyUsageDisplay(Appliance appliance) {
    final hoursFormatter = NumberFormat('0.##', 'fr_FR');

    return _UsageDisplay(
      primary: '${hoursFormatter.format(appliance.hoursPerDay)} h/jour',
      secondary: '${appliance.daysPerMonth} j/mois',
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours h';
    }

    return '$hours h $remainingMinutes min';
  }

  String _frequencyLabel(UsageFrequency frequency) {
    switch (frequency) {
      case UsageFrequency.daily:
        return '/ jour';
      case UsageFrequency.weekly:
        return '/ semaine';
      case UsageFrequency.monthly:
        return '/ mois';
    }
  }
}

enum _ApplianceAction { edit, delete }

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String primaryValue;
  final String? secondaryValue;
  final Color? iconColor;
  final Color? valueColor;
  final bool showChevron;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.primaryValue,
    this.secondaryValue,
    this.iconColor,
    this.valueColor,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                primaryValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right, size: 16),
          ],
        ),
        if (secondaryValue != null) ...[
          const SizedBox(height: 2),
          Text(
            secondaryValue!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ContributionBar extends StatelessWidget {
  final double percentage;
  final Color color;

  const _ContributionBar({required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('0.0', 'fr_FR');

    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${formatter.format(percentage)} % du total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _UsageDisplay {
  final String primary;
  final String secondary;

  const _UsageDisplay({required this.primary, required this.secondary});
}
