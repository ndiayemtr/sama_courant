import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/tariff_engine_impl.dart';
import '../services/appliance_tariff_service.dart';
import '../services/tariff_engine.dart';

final tariffEngineProvider = Provider<TariffEngine>((ref) {
  return const TariffEngineImpl();
});

final applianceTariffServiceProvider = Provider<ApplianceTariffService>((ref) {
  final tariffEngine = ref.watch(tariffEngineProvider);

  return ApplianceTariffService(tariffEngine: tariffEngine);
});
