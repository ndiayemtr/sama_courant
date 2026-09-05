import '../entities/appliance.dart';
import '../repositories/appliance_repository.dart';

class GetAppliances {
  final ApplianceRepository repository;

  GetAppliances(this.repository);

  Future<List<Appliance>> call() {
    return repository.getAll();
  }
}
