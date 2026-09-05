import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/appliance_repository.dart';
import '../repositories/drift_appliance_repository.dart';

final applianceRepositoryProvider = Provider<ApplianceRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftApplianceRepository(database);
});
