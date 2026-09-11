import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/consumption_snapshot_repository_provider.dart';
import '../../domain/entities/consumption_snapshot.dart';

/// The repository supplies snapshots in descending capture order.
final consumptionHistoryProvider =
    FutureProvider.autoDispose<List<ConsumptionSnapshot>>(
      (ref) => ref.watch(consumptionSnapshotRepositoryProvider).getAll(),
      retry: (_, _) => null,
    );
