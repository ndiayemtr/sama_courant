import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('settings information remains readable and scrollable on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const SettingsPage(),
      ),
    );
    expect(find.text('Tarification'), findsOneWidget);
    for (final text in [
      'Comment fonctionnent les estimations ?',
      'Les montants affichés sont des estimations.',
      'Sama Courant ne lit pas directement votre compteur Woyofal et ne remplace pas les informations officielles fournies par SENELEC.',
      'À propos de Sama Courant',
      'Sama Courant',
      'Sama Courant vous aide à mieux comprendre et estimer la consommation électrique de votre foyer.',
    ]) {
      final finder = find.text(text);
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
