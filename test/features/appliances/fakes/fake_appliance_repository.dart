import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/repositories/appliance_repository.dart';

class FakeApplianceRepository implements ApplianceRepository {
  final List<Appliance> _appliances = [];

  int _nextId = 1;

  @override
  Future<List<Appliance>> getAll() async {
    return List.unmodifiable(_appliances);
  }

  @override
  Future<Appliance?> getById(int id) async {
    for (final appliance in _appliances) {
      if (appliance.id == id) {
        return appliance;
      }
    }

    return null;
  }

  @override
  Future<int> create(Appliance appliance) async {
    final id = _nextId++;

    final createdAppliance = Appliance(
      id: id,
      name: appliance.name,
      category: appliance.category,
      powerWatts: appliance.powerWatts,
      quantity: appliance.quantity,
      hoursPerDay: appliance.hoursPerDay,
      daysPerMonth: appliance.daysPerMonth,
      isActive: appliance.isActive,
      createdAt: appliance.createdAt,
      updatedAt: appliance.updatedAt,
    );

    _appliances.add(createdAppliance);

    return id;
  }

  @override
  Future<bool> update(Appliance appliance) async {
    if (appliance.id == null) {
      return false;
    }

    final index = _appliances.indexWhere((item) => item.id == appliance.id);

    if (index == -1) {
      return false;
    }

    _appliances[index] = appliance;

    return true;
  }

  @override
  Future<void> delete(int id) async {
    _appliances.removeWhere((appliance) => appliance.id == id);
  }
}
