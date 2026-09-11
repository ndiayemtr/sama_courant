import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../budget/data/factories/woyofal_tariff_configuration_factory.dart';
import '../../../consumption_history/domain/providers/consumption_snapshot_service_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/consumption_distribution_card.dart';
import '../widgets/top_consumers_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isCapturing = false;

  Future<void> _captureSnapshot() async {
    final state = ref.read(appliancesProvider);
    if (_isCapturing || state.isLoading || state.errorMessage != null) return;
    setState(() => _isCapturing = true);
    try {
      await ref
          .read(consumptionSnapshotServiceProvider)
          .capture(
            appliances: List.of(state.appliances),
            configuration: WoyofalTariffConfigurationFactory.dpp2026(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('État actuel enregistré.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer l’état actuel.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted && !ref.read(appliancesProvider).isLoading) {
        ref.read(appliancesProvider.notifier).loadAppliances();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appliancesProvider);
    final summary = ref.watch(dashboardProvider);
    final decimal = NumberFormat('0.00', 'fr_FR');
    final fcfa = NumberFormat.decimalPattern('fr_FR');
    final theme = Theme.of(context);
    final mostConsuming = summary.mostConsuming;

    return Scaffold(
      appBar: AppBar(title: const Text('Sama Courant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue ⚡', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Suivez votre consommation électrique.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Vue d’ensemble', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.errorMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impossible de charger les appareils.'),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(appliancesProvider.notifier).loadAppliances(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Card.filled(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résumé mensuel',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          _SummaryRow(
                            icon: Icons.electrical_services,
                            label: 'Appareils actifs',
                            value: '${summary.activeCount}',
                          ),
                          _SummaryRow(
                            icon: Icons.bolt_outlined,
                            label: 'Consommation mensuelle',
                            value:
                                '${decimal.format(summary.consumptionKwh)} kWh',
                          ),
                          _SummaryRow(
                            icon: Icons.payments_outlined,
                            label: 'Coût mensuel estimé',
                            value:
                                '${fcfa.format(summary.costFcfa.round())} FCFA',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.insights_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Plus énergivore',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mostConsuming?.name ?? '—',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (mostConsuming != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${decimal.format(mostConsuming.monthlyConsumptionKwh)} kWh/mois',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '≈ ${NumberFormat('0.0', 'fr_FR').format(summary.consumptionKwh <= 0 ? 0 : mostConsuming.monthlyConsumptionKwh / summary.consumptionKwh * 100)} % du total',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            if (!state.isLoading && state.errorMessage == null) ...[
              const SizedBox(height: 10),
              ConsumptionDistributionCard(summary: summary),
              const SizedBox(height: 10),
              TopConsumersCard(summary: summary),
              const SizedBox(height: 10),
              Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Analyse rapide',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.analysisSummary,
                        key: const ValueKey('analysis-summary'),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!state.isLoading && state.errorMessage == null) ...[
              const SizedBox(height: 10),
              Card.filled(
                key: const ValueKey('dashboard-recommendations'),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conseils', style: theme.textTheme.titleSmall),
                      for (final recommendation in summary.recommendations)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recommendation.title,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      recommendation.message,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('capture-snapshot'),
                onPressed:
                    _isCapturing ||
                        state.isLoading ||
                        state.errorMessage != null
                    ? null
                    : _captureSnapshot,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: 'Enregistrement en cours',
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Enregistrer l’état actuel'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history),
                label: const Text('Voir l’historique'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/appliances'),
                icon: const Icon(Icons.electrical_services),
                label: const Text('Mes appareils'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: emphasize ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
