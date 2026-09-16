import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sama_courant/core/router/app_router.dart';
import 'package:sama_courant/core/theme/app_theme.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'package:sama_courant/features/consumption_history/data/providers/consumption_snapshot_repository_provider.dart';
import 'package:sama_courant/features/consumption_history/presentation/widgets/consumption_history_chart.dart';
import 'features/appliances/presentation/pages/appliances_page_test.dart'
    as appliances;
import 'features/consumption_history/presentation/consumption_history_page_test.dart'
    as history;

void checkLayout(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: 'Texte tronqué : ${paragraph.text.toPlainText()}',
    );
  }
}

Future<void> inspectScroll(WidgetTester tester) async {
  checkLayout(tester);
  final scrollables = find.byType(Scrollable).evaluate().toList();
  for (final element in scrollables) {
    if (!element.mounted) continue;
    final state = (element as StatefulElement).state as ScrollableState;
    if (axisDirectionToAxis(state.axisDirection) != Axis.vertical) continue;
    final position = state.position;
    while (position.pixels < position.maxScrollExtent) {
      position.jumpTo(
        (position.pixels + 250).clamp(0, position.maxScrollExtent),
      );
      await tester.pumpAndSettle();
      checkLayout(tester);
    }
    position.jumpTo(0);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  for (final width in [320.0, 800.0]) {
    testWidgets(
      'UX complète largeur $width texte ${width == 320 ? 150 : 100} %',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = appliances.TestApplianceRepository(
          appliances: [appliances.createTestAppliance()],
        );
        final historyRepository = history.HistoryRepository()
          ..load = () async => [history.snapshot(14), history.snapshot(15)];
        appRouter.go('/');
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              getAppliancesProvider.overrideWithValue(
                GetAppliances(repository),
              ),
              consumptionSnapshotRepositoryProvider.overrideWithValue(
                historyRepository,
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light(),
              routerConfig: appRouter,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(width == 320 ? 1.5 : 1),
                ),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await inspectScroll(tester);
        expect(find.text('Résumé mensuel'), findsOneWidget);
        for (final label in ['Historique', 'Analyse', 'Appareils']) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(NavigationDestination), findsNWidgets(4));
          await inspectScroll(tester);
          if (label == 'Historique') {
            for (final period in ['7 jours', '30 jours']) {
              await tester.tap(find.text(period));
              await tester.pumpAndSettle();
              checkLayout(tester);
            }
            await tester.tap(find.text('Tout'));
            await tester.pumpAndSettle();
            expect(find.byType(ConsumptionHistoryChart), findsOneWidget);
            await tester.ensureVisible(find.text('Coût'));
            await tester.tap(find.text('Coût'));
            await tester.pumpAndSettle();
            await inspectScroll(tester);
            await tester.tap(find.text('Consommation'));
            await tester.pumpAndSettle();
            checkLayout(tester);
          }
          if (label == 'Analyse') {
            expect(find.text('À retenir'), findsOneWidget);
            expect(find.text('Top consommateurs'), findsOneWidget);
            expect(
              find.byKey(const ValueKey('analysis-summary')),
              findsOneWidget,
            );
          }
        }
        final cost = find.text('Part mensuelle estimée');
        await tester.scrollUntilVisible(
          cost,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(cost);
        await tester.pumpAndSettle();
        await tester.tap(cost);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        await inspectScroll(tester);
        await tester.tap(find.byTooltip('Fermer'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byTooltip('Actions'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Modifier'));
        await tester.pumpAndSettle();
        await inspectScroll(tester);
        await tester.pageBack();
        await tester.pumpAndSettle();
        appRouter.push('/appliances/add');
        await tester.pumpAndSettle();
        await inspectScroll(tester);
        final category = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(category);
        await tester.pumpAndSettle();
        await tester.tap(category);
        await tester.pumpAndSettle();
        final bathroom = find.text('Salle de bain').last;
        await tester.ensureVisible(bathroom);
        await tester.pumpAndSettle();
        await tester.tap(bathroom);
        await tester.pumpAndSettle();
        checkLayout(tester);
        await tester.pageBack();
        await tester.pumpAndSettle();
        appRouter.go('/');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Paramètres'));
        await tester.pumpAndSettle();
        await inspectScroll(tester);
        await tester.tap(find.text('Tarification'));
        await tester.pumpAndSettle();
        await inspectScroll(tester);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        checkLayout(tester);
      },
    );
  }
}
