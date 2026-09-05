import '../entities/appliance.dart';
import '../repositories/appliance_repository.dart';

class UpdateAppliance {
  final ApplianceRepository repository;

  UpdateAppliance(this.repository);

  Future<bool> call(Appliance appliance) {
    return repository.update(appliance);
  }
}
