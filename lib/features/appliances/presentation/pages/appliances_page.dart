import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/appliance.dart';
import '../providers/appliances_provider.dart';
import '../state/appliances_state.dart';
import '../widgets/appliance_card.dart';
import '../widgets/appliances_error.dart';
import '../widgets/appliances_loading.dart';
import '../widgets/empty_appliances.dart';

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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.appliances.length,
      itemBuilder: (context, index) {
        final appliance = state.appliances[index];

        return ApplianceCard(
          appliance: appliance,
          onEdit: () {
            context.push('/appliances/edit', extra: appliance);
          },
          onDelete: () {
            // Suppression implémentée dans l'étape suivante.
            _confirmDelete(context, ref, appliance);
          },
        );
      },
    );
  }
}
