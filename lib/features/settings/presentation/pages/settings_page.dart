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
        child: Card.filled(
          margin: EdgeInsets.zero,
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Tarification'),
            subtitle: Text(
              '${configuration.name}\nVoir la configuration tarifaire',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tariff'),
          ),
        ),
      ),
    );
  }
}
