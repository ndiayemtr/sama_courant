import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue ⚡', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Suivez votre consommation électrique.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 2 : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _KpiCard(
                        width: width,
                        icon: Icons.electrical_services,
                        label: 'Appareils actifs',
                        value: '${summary.activeCount}',
                      ),
                      _KpiCard(
                        width: width,
                        icon: Icons.bolt_outlined,
                        label: 'Consommation mensuelle',
                        value: '${decimal.format(summary.consumptionKwh)} kWh',
                      ),
                      _KpiCard(
                        width: width,
                        icon: Icons.payments_outlined,
                        label: 'Coût mensuel estimé',
                        value: '${fcfa.format(summary.costFcfa.round())} FCFA',
                        emphasize: true,
                      ),
                      _KpiCard(
                        width: width,
                        icon: Icons.insights_outlined,
                        label: 'Appareil le plus énergivore',
                        value: mostConsuming?.name ?? '—',
                        subtitle: mostConsuming == null
                            ? null
                            : '${decimal.format(mostConsuming.monthlyConsumptionKwh)} kWh/mois',
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
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

class _KpiCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final bool emphasize;

  const _KpiCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: emphasize ? theme.colorScheme.primaryContainer : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: emphasize
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(label, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
