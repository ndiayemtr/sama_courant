import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sama_courant/app.dart';

void main() {
  testWidgets('Sama Courant app starts successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SamaCourantApp()));

    await tester.pumpAndSettle();

    expect(find.text('Sama Courant'), findsOneWidget);
    expect(find.text('Bienvenue sur Sama Courant ⚡'), findsOneWidget);
  });
}
