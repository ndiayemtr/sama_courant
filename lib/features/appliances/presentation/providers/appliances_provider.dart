import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/appliances_notifier.dart';
import '../state/appliances_state.dart';

final appliancesProvider =
    NotifierProvider<AppliancesNotifier, AppliancesState>(
      AppliancesNotifier.new,
    );
