import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),

                  Expanded(
                    child: _InfoItem(
                      label: 'Conso / jour',
                      value:
                          '${decimalFormatter.format(appliance.dailyConsumptionKwh)} kWh',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _InfoItem(
                      label: 'Conso / mois',
                      value:
                          '${decimalFormatter.format(appliance.monthlyConsumptionKwh)} kWh',
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
                      child: Text(
                        'Part mensuelle estimée',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '${fcfaFormatter.format(monthlyCostFcfa.round())} FCFA',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
}

enum _ApplianceAction { edit, delete }

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
