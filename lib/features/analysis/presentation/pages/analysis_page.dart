import '../../../../core/widgets/page_app_bar.dart';
import '../../../appliances/presentation/widgets/appliances_error.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state_card.dart';
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
      appBar: pageAppBar(
        context: context,
        automaticallyImplyLeading: false,
        title: 'Analyse énergétique',
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? AppliancesError(
              message: 'Impossible de charger les appareils.',
              onRetry: () =>
                  ref.read(appliancesProvider.notifier).loadAppliances(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summary.consumptionKwh <= 0) ...[
                    EmptyStateCard(
                      icon: Icons.insights_outlined,
                      title: 'Pas encore de données à analyser',
                      message:
                          'Ajoutez et activez des appareils pour voir la répartition de votre consommation.',
                      actionLabel: 'Voir mes appareils',
                      onAction: () => context.go('/appliances'),
                    ),
                  ] else ...[
                    ConsumptionDistributionCard(summary: summary),
                    const SizedBox(height: 12),
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
                                  Icons.lightbulb_outline,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'À retenir',
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
                    const SizedBox(height: 12),
                    TopConsumersCard(summary: summary),

                    if (summary.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Card.filled(
                        key: const ValueKey('analysis-recommendations'),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conseils',
                                style: theme.textTheme.titleSmall,
                              ),
                              for (final recommendation
                                  in summary.recommendations)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                  ],
                ],
              ),
            ),
    );
  }
}
