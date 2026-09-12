import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/consumption_distribution_card.dart';
import '../../../dashboard/presentation/widgets/top_consumers_card.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Analyse énergétique')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comprenez où part votre consommation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.errorMessage != null) ...[
              const Text('Impossible de charger les appareils.'),
              TextButton.icon(
                onPressed: () =>
                    ref.read(appliancesProvider.notifier).loadAppliances(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ] else ...[
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
          ],
        ),
      ),
    );
  }
}
