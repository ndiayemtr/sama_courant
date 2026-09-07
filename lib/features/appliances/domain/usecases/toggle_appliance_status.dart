import '../entities/appliance.dart';
import '../repositories/appliance_repository.dart';

class ToggleApplianceStatus {
  final ApplianceRepository repository;

  ToggleApplianceStatus(this.repository);

  Future<bool> call(Appliance appliance) {
    final updatedAppliance = Appliance(
      id: appliance.id,
      name: appliance.name,
      category: appliance.category,
      powerWatts: appliance.powerWatts,
      quantity: appliance.quantity,
      hoursPerDay: appliance.hoursPerDay,
      daysPerMonth: appliance.daysPerMonth,
      isActive: !appliance.isActive,
      createdAt: appliance.createdAt,
      updatedAt: DateTime.now(),
    );

    return repository.update(updatedAppliance);
  }
}
