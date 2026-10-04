import '../../../../core/widgets/page_app_bar.dart';
import '../../../budget/presentation/widgets/tariff_calculation_details.dart';
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

import 'package:image_picker/image_picker.dart';

import '../../data/services/mlkit_label_text_recognizer.dart';
import '../../domain/services/appliance_classifier.dart';
import '../../domain/services/appliance_label_parser.dart';
import '../../domain/services/appliance_label_type_detector.dart';
import '../../domain/services/appliance_power_estimator.dart';
import '../../domain/services/label_text_normalizer.dart';
import '../../domain/services/power_resolver.dart';
import '../../domain/usecases/scan_appliance_label.dart';
import '../widgets/appliance_type_selector.dart';

class AppliancesPage extends ConsumerStatefulWidget {
  const AppliancesPage({super.key});

  @override
  ConsumerState<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends ConsumerState<AppliancesPage> {
  final _imagePicker = ImagePicker();
  bool _isScanning = false;

  static const _scanApplianceLabel = ScanApplianceLabel(
    textRecognizer: MlKitLabelTextRecognizer(),
    textNormalizer: LabelTextNormalizer(),
    labelParser: ApplianceLabelParser(),
    classifier: ApplianceClassifier(),
    powerResolver: PowerResolver(),
    powerEstimator: AppliancePowerEstimator(),
    labelTypeDetector: ApplianceLabelTypeDetector(),
  );

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(appliancesProvider.notifier).loadAppliances();
    });
  }

  Future<void> _scanApplianceFromCamera() async {
    setState(() {
      _isScanning = true;
    });

    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
      return;
    }

    try {
      final scanResult = await _scanApplianceLabel(image.path);

      if (!mounted) {
        return;
      }

      debugPrint('OCR RAW: ${scanResult.rawOcrText}');
      debugPrint('TYPE: ${scanResult.applianceType}');
      debugPrint('POWER: ${scanResult.powerWatts}');
      debugPrint('POWER SOURCE: ${scanResult.powerSource}');
      debugPrint('CONFIDENCE: ${scanResult.confidenceLevel}');
      debugPrint('ENERGY METRICS: ${scanResult.energyConsumptionMetrics}');

      await context.push('/appliances/add-from-scan', extra: scanResult);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’analyser cette étiquette. Réessayez avec une photo plus nette.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<String?> _selectManualApplianceType(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quel appareil avez-vous ?',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Touchez l’image qui correspond à votre appareil.',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ApplianceTypeSelector(
                    onSelected: (type) {
                      Navigator.of(sheetContext).pop(type);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAddApplianceOptions(BuildContext context) async {
    final mode = await showModalBottomSheet<_AddApplianceMode>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajouter un appareil',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez la méthode la plus simple pour vous.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop(_AddApplianceMode.scan);
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scanner une étiquette'),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop(_AddApplianceMode.manual);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ajouter manuellement'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || mode == null) {
      return;
    }

    switch (mode) {
      case _AddApplianceMode.scan:
        await _scanApplianceFromCamera();
        break;

      case _AddApplianceMode.manual:
        final applianceType = await _selectManualApplianceType(context);

        if (!context.mounted || applianceType == null) {
          return;
        }

        context.push('/appliances/add', extra: applianceType);
        break;
    }
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
      SnackBar(
        content: Text(
          ref.read(appliancesProvider).errorMessage == null
              ? 'Appareil supprimé avec succès.'
              : 'Impossible de terminer la suppression. Veuillez réessayer.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appliancesProvider);

    if (_isScanning) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.document_scanner_outlined, size: 72),
                  SizedBox(height: 28),
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'Analyse en cours',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Sama Courant lit l’étiquette de votre appareil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quelques secondes seulement.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: pageAppBar(
        context: context,
        automaticallyImplyLeading: false,
        title: 'Mes appareils',
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: state.appliances.isEmpty || _isScanning
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                _openAddApplianceOptions(context);
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
        message: 'Impossible de charger les appareils.',
        onRetry: () {
          ref.read(appliancesProvider.notifier).loadAppliances();
        },
      );
    }

    if (state.appliances.isEmpty) {
      return EmptyAppliances(
        onAdd: () {
          _openAddApplianceOptions(context);
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

    Appliance? mostConsumingAppliance;

    for (final appliance in activeAppliances) {
      if (mostConsumingAppliance == null ||
          appliance.monthlyConsumptionKwh >
              mostConsumingAppliance.monthlyConsumptionKwh) {
        mostConsumingAppliance = appliance;
      }
    }

    final totalTariffResult = tariffService.tariffEngine.calculate(
      consumptionKwh: totalMonthlyConsumptionKwh,
      configuration: tariffConfiguration,
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: state.appliances.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MonthlySummaryCard(
              activeAppliancesCount: activeAppliances.fold<int>(
                0,
                (total, appliance) => total + appliance.quantity,
              ),
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

        final contributionPercentage =
            !appliance.isActive || totalMonthlyConsumptionKwh <= 0
            ? 0.0
            : appliance.monthlyConsumptionKwh /
                  totalMonthlyConsumptionKwh *
                  100;

        final isMostConsuming =
            appliance.isActive && identical(appliance, mostConsumingAppliance);

        return ApplianceCard(
          appliance: appliance,
          monthlyCostFcfa: allocatedMonthlyCost,
          isMostConsuming: isMostConsuming,
          contributionPercentage: contributionPercentage,
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
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.25,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appliance.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Détail de la part mensuelle estimée',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Fermer',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer
                            .withValues(alpha: 0.45),
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

                    const SizedBox(height: 12),

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

                    TariffCalculationDetails(
                      result: householdResult,
                      configuration: configuration,
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
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
    final fcfa = NumberFormat.decimalPattern('fr_FR');
    final decimal = NumberFormat('0.00', 'fr_FR');
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé mensuel',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MonthlySummaryMetric(
                    icon: Icons.power_outlined,
                    label: 'Appareils actifs',
                    value: activeAppliancesCount.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MonthlySummaryMetric(
                    icon: Icons.bolt_outlined,
                    label: 'Consommation totale',
                    value: '${decimal.format(totalConsumptionKwh)} kWh',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MonthlySummaryMetric(
                    icon: Icons.payments_outlined,
                    label: 'Coût estimé',
                    value: '${fcfa.format(totalCostFcfa.round())} FCFA',
                    emphasize: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TariffDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _TariffDetailRow({
    required this.label,
    required this.value,
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
          ],
        ),
      ],
    );
  }
}

enum _AddApplianceMode { scan, manual }

class _MonthlySummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const _MonthlySummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
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
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasize ? theme.colorScheme.tertiary : null,
          ),
        ),
      ],
    );
  }
}
