import 'package:flutter/material.dart';

class ApplianceFormPage extends StatelessWidget {
  const ApplianceFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un appareil')),
      body: const Center(child: Text('Formulaire d’appareil')),
    );
  }
}
