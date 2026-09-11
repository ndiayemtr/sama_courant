import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/consumption_snapshot_repository.dart';
import '../repositories/drift_consumption_snapshot_repository.dart';

final consumptionSnapshotRepositoryProvider =
    Provider<ConsumptionSnapshotRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);
      return DriftConsumptionSnapshotRepository(database);
    });
