import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../budget/data/factories/woyofal_tariff_configuration_factory.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final configuration = WoyofalTariffConfigurationFactory.dpp2026();
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card.filled(
              margin: EdgeInsets.zero,
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Tarification'),
                subtitle: Text(configuration.name),
                isThreeLine: false,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tariff'),
              ),
            ),
            const SizedBox(height: 10),
            const _InformationCard(
              icon: Icons.info_outline,
              title: 'Comment fonctionnent les estimations ?',
              children: [
                Text(
                  'La consommation estimée dépend de la puissance, de la quantité '
                  'et de la durée d’utilisation de vos appareils.',
                ),
                SizedBox(height: 6),
                Text(
                  'Le coût estimé utilise la tarification Woyofal active ainsi que '
                  'les taxes actuellement intégrées dans Sama Courant.',
                ),
                SizedBox(height: 12),
                Text(
                  'Les montants affichés sont des estimations.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Sama Courant ne lit pas directement votre compteur Woyofal et ne remplace pas les informations officielles fournies par SENELEC.',
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InformationCard(
              icon: Icons.bolt_outlined,
              title: 'À propos de Sama Courant',
              children: [
                Text(
                  'Sama Courant',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Sama Courant vous aide à mieux comprendre et estimer la consommation électrique de votre foyer.',
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Card.filled(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}
