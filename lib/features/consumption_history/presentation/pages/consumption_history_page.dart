import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/consumption_history_provider.dart';

class ConsumptionHistoryPage extends ConsumerWidget {
  const ConsumptionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(consumptionHistoryProvider);
    final decimal = NumberFormat('0.00', 'fr_FR');
    final fcfa = NumberFormat.decimalPattern('fr_FR');
    final date = DateFormat("dd/MM/yyyy 'à' HH:mm", 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: history.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger l’historique.'),
                TextButton.icon(
                  onPressed: () => ref.invalidate(consumptionHistoryProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (snapshots) => RefreshIndicator(
          onRefresh: () async {
            try {
              ref.invalidate(consumptionHistoryProvider);
              await ref.read(consumptionHistoryProvider.future);
            } catch (_) {
              // The provider exposes the error through the page's error state.
            }
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: snapshots.isEmpty ? 1 : snapshots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (snapshots.isEmpty) {
                return const Column(
                  children: [
                    Icon(Icons.history_outlined),
                    SizedBox(height: 8),
                    Text('Aucun historique enregistré.'),
                    Text(
                      'Enregistrez un état depuis le Dashboard pour commencer le suivi.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }
              final snapshot = snapshots[index];
              return Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date.format(snapshot.capturedAt),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Consommation estimée : ${decimal.format(snapshot.totalMonthlyConsumptionKwh)} kWh',
                          ),
                          Text(
                            'Coût estimé : ${fcfa.format(snapshot.totalMonthlyCostFcfa.round())} FCFA',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.activeAppliancesCount} appareil${snapshot.activeAppliancesCount == 1 ? '' : 's'} actif${snapshot.activeAppliancesCount == 1 ? '' : 's'}',
                      ),
                      Text(snapshot.tariffConfigurationName),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
