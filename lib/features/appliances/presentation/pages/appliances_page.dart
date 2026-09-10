import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_result.dart';
import 'package:sama_courant/features/budget/domain/providers/appliance_tariff_service_provider.dart';

import '../../../budget/domain/entities/tariff_configuration.dart';
import '../../domain/entities/appliance.dart';
import '../providers/appliances_provider.dart';
import '../state/appliances_state.dart';
import '../widgets/appliance_card.dart';
import '../widgets/appliances_error.dart';
import '../widgets/appliances_loading.dart';
import '../widgets/empty_appliances.dart';
import 'package:intl/intl.dart';

class AppliancesPage extends ConsumerStatefulWidget {
  const AppliancesPage({super.key});

  @override
  ConsumerState<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends ConsumerState<AppliancesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(appliancesProvider.notifier).loadAppliances();
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Appliance appliance,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer l’appareil ?'),
          content: Text(
            'Voulez-vous vraiment supprimer « ${appliance.name} » ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (appliance.id == null) {
      return;
    }

    await ref.read(appliancesProvider.notifier).deleteAppliance(appliance.id!);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appareil supprimé avec succès.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appliancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes appareils')),
      body: _buildBody(context, ref, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Le formulaire d'ajout sera ajouté dans une prochaine étape.
          context.push('/appliances/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppliancesState state,
  ) {
    if (state.isLoading) {
      return const AppliancesLoading();
    }

    if (state.errorMessage != null) {
      return AppliancesError(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(appliancesProvider.notifier).loadAppliances();
        },
      );
    }

    if (state.appliances.isEmpty) {
      return EmptyAppliances(
        onAdd: () {
          // Le formulaire sera connecté dans une prochaine étape.
          context.push('/appliances/add');
        },
      );
    }

    final tariffService = ref.read(applianceTariffServiceProvider);
    final tariffConfiguration = WoyofalTariffConfigurationFactory.dpp2026();

    final activeAppliances = state.appliances
        .where((appliance) => appliance.isActive)
        .toList();

    final totalMonthlyConsumptionKwh = activeAppliances.fold<double>(
      0,
      (total, appliance) => total + appliance.monthlyConsumptionKwh,
    );

    final totalTariffResult = tariffService.tariffEngine.calculate(
      consumptionKwh: totalMonthlyConsumptionKwh,
      configuration: tariffConfiguration,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.appliances.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MonthlySummaryCard(
              activeAppliancesCount: activeAppliances.length,
              totalConsumptionKwh: totalMonthlyConsumptionKwh,
              totalCostFcfa: totalTariffResult.totalCost,
            ),
          );
        }

        final appliance = state.appliances[index - 1];

        final allocatedMonthlyCost = tariffService
            .calculateAllocatedMonthlyCost(
              appliance: appliance,
              appliances: state.appliances,
              configuration: tariffConfiguration,
            );

        return ApplianceCard(
          appliance: appliance,
          monthlyCostFcfa: allocatedMonthlyCost,
          onViewTariffDetails: () {
            _showTariffDetails(
              context,
              appliance,
              tariffConfiguration,
              totalTariffResult,
              allocatedMonthlyCost,
              totalMonthlyConsumptionKwh,
            );
          },
          onEdit: () {
            context.push('/appliances/edit', extra: appliance);
          },
          onDelete: () {
            _confirmDelete(context, ref, appliance);
          },
        );
      },
    );
  }

  void _showTariffDetails(
    BuildContext context,
    Appliance appliance,
    TariffConfiguration configuration,
    TariffCalculationResult householdResult,
    double allocatedCost,
    double totalMonthlyConsumptionKwh,
  ) {
    final fcfaFormatter = NumberFormat.decimalPattern('fr_FR');
    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    final percentageFormatter = NumberFormat('0.0', 'fr_FR');
    final dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');

    final contributionPercentage = totalMonthlyConsumptionKwh <= 0
        ? 0.0
        : appliance.monthlyConsumptionKwh / totalMonthlyConsumptionKwh * 100;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliance.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Détail de la part mensuelle estimée',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                configuration.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Catégorie : ${configuration.customerCategory}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          configuration.effectiveTo == null
                              ? 'Applicable depuis le '
                                    '${dateFormatter.format(configuration.effectiveFrom)}'
                              : 'Applicable du '
                                    '${dateFormatter.format(configuration.effectiveFrom)} '
                                    'au '
                                    '${dateFormatter.format(configuration.effectiveTo!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _TariffDetailRow(
                    label: 'Consommation de l’appareil',
                    value:
                        '${decimalFormatter.format(appliance.monthlyConsumptionKwh)} kWh',
                  ),

                  const SizedBox(height: 12),

                  _TariffDetailRow(
                    label: 'Consommation du foyer',
                    value:
                        '${decimalFormatter.format(totalMonthlyConsumptionKwh)} kWh',
                  ),

                  const SizedBox(height: 12),

                  _TariffDetailRow(
                    label: 'Part de consommation',
                    value:
                        '${percentageFormatter.format(contributionPercentage)} %',
                  ),

                  const Divider(height: 28),

                  Text(
                    'Tarification globale du foyer',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...householdResult.tierCalculations.map(
                    (tier) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TariffDetailRow(
                        label: 'Tranche ${tier.tierOrder}',
                        value:
                            '${decimalFormatter.format(tier.consumedKwh)} kWh × '
                            '${decimalFormatter.format(tier.pricePerKwh)} FCFA/kWh',
                        secondaryValue:
                            '${fcfaFormatter.format(tier.cost.round())} FCFA',
                      ),
                    ),
                  ),

                  if (householdResult.fees > 0) ...[
                    const Divider(height: 28),
                    _TariffDetailRow(
                      label: 'Frais',
                      value:
                          '${fcfaFormatter.format(householdResult.fees.round())} FCFA',
                    ),
                  ],

                  if (householdResult.taxes > 0) ...[
                    const SizedBox(height: 12),
                    _TariffDetailRow(
                      label: 'Taxes',
                      value:
                          '${fcfaFormatter.format(householdResult.taxes.round())} FCFA',
                    ),
                  ],

                  const Divider(height: 28),

                  _TariffDetailRow(
                    label: 'Coût total estimé du foyer',
                    value:
                        '${fcfaFormatter.format(householdResult.totalCost.round())} FCFA',
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _TariffDetailRow(
                      label: 'Part estimée de cet appareil',
                      value:
                          '${fcfaFormatter.format(allocatedCost.round())} FCFA',
                      emphasize: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Le coût de cet appareil correspond à sa part de la '
                          'consommation mensuelle totale du foyer. La grille '
                          'tarifaire progressive est appliquée une seule fois à '
                          'la consommation globale, puis le coût est réparti '
                          'proportionnellement entre les appareils actifs.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  final int activeAppliancesCount;
  final double totalConsumptionKwh;
  final double totalCostFcfa;

  const _MonthlySummaryCard({
    required this.activeAppliancesCount,
    required this.totalConsumptionKwh,
    required this.totalCostFcfa,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fcfaFormatter = NumberFormat.decimalPattern('fr_FR');
    final decimalFormatter = NumberFormat('0.00', 'fr_FR');
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Résumé mensuel',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _SummaryMetric(
                  icon: Icons.power_outlined,
                  label: 'Appareils actifs',
                  value: '$activeAppliancesCount',
                ),
                _SummaryMetric(
                  icon: Icons.bolt_outlined,
                  label: 'Consommation totale',
                  value: '${decimalFormatter.format(totalConsumptionKwh)} kWh',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _SummaryMetric(
                icon: Icons.payments_outlined,
                label: 'Coût mensuel estimé',
                value: '${fcfaFormatter.format(totalCostFcfa.round())} FCFA',
                emphasize: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(icon, size: 20),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style:
              (emphasize
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TariffDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? secondaryValue;
  final bool emphasize;

  const _TariffDetailRow({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.bold : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
                color: emphasize ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            if (secondaryValue != null) ...[
              const SizedBox(height: 2),
              Text(
                secondaryValue!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
