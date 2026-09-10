import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance.dart';
import 'package:sama_courant/features/appliances/domain/providers/appliance_usecase_providers.dart';
import 'package:sama_courant/features/appliances/domain/usecases/get_appliances.dart';
import 'package:sama_courant/features/appliances/presentation/providers/appliances_provider.dart';
import 'package:sama_courant/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../appliances/fakes/fake_appliance_repository.dart';

Appliance appliance(
  String name,
  double watts, {
  bool active = true,
  int quantity = 1,
  double hours = 10,
}) => Appliance(
  name: name,
  category: 'Maison',
  powerWatts: watts,
  quantity: quantity,
  hoursPerDay: hours,
  daysPerMonth: 30,
  isActive: active,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Future<DashboardSummary> summaryFor(List<Appliance> appliances) async {
  final repository = FakeApplianceRepository();
  for (final appliance in appliances) {
    await repository.create(appliance);
  }
  final container = ProviderContainer(
    overrides: [
      getAppliancesProvider.overrideWithValue(GetAppliances(repository)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(appliancesProvider.notifier).loadAppliances();
  return container.read(dashboardProvider);
}

void main() {
  test('recommendations cover empty and zero consumption safely', () async {
    expect(
      (await summaryFor([])).recommendations.single.message,
      'Activez ou ajoutez des appareils pour obtenir des conseils personnalisés.',
    );
    expect(
      (await summaryFor([appliance('Zéro', 0)])).recommendations.single.title,
      'Consommation nulle',
    );
  });
  test(
    'recommendations identify dominance at 70 percent and exclude inactive appliances',
    () async {
      final summary = await summaryFor([
        appliance('Grand', 700),
        appliance('Petit', 300),
        appliance('Inactif', 9999, active: false),
      ]);
      expect(summary.recommendations.single.message, contains('70,0 %'));
      expect(summary.recommendations.single.title, 'Grand');
    },
  );
  test('recommendations cover twelve hours per day', () async {
    final summary = await summaryFor([
      appliance('Long', 100, hours: 12),
      appliance('B', 120),
      appliance('C', 120),
    ]);
    expect(summary.recommendations.single.message, contains('12 h par jour'));
  });
  test('recommendations cover multiple units at thirty percent', () async {
    final summary = await summaryFor([
      appliance('Lampes', 100, quantity: 3),
      appliance('B', 350),
      appliance('C', 350),
    ]);
    expect(summary.recommendations.single.message, contains('3 unités'));
    expect(summary.recommendations.single.message, contains('30,0 %'));
  });
  test('recommendations cover top two at eighty percent', () async {
    final summary = await summaryFor([
      appliance('A', 500),
      appliance('B', 300),
      appliance('C', 200),
    ]);
    expect(
      summary.recommendations.single.message,
      contains('A et B représentent 80,0 %'),
    );
  });
  test(
    'recommendations describe balanced consumption below thresholds',
    () async {
      final summary = await summaryFor([
        appliance('A', 100),
        appliance('B', 100),
        appliance('C', 100),
      ]);
      expect(summary.recommendations.single.title, 'Répartition équilibrée');
    },
  );
  test('recommendations have stable priority and a maximum of three', () async {
    final appliances = [
      appliance('A', 700, quantity: 2, hours: 12),
      appliance('B', 100, hours: 12),
      appliance('C', 100, hours: 12),
    ];
    final first = (await summaryFor(appliances)).recommendations;
    final second = (await summaryFor(appliances)).recommendations;
    expect(first, hasLength(3));
    expect(first.map((r) => r.priority.name), ['high', 'medium', 'low']);
    expect(first.map((r) => r.message), second.map((r) => r.message));
  });
  test('recommendations retain input order for equal consumption', () async {
    final summary = await summaryFor([
      for (final name in ['Z', 'A', 'B', 'C']) appliance(name, 100, hours: 12),
    ]);
    expect(summary.recommendations.map((r) => r.title), ['Z', 'A', 'B']);
  });

  test('analysis handles no active appliances and zero consumption', () async {
    expect(
      (await summaryFor([])).analysisSummary,
      'Aucun appareil actif pour analyser la consommation.',
    );
    expect(
      (await summaryFor([
        appliance('Inactif', 900, active: false),
      ])).analysisSummary,
      'Aucun appareil actif pour analyser la consommation.',
    );
    expect(
      (await summaryFor([appliance('Zéro', 0)])).analysisSummary,
      'La consommation actuelle des appareils actifs est nulle.',
    );
  });

  test(
    'analysis describes the single active appliance and ignores inactive ones',
    () async {
      expect(
        (await summaryFor([
          appliance('Réfrigérateur', 150),
          appliance('Inactif', 900, active: false),
        ])).analysisSummary,
        'Réfrigérateur représente 100 % de votre consommation actuelle.',
      );
    },
  );

  test(
    'analysis prioritizes the largest share at the 70 percent threshold',
    () async {
      expect(
        (await summaryFor([
          appliance('Petit', 300),
          appliance('Grand', 700),
        ])).analysisSummary,
        'Votre consommation est très concentrée sur Grand, qui représente 70,0 % du total.',
      );
      expect(
        (await summaryFor([
          appliance('Grand', 500),
          appliance('Petit', 100),
        ])).analysisSummary,
        'Votre consommation est très concentrée sur Grand, qui représente 83,3 % du total.',
      );
    },
  );

  test(
    'analysis combines the first two shares at the 80 percent threshold',
    () async {
      expect(
        (await summaryFor([
          appliance('Petit', 200),
          appliance('Deuxième', 300),
          appliance('Premier', 500),
        ])).analysisSummary,
        'Premier et Deuxième représentent ensemble 80,0 % de votre consommation.',
      );
    },
  );

  test(
    'analysis describes distributed consumption below the thresholds',
    () async {
      expect(
        (await summaryFor([
          for (var i = 0; i < 6; i++) appliance('Appareil $i', 100),
        ])).analysisSummary,
        'Votre consommation est répartie entre plusieurs appareils.',
      );
    },
  );

  test('empty or inactive household has no shares', () async {
    expect((await summaryFor([])).consumptionShares, isEmpty);
    expect(
      (await summaryFor([
        appliance('Inactif', 100, active: false),
      ])).consumptionShares,
      isEmpty,
    );
  });

  test('one active appliance accounts for 100 percent', () async {
    final summary = await summaryFor([appliance('Lampe', 100)]);
    expect(summary.consumptionShares.single.consumptionKwh, 30);
    expect(summary.consumptionShares.single.percentage, 100);
  });

  test('shares are descending and exclude inactive consumption', () async {
    final summary = await summaryFor([
      appliance('Petit', 100),
      appliance('Inactif', 2000, active: false),
      appliance('Grand', 900),
    ]);
    expect(summary.consumptionShares.map((share) => share.name), [
      'Grand',
      'Petit',
    ]);
    expect(summary.consumptionShares.map((share) => share.percentage), [
      90,
      10,
    ]);
    expect(summary.consumptionKwh, 300);
    expect(summary.costFcfa, closeTo(32773.5, 1e-9));
    expect(
      summary.consumptionShares.first.allocatedCostFcfa,
      closeTo(29496.15, 1e-9),
    );
    expect(
      summary.consumptionShares.last.allocatedCostFcfa,
      closeTo(3277.35, 1e-9),
    );
    expect(
      summary.consumptionShares.fold<double>(
        0,
        (total, share) => total + share.allocatedCostFcfa,
      ),
      closeTo(summary.costFcfa, 1e-9),
    );
  });

  test(
    'keeps top five and groups all remaining consumption into Others',
    () async {
      final summary = await summaryFor([
        for (var i = 1; i <= 8; i++) appliance('Appareil $i', i * 100),
        appliance('Inactif', 9999, active: false),
      ]);
      final shares = summary.consumptionShares;
      expect(shares.map((share) => share.name), [
        'Appareil 8',
        'Appareil 7',
        'Appareil 6',
        'Appareil 5',
        'Appareil 4',
        'Autres',
      ]);
      expect(shares.last.consumptionKwh, 180);
      expect(shares.last.percentage, closeTo(100 / 6, 1e-9));
      expect(
        shares.fold<double>(0, (sum, share) => sum + share.consumptionKwh),
        summary.consumptionKwh,
      );
      expect(
        shares.fold<double>(0, (sum, share) => sum + share.percentage),
        closeTo(100, 1e-9),
      );
    },
  );

  test('exactly five appliances do not create Others', () async {
    final summary = await summaryFor([
      for (var i = 1; i <= 5; i++) appliance('$i', i * 100),
    ]);
    expect(summary.consumptionShares, hasLength(5));
    expect(
      summary.consumptionShares.any((share) => share.name == 'Autres'),
      isFalse,
    );
  });

  test('zero total produces empty shares without division by zero', () async {
    final summary = await summaryFor([appliance('Zéro', 0)]);
    expect(summary.consumptionKwh, 0);
    expect(summary.costFcfa, 0);
    expect(summary.consumptionShares, isEmpty);
  });
}
