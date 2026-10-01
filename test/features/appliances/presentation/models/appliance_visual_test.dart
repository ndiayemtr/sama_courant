import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/presentation/models/appliance_visual.dart';

void main() {
  group('ApplianceVisualCatalog', () {
    test('retourne le libellé et une icône pour un type connu', () {
      final visual = ApplianceVisualCatalog.resolve('refrigerator');

      expect(visual.label, 'Réfrigérateur');
      expect(visual.icon, Icons.kitchen_outlined);
    });

    test('retourne le libellé français pour plusieurs types connus', () {
      expect(
        ApplianceVisualCatalog.labelForType('air_conditioner'),
        'Climatiseur',
      );
      expect(ApplianceVisualCatalog.labelForType('television'), 'Téléviseur');
      expect(ApplianceVisualCatalog.labelForType('fan'), 'Ventilateur');
    });

    test('retourne null si le type est null', () {
      expect(ApplianceVisualCatalog.labelForType(null), isNull);
    });

    test('retourne null si le type est inconnu', () {
      expect(ApplianceVisualCatalog.labelForType('unknown_appliance'), isNull);
    });

    test('préserve une catégorie legacy inconnue avec une icône générique', () {
      final visual = ApplianceVisualCatalog.resolve('Cuisine');

      expect(visual.label, 'Cuisine');
      expect(visual.icon, Icons.electrical_services_outlined);
    });

    test('préserve Autre avec une icône générique', () {
      final visual = ApplianceVisualCatalog.resolve('Autre');

      expect(visual.label, 'Autre');
      expect(visual.icon, Icons.electrical_services_outlined);
    });
  });
}
