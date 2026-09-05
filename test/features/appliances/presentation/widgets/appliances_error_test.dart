import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/presentation/widgets/appliances_error.dart';

void main() {
  testWidgets('displays error message and retry button', (tester) async {
    var retryCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppliancesError(
            message: 'Impossible de charger les appareils.',
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Une erreur est survenue'), findsOneWidget);

    expect(find.text('Impossible de charger les appareils.'), findsOneWidget);

    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(retryCalled, isTrue);
  });
}
