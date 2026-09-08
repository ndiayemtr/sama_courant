import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sama_courant/features/budget/domain/providers/appliance_tariff_service_provider.dart';
import 'package:sama_courant/features/budget/domain/services/appliance_tariff_service.dart';
import 'package:sama_courant/features/budget/domain/services/tariff_engine.dart';

void main() {
  test('should provide a TariffEngine', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final engine = container.read(tariffEngineProvider);

    expect(engine, isA<TariffEngine>());
  });

  test('should provide an ApplianceTariffService', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final service = container.read(applianceTariffServiceProvider);

    expect(service, isA<ApplianceTariffService>());
  });
}
