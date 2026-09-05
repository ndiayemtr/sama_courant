import '../repositories/appliance_repository.dart';

class DeleteAppliance {
  final ApplianceRepository repository;

  DeleteAppliance(this.repository);

  Future<void> call(int id) {
    return repository.delete(id);
  }
}
