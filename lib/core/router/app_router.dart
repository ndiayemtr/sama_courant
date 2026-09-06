import 'package:go_router/go_router.dart';

import '../../features/appliances/presentation/pages/appliance_form_page.dart';
import '../../features/appliances/presentation/pages/appliances_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
    GoRoute(
      path: '/appliances/add',
      builder: (context, state) => const ApplianceFormPage(),
    ),
    GoRoute(
      path: '/appliances',
      builder: (context, state) => const AppliancesPage(),
    ),
  ],
);
