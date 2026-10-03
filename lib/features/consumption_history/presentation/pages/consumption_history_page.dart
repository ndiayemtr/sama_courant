import '../../../../core/widgets/page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state_card.dart';
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
    return Scaffold(
      appBar: pageAppBar(
        context: context,
        automaticallyImplyLeading: false,
        title: 'Historique',
      ),
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
                FilledButton.icon(
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
              padding: const EdgeInsets.all(16),
              itemCount: visible.isEmpty ? 2 : visible.length + 2,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<int>(
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${visible.length} état${visible.length == 1 ? '' : 's'} '
                        'enregistré${visible.length == 1 ? '' : 's'}',
                        key: const ValueKey('history-visible-count'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }
                if (snapshots.isEmpty) {
                  return EmptyStateCard(
                    icon: Icons.history_outlined,
                    title: 'Aucun historique enregistré',
                    message:
                        'Enregistrez un état depuis le Dashboard pour commencer le suivi.',
                    actionLabel: 'Aller au Dashboard',
                    onAction: () => context.go('/'),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'dd MMM',
                                  'fr_FR',
                                ).format(snapshot.capturedAt),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(snapshot.capturedAt),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HistoryMetric(
                                icon: Icons.bolt_outlined,
                                value:
                                    '${decimal.format(snapshot.totalMonthlyConsumptionKwh)} kWh',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HistoryMetric(
                                icon: Icons.payments_outlined,
                                value:
                                    '${fcfa.format(snapshot.totalMonthlyCostFcfa.round())} FCFA',
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.power_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${snapshot.activeAppliancesCount} appareils',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, size: 22),
                          ],
                        ),
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

class _HistoryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool alignEnd;

  const _HistoryMetric({
    required this.icon,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
