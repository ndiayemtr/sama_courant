import 'package:flutter/material.dart';

import '../../domain/entities/appliance.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // final VoidCallback? onToggleStatus;

  const ApplianceCard({
    super.key,
    required this.appliance,
    this.onEdit,
    this.onDelete,
    // this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      appliance.isActive
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      appliance.isActive ? 'Actif' : 'Inactif',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              appliance.category,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoItem(
                        label: 'Consommation / jour',
                        value:
                            '${appliance.dailyConsumptionKwh.toStringAsFixed(2)} kWh',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoItem(
                        label: 'Consommation / mois',
                        value:
                            '${appliance.monthlyConsumptionKwh.toStringAsFixed(2)} kWh',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
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
                      minimumSize: const Size.fromHeight(44),
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
        const SizedBox(height: 2),
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
