import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sama_courant/features/appliances/presentation/widgets/appliances_loading.dart';

void main() {
  testWidgets('displays loading indicator and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppliancesLoading())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Chargement de vos appareils...'), findsOneWidget);
  });
}
