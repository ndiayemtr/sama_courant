import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/budget/data/factories/woyofal_tariff_configuration_factory.dart';
import '../../features/budget/presentation/pages/tariff_configuration_page.dart';
import 'main_navigation_shell.dart';
import '../../features/analysis/presentation/pages/analysis_page.dart';

import '../../features/appliances/domain/entities/appliance.dart';
import '../../features/appliances/presentation/pages/appliance_form_page.dart';
import '../../features/appliances/presentation/pages/appliances_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/consumption_history/presentation/pages/consumption_history_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/tariff',
      builder: (context, state) => TariffConfigurationPage(
        configuration: WoyofalTariffConfigurationFactory.dpp2026(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          MainNavigationShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: '/history',
          builder: (context, state) => const ConsumptionHistoryPage(),
        ),
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisPage(),
        ),
        GoRoute(
          path: '/appliances',
          builder: (context, state) => const AppliancesPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/appliances/add',
      builder: (context, state) => const ApplianceFormPage(),
    ),
    GoRoute(
      path: '/appliances/edit',
      builder: (context, state) {
        final appliance = state.extra as Appliance?;

        if (appliance == null) {
          return const Scaffold(
            body: Center(child: Text('Appareil introuvable.')),
          );
        }

        return ApplianceFormPage(appliance: appliance);
      },
    ),
  ],
);
