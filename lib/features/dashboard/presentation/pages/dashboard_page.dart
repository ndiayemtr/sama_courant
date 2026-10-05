import '../../../../core/widgets/page_app_bar.dart';
import '../../../appliances/presentation/widgets/appliances_error.dart';
import '../../../../core/widgets/empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:sama_courant/core/presentation/utils/appliance_colors.dart';

import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../budget/data/factories/woyofal_tariff_configuration_factory.dart';
import '../../../consumption_history/domain/providers/consumption_snapshot_service_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../appliances/presentation/models/appliance_visual.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('État actuel enregistré.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer l’état actuel.'),
          behavior: SnackBarBehavior.floating,
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
    final mostConsumingVisual = mostConsuming == null
        ? null
        : ApplianceVisualCatalog.resolve(
            mostConsuming.applianceType ?? mostConsuming.category,
          );
    return Scaffold(
      appBar: pageAppBar(
        context: context,
        automaticallyImplyLeading: false,
        title: 'Sama Courant',

        actions: [
          IconButton(
            tooltip: 'Paramètres',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
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
              child: state.appliances.isEmpty
                  ? EmptyStateCard(
                      icon: Icons.bolt_outlined,
                      title: 'Bienvenue dans Sama Courant',
                      message:
                          'Ajoutez vos appareils pour estimer votre consommation et votre coût.',
                      actionLabel: 'Ajouter mon premier appareil',
                      onAction: () => context.push('/appliances/add'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vue d’ensemble',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            Card.filled(
                              color: theme.colorScheme.surfaceContainerLowest,
                              elevation: 1,
                              shadowColor: theme.colorScheme.shadow.withValues(
                                alpha: 0.08,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ce mois',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _DashboardMetric(
                                            icon: Icons
                                                .electrical_services_outlined,
                                            value:
                                                '${summary.activeUnitsCount}',
                                            label: 'Actifs',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _DashboardMetric(
                                            icon: Icons.bolt_outlined,
                                            value: decimal.format(
                                              summary.consumptionKwh,
                                            ),
                                            label: 'kWh',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _DashboardMetric(
                                            icon: Icons.payments_outlined,
                                            value: fcfa.format(
                                              summary.costFcfa.round(),
                                            ),
                                            label: 'FCFA',
                                            emphasize: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card.filled(
                              color: theme.colorScheme.surfaceContainerLowest,
                              elevation: 1,
                              shadowColor: theme.colorScheme.shadow.withValues(
                                alpha: 0.08,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plus énergivore',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 6),
                                    if (mostConsuming != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 76,
                                            height: 76,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: theme
                                                    .colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child:
                                                mostConsumingVisual
                                                        ?.assetPath !=
                                                    null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Image.asset(
                                                      mostConsumingVisual!
                                                          .assetPath!,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  )
                                                : Icon(
                                                    mostConsumingVisual?.icon ??
                                                        Icons
                                                            .electrical_services_outlined,
                                                    size: 36,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  mostConsuming.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),

                                                const SizedBox(height: 8),

                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.bolt_outlined,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '${decimal.format(mostConsuming.monthlyConsumptionKwh)} kWh',
                                                        maxLines: 2,
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 6),

                                                if (summary
                                                        .mostConsumingCostFcfa !=
                                                    null)
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Icon(
                                                        Icons.payments_outlined,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${fcfa.format(summary.mostConsumingCostFcfa!.round())} FCFA',
                                                          maxLines: 2,
                                                          style: theme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: theme
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      LinearProgressIndicator(
                                        color:
                                            ApplianceChartColors.forApplianceId(
                                              mostConsuming.id,
                                              mostConsuming.name,
                                            ),
                                        value: summary.consumptionKwh <= 0
                                            ? 0
                                            : (mostConsuming
                                                          .monthlyConsumptionKwh /
                                                      summary.consumptionKwh)
                                                  .clamp(0.0, 1.0),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${NumberFormat('0.0', 'fr_FR').format(summary.consumptionKwh <= 0 ? 0 : mostConsuming.monthlyConsumptionKwh / summary.consumptionKwh * 100)} %',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!state.isLoading && state.errorMessage == null) ...[
                          const SizedBox(height: 12),
                          Card.filled(
                            color: theme.colorScheme.surfaceContainerLow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            key: const ValueKey('dashboard-recommendations'),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final recommendation
                                            in summary.recommendations) ...[
                                          Text(
                                            recommendation.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recommendation.message,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
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
                      ],
                    ),
            ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool emphasize;

  const _DashboardMetric({
    required this.icon,
    required this.value,
    required this.label,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: emphasize
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: emphasize
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: emphasize ? theme.colorScheme.primary : null,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
