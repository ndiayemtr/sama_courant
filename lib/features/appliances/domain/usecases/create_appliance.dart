import '../entities/appliance.dart';
import '../repositories/appliance_repository.dart';

class CreateAppliance {
  final ApplianceRepository repository;

  CreateAppliance(this.repository);

  Future<int> call(Appliance appliance) {
    return repository.create(appliance);
  }
}
