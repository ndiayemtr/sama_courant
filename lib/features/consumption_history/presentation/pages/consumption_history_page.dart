import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/providers/consumption_history_chart_service_provider.dart';
import '../widgets/consumption_history_chart.dart';

import '../providers/consumption_history_provider.dart';

class ConsumptionHistoryPage extends ConsumerStatefulWidget {
  const ConsumptionHistoryPage({super.key});

  @override
  ConsumerState<ConsumptionHistoryPage> createState() =>
      _ConsumptionHistoryPageState();
}

class _ConsumptionHistoryPageState
    extends ConsumerState<ConsumptionHistoryPage> {
  int _periodDays = 30;

  @override
  Widget build(BuildContext context) {
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
        data: (snapshots) {
          final now = DateTime.now();
          final cutoff = now.subtract(Duration(days: _periodDays));
          final visible = snapshots
              .where(
                (snapshot) =>
                    _periodDays == 0 || !snapshot.capturedAt.isBefore(cutoff),
              )
              .toList();
          final chartService = ref.read(consumptionHistoryChartServiceProvider);

          final chartPoints = chartService.buildPoints(visible);

          return RefreshIndicator(
            onRefresh: () async {
              try {
                ref.invalidate(consumptionHistoryProvider);
                await ref.read(consumptionHistoryProvider.future);
              } catch (_) {
                // L'erreur est exposée par le provider.
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: visible.isEmpty ? 2 : visible.length + 2,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 7, label: Text('7 jours')),
                          ButtonSegment(value: 30, label: Text('30 jours')),
                          ButtonSegment(value: 0, label: Text('Tout')),
                        ],
                        selected: {_periodDays},
                        onSelectionChanged: (selection) =>
                            setState(() => _periodDays = selection.single),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${visible.length} état${visible.length == 1 ? '' : 's'} enregistré${visible.length == 1 ? '' : 's'}',
                        key: const ValueKey('history-visible-count'),
                      ),
                    ],
                  );
                }
                if (snapshots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.history_outlined, size: 40),
                        SizedBox(height: 12),
                        Text('Aucun historique enregistré.'),
                        SizedBox(height: 4),
                        Text(
                          'Enregistrez un état depuis le Dashboard '
                          'pour commencer le suivi.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (visible.isEmpty) {
                  return const Text('Aucun état enregistré sur cette période.');
                }

                if (index == 1) {
                  return ConsumptionHistoryChart(points: chartPoints);
                }

                final snapshot = visible[index - 2];

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
                              'Consommation estimée : '
                              '${decimal.format(snapshot.totalMonthlyConsumptionKwh)} kWh',
                            ),
                            Text(
                              'Coût estimé : '
                              '${fcfa.format(snapshot.totalMonthlyCostFcfa.round())} FCFA',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.activeAppliancesCount} '
                          'appareil'
                          '${snapshot.activeAppliancesCount == 1 ? '' : 's'} '
                          'actif'
                          '${snapshot.activeAppliancesCount == 1 ? '' : 's'}',
                        ),
                        Text(snapshot.tariffConfigurationName),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
