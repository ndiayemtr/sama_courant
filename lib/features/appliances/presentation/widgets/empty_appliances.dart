import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_card.dart';

class EmptyAppliances extends StatelessWidget {
  final VoidCallback? onAdd;
  const EmptyAppliances({super.key, this.onAdd});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: EmptyStateCard(
      icon: Icons.electrical_services_outlined,
      title: 'Aucun appareil enregistré',
      message:
          'Ajoutez votre premier appareil pour estimer votre consommation.',
      actionLabel: 'Ajouter un appareil',
      onAction: onAdd,
    ),
  );
}
