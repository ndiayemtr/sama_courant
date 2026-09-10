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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.electrical_services),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appliance.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'x${appliance.quantity}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  appliance.category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  avatar: Icon(
                    appliance.isActive
                        ? Icons.check_circle
                        : Icons.pause_circle,
                    size: 18,
                    color: appliance.isActive
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: Text(appliance.isActive ? 'Actif' : 'Inactif'),
                  backgroundColor: appliance.isActive
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 6),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_outlined),
                    const SizedBox(width: 10),
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
            ),

            const SizedBox(height: 6),

            InkWell(
              onTap: onViewTariffDetails,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Part mensuelle estimée',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${fcfaFormatter.format(monthlyCostFcfa.round())} FCFA',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
