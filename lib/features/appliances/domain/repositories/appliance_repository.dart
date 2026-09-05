import '../entities/appliance.dart';

abstract interface class ApplianceRepository {
  Future<List<Appliance>> getAll();

  Future<Appliance?> getById(int id);

  Future<int> create(Appliance appliance);

  Future<bool> update(Appliance appliance);

  Future<void> delete(int id);
}
