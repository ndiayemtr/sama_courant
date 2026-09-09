import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import 'package:sama_courant/features/budget/domain/providers/appliance_tariff_service_provider.dart';

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

        final tariffResult = tariffService.calculateMonthlyCost(
          appliance: appliance,
          configuration: tariffConfiguration,
        );

        return ApplianceCard(
          appliance: appliance,
          monthlyCostFcfa: tariffResult.totalCost,
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
    final fcfaFormatter = NumberFormat.decimalPattern('fr_FR');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résumé mensuel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SummaryRow(
              icon: Icons.power_outlined,
              label: 'Appareils actifs',
              value: '$activeAppliancesCount',
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.bolt_outlined,
              label: 'Consommation totale',
              value: '${totalConsumptionKwh.toStringAsFixed(2)} kWh',
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.payments_outlined,
              label: 'Coût mensuel estimé',
              value: '${fcfaFormatter.format(totalCostFcfa.round())} FCFA',
              emphasize: true,
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
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
            color: emphasize ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
