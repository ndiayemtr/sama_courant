import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';

import '../../domain/entities/appliance.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final double monthlyCostFcfa;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewTariffDetails;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.monthlyCostFcfa,
    this.onEdit,
    this.onDelete,
    this.onViewTariffDetails,
  });

  @override
  Widget build(BuildContext context) {
    final fcfaFormatter = NumberFormat.decimalPattern('fr_FR');
    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    final usageText = _buildUsageText(appliance);
    final theme = Theme.of(context);

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
                const Icon(Icons.electrical_services, size: 22),
                const SizedBox(width: 10),

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
                      const SizedBox(height: 4),

                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            appliance.category,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoItem(label: 'Utilisation', value: usageText),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _InfoItem(
                      label: 'Conso / mois',
                      value:
                          '${decimalFormatter.format(appliance.monthlyConsumptionKwh)} kWh',
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: onViewTariffDetails,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final label = Text(
                            'Part mensuelle estimée',
                            style: theme.textTheme.bodyMedium,
                          );
                          final value = Text(
                            '${fcfaFormatter.format(monthlyCostFcfa.round())} FCFA',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          );
                          if (constraints.maxWidth /
                                  MediaQuery.textScalerOf(context).scale(1) <
                              240) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label,
                                const SizedBox(height: 4),
                                value,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: label),
                              const SizedBox(width: 12),
                              Flexible(child: value),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),

                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildUsageText(Appliance appliance) {
    if (!appliance.usesNewUsageModel) {
      return _buildLegacyUsageText(appliance);
    }

    final duration = _formatDuration(appliance.usageDurationMinutes!);

    final count = appliance.usageCount!;
    final frequency = _frequencyLabel(appliance.usageFrequency!);

    return '$duration • $count fois $frequency';
  }

  String _buildLegacyUsageText(Appliance appliance) {
    final hoursFormatter = NumberFormat('0.##', 'fr_FR');

    return '${hoursFormatter.format(appliance.hoursPerDay)} h/j'
        ' • ${appliance.daysPerMonth} j/mois';
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  const _InfoItem({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, textAlign: textAlign, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          maxLines: 2,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
