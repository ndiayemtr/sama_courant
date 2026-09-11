import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budget/domain/providers/appliance_tariff_service_provider.dart';
import '../../data/providers/consumption_snapshot_repository_provider.dart';
import '../services/consumption_snapshot_service.dart';

final consumptionSnapshotServiceProvider = Provider<ConsumptionSnapshotService>(
  (ref) {
    return ConsumptionSnapshotService(
      repository: ref.watch(consumptionSnapshotRepositoryProvider),
      tariffService: ref.watch(applianceTariffServiceProvider),
    );
  },
);
