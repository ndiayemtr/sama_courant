import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/dashboard/presentation/utils/appliance_chart_colors.dart';

void main() {
  test('same appliance id always returns the same color', () {
    final first = ApplianceChartColors.forApplianceId(42, 'Télévision');
    final second = ApplianceChartColors.forApplianceId(42, 'Télévision');

    expect(second, first);
  });

  test('appliance color does not depend on its name when id is available', () {
    final first = ApplianceChartColors.forApplianceId(7, 'Ancien nom');
    final second = ApplianceChartColors.forApplianceId(7, 'Nouveau nom');

    expect(second, first);
  });

  test('different appliance ids can map to different palette colors', () {
    final first = ApplianceChartColors.forApplianceId(1, 'A');
    final second = ApplianceChartColors.forApplianceId(2, 'B');

    expect(second, isNot(first));
  });

  test('Others uses the fallback color', () {
    final first = ApplianceChartColors.forApplianceId(null, 'Autres');
    final second = ApplianceChartColors.forApplianceId(null, 'Autres');

    expect(second, first);
  });

  test('fallback based on name is deterministic when id is missing', () {
    final first = ApplianceChartColors.forApplianceId(null, 'Ventilateur');
    final second = ApplianceChartColors.forApplianceId(null, 'Ventilateur');

    expect(second, first);
  });
}
