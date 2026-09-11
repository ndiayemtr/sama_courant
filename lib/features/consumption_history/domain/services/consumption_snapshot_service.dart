import '../../../appliances/domain/entities/appliance.dart';
import '../../../budget/domain/entities/tariff_configuration.dart';
import '../../../budget/domain/services/appliance_tariff_service.dart';
import '../entities/consumption_snapshot.dart';
import '../repositories/consumption_snapshot_repository.dart';

class ConsumptionSnapshotService {
  final ConsumptionSnapshotRepository repository;
  final ApplianceTariffService tariffService;

  const ConsumptionSnapshotService({
    required this.repository,
    required this.tariffService,
  });

  Future<int> capture({
    required List<Appliance> appliances,
    required TariffConfiguration configuration,
    DateTime? capturedAt,
  }) async {
    final now = DateTime.now();
    final active = appliances.where((appliance) => appliance.isActive).toList();
    final consumption = active.fold<double>(
      0,
      (total, appliance) => total + appliance.monthlyConsumptionKwh,
    );
    final cost = active.isEmpty
        ? 0.0
        : tariffService
              .calculateCost(
                consumptionKwh: consumption,
                configuration: configuration,
              )
              .totalCost;
    return repository.create(
      ConsumptionSnapshot(
        capturedAt: capturedAt ?? now,
        totalMonthlyConsumptionKwh: consumption,
        totalMonthlyCostFcfa: cost,
        activeAppliancesCount: active.length,
        tariffConfigurationName: configuration.name,
        createdAt: now,
      ),
    );
  }
}
