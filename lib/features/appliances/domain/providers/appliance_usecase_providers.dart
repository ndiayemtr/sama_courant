import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/appliance_repository_provider.dart';
import '../usecases/create_appliance.dart';
import '../usecases/delete_appliance.dart';
import '../usecases/get_appliances.dart';
import '../usecases/update_appliance.dart';

final createApplianceProvider = Provider<CreateAppliance>((ref) {
  final repository = ref.watch(applianceRepositoryProvider);

  return CreateAppliance(repository);
});

final getAppliancesProvider = Provider<GetAppliances>((ref) {
  final repository = ref.watch(applianceRepositoryProvider);

  return GetAppliances(repository);
});

final updateApplianceProvider = Provider<UpdateAppliance>((ref) {
  final repository = ref.watch(applianceRepositoryProvider);

  return UpdateAppliance(repository);
});

final deleteApplianceProvider = Provider<DeleteAppliance>((ref) {
  final repository = ref.watch(applianceRepositoryProvider);

  return DeleteAppliance(repository);
});
