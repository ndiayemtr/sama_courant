import '../entities/consumption_snapshot.dart';

abstract interface class ConsumptionSnapshotRepository {
  /// Snapshots ordered by capture time, newest first.
  Future<List<ConsumptionSnapshot>> getAll();

  Future<ConsumptionSnapshot?> getById(int id);

  Future<ConsumptionSnapshot?> getLatest();

  Future<int> create(ConsumptionSnapshot snapshot);
}
