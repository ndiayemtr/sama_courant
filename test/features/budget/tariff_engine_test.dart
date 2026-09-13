import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/budget/data/factories/woyofal_tariff_configuration_factory.dart';

import 'package:sama_courant/features/budget/data/services/tariff_engine_impl.dart';
import 'package:sama_courant/features/budget/domain/entities/billing_mode.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_calculation_method.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_component_type.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_configuration.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_taxable_base.dart';
import 'package:sama_courant/features/budget/domain/entities/tariff_tier.dart';

void main() {
  const engine = TariffEngineImpl();
  test(
    'additional configured charges coexist with official VAT without double counting',
    () {
      final official = WoyofalTariffConfigurationFactory.dpp2026();
      expect(official.components, hasLength(1));
      final baseline = engine.calculate(
        consumptionKwh: 300,
        configuration: official,
      );
      expect(baseline.energyCost, closeTo(32773.5, 1e-8));
      expect(baseline.taxes, closeTo(1228.41, 1e-8));
      expect(baseline.totalCost, closeTo(34001.91, 1e-8));
      // Synthetic charges belong to this test configuration only.
      final additions = [
        for (final type in [TariffComponentType.fee, TariffComponentType.tax])
          for (final method in TariffCalculationMethod.values)
            TariffComponent(
              name: 'Test ${type.name} ${method.name}',
              type: type,
              calculationMethod: method,
              value: 1,
              unit: 'test',
              taxableBase: TariffTaxableBase.energy,
              thresholdKwh: method == TariffCalculationMethod.perKwh
                  ? 250
                  : null,
              includedInTariff: false,
            ),
        const TariffComponent(
          name: 'Incluse',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: true,
        ),
        const TariffComponent(
          name: 'Inactive',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 100,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
          enabled: false,
        ),
      ];
      for (final components in [
        [...official.components, ...additions],
        [...additions.reversed, ...official.components],
      ]) {
        final config = TariffConfiguration(
          name: 'Test',
          customerCategory: official.customerCategory,
          billingMode: official.billingMode,
          tiers: official.tiers,
          effectiveFrom: official.effectiveFrom,
          effectiveTo: null,
          isActive: true,
          components: components,
        );
        final result = engine.calculate(
          consumptionKwh: 300,
          configuration: config,
        );
        expect(result.fees, closeTo(378.735, 1e-8));
        expect(result.taxes, closeTo(1607.145, 1e-8));
        expect(result.totalCost, closeTo(34759.38, 1e-8));
        expect(config.components, hasLength(9));
        final details = [...result.feeCalculations, ...result.taxCalculations];
        expect(details, hasLength(7));
        for (final detail in details) {
          final source = config.components.singleWhere(
            (c) => c.name == detail.name,
          );
          expect(detail.enabled, source.enabled);
          expect(detail.includedInTariff, source.includedInTariff);
          expect(detail.taxableBase, source.taxableBase);
          expect(detail.thresholdKwh, source.thresholdKwh);
          expect(detail.value, source.value);
          expect(detail.calculationMethod, source.calculationMethod);
          expect(detail.includedInTotal, isTrue);
        }
        expect(
          result.totalCost,
          closeTo(
            result.energyCost +
                details.fold<double>(0, (sum, c) => sum + c.amount),
            1e-8,
          ),
        );
      }
    },
  );
  test(
    'excess energy basis spans actual tier prices without changing global percentages',
    () {
      final configuration = TariffConfiguration(
        name: 'Test',
        customerCategory: 'Test',
        billingMode: BillingMode.woyofal,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: 100, pricePerKwh: 2, tierOrder: 1),
          TariffTier(minKwh: 100, maxKwh: null, pricePerKwh: 5, tierOrder: 2),
        ],
        effectiveFrom: DateTime(2026),
        effectiveTo: null,
        isActive: true,
        components: [
          for (final base in [
            TariffTaxableBase.energy,
            TariffTaxableBase.excessEnergyCost,
          ])
            TariffComponent(
              name: base.name,
              type: TariffComponentType.tax,
              calculationMethod: TariffCalculationMethod.percentage,
              value: 10,
              unit: '%',
              taxableBase: base,
              thresholdKwh: 50,
              includedInTariff: false,
            ),
        ],
      );
      final result = engine.calculate(
        consumptionKwh: 150,
        configuration: configuration,
      );
      expect(result.energyCost, 450);
      expect(result.taxCalculations.map((item) => item.baseAmount), [450, 350]);
      expect(result.totalCost, 530);
    },
  );

  TariffComponent component(
    TariffCalculationMethod method, {
    bool enabled = true,
    bool included = false,
    double? threshold,
    TariffComponentType type = TariffComponentType.fee,
    TariffTaxableBase? base,
  }) => TariffComponent(
    name: 'Test $method',
    type: type,
    calculationMethod: method,
    value: 10,
    unit: 'test',
    taxableBase: base,
    includedInTariff: included,
    enabled: enabled,
    thresholdKwh: threshold,
  );
  TariffConfiguration configured(List<TariffComponent> components) =>
      TariffConfiguration(
        name: 'Test générique',
        customerCategory: 'Test',
        billingMode: BillingMode.woyofal,
        tiers: const [
          TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 2, tierOrder: 1),
          TariffTier(minKwh: 50, maxKwh: null, pricePerKwh: 4, tierOrder: 2),
        ],
        effectiveFrom: DateTime(2026),
        effectiveTo: null,
        isActive: true,
        components: components,
      );

  for (final type in [TariffComponentType.fee, TariffComponentType.tax]) {
    for (final method in TariffCalculationMethod.values) {
      for (final consumption in [0.0, 50.0, 100.0]) {
        for (final threshold in <double?>[null, 50]) {
          test(
            '$type $method at $consumption kWh with threshold $threshold',
            () {
              final result = engine.calculate(
                consumptionKwh: consumption,
                configuration: configured([
                  component(method, type: type, threshold: threshold),
                ]),
              );
              final energy = consumption == 100 ? 300.0 : consumption * 2;
              final applies = threshold == null || consumption > threshold;
              final expected = !applies
                  ? 0.0
                  : switch (method) {
                      TariffCalculationMethod.fixed => 10.0,
                      TariffCalculationMethod.perKwh =>
                        (consumption - (threshold ?? 0)) * 10,
                      TariffCalculationMethod.percentage => energy * 0.1,
                    };
              expect(result.energyCost, energy);
              expect(result.totalCost, energy + expected);
              final details = [
                ...result.feeCalculations,
                ...result.taxCalculations,
              ];
              expect(
                details.fold<double>(0, (sum, item) => sum + item.amount),
                expected,
              );
              for (final detail in details) {
                expect(detail.calculationMethod, method);
                expect(detail.type, type);
                expect(detail.includedInTotal, isTrue);
              }
            },
          );
        }
      }
      for (final included in [false, true]) {
        test(
          '$type $method is excluded when ${included ? 'included' : 'disabled'}',
          () {
            final result = engine.calculate(
              consumptionKwh: 100,
              configuration: configured([
                component(
                  method,
                  type: type,
                  included: included,
                  enabled: included,
                ),
              ]),
            );
            expect(result.totalCost, 300);
            expect(result.feeCalculations, isEmpty);
            expect(result.taxCalculations, isEmpty);
          },
        );
      }
    }
  }

  test(
    'combines components once with explicit tax base and stable fee base',
    () {
      final components = [
        component(TariffCalculationMethod.fixed),
        component(TariffCalculationMethod.perKwh, threshold: 50),
        component(TariffCalculationMethod.percentage),
        component(
          TariffCalculationMethod.percentage,
          type: TariffComponentType.tax,
          base: TariffTaxableBase.energyAndFees,
        ),
        component(TariffCalculationMethod.fixed, included: true),
        component(TariffCalculationMethod.fixed, enabled: false),
      ];
      for (final ordered in [components, components.reversed.toList()]) {
        final result = engine.calculate(
          consumptionKwh: 100,
          configuration: configured(ordered),
        );
        expect(result.energyCost, 300);
        expect(result.fees, 540);
        expect(result.taxes, 84);
        expect(result.totalCost, 924);
        expect(result.feeCalculations, hasLength(3));
        expect(result.taxCalculations, hasLength(1));
      }
    },
  );

  group('TariffEngineImpl', () {
    final configuration = TariffConfiguration(
      name: 'Configuration de test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: 150, pricePerKwh: 136.49, tierOrder: 2),
        TariffTier(minKwh: 150, maxKwh: null, pricePerKwh: 159, tierOrder: 3),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
      components: const [],
    );

    test('calculates energy cost using tariff tiers', () {
      final result = engine.calculate(
        consumptionKwh: 100,
        configuration: configuration,
      );

      expect(result.consumptionKwh, 100);
      expect(result.tierCalculations, hasLength(2));

      expect(result.energyCost, closeTo(10924.5, 0.001));
      expect(result.totalCost, closeTo(10924.5, 0.001));
    });

    test('returns zero cost for zero consumption', () {
      final result = engine.calculate(
        consumptionKwh: 0,
        configuration: configuration,
      );

      expect(result.consumptionKwh, 0);
      expect(result.energyCost, 0);
      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, 0);
      expect(result.tierCalculations, isEmpty);
    });

    test('calculates all three tiers', () {
      final result = engine.calculate(
        consumptionKwh: 200,
        configuration: configuration,
      );

      expect(result.tierCalculations, hasLength(3));

      expect(result.energyCost, closeTo(25699, 0.001));

      expect(result.totalCost, closeTo(25699, 0.001));
    });

    test('does not add fees or taxes yet', () {
      final result = engine.calculate(
        consumptionKwh: 100,
        configuration: configuration,
      );

      expect(result.fees, 0);
      expect(result.taxes, 0);
      expect(result.totalCost, result.energyCost);
    });
  });

  test('adds fees to the energy cost', () {
    final configuration = TariffConfiguration(
      name: 'Configuration avec frais',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: null, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = engine.calculate(
      consumptionKwh: 100,
      configuration: configuration,
    );

    expect(result.energyCost, closeTo(10924.5, 0.001));
    expect(result.fees, closeTo(70.0, 0.001));
    expect(result.taxes, 0);
    expect(result.totalCost, closeTo(10994.5, 0.001));
  });

  test('calculates energy, fees, taxes and total cost', () {
    final configuration = TariffConfiguration(
      name: 'Configuration complète',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: null, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Taxe test',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energyAndFees,
          includedInTariff: false,
        ),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = engine.calculate(
      consumptionKwh: 100,
      configuration: configuration,
    );

    expect(result.energyCost, closeTo(10924.5, 0.001));
    expect(result.fees, closeTo(70.0, 0.001));

    final taxableBase = 10924.5 + 70;
    final expectedTax = taxableBase * 0.10;

    expect(result.taxes, closeTo(expectedTax, 0.001));
    expect(result.totalCost, closeTo(10924.5 + 70 + expectedTax, 0.001));
  });

  test('should return complete tariff breakdown', () {
    const engine = TariffEngineImpl();

    final configuration = TariffConfiguration(
      name: 'Configuration test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: null, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Taxe test',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energy,
          includedInTariff: false,
        ),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = engine.calculate(
      consumptionKwh: 100,
      configuration: configuration,
    );

    expect(result.consumptionKwh, 100);

    expect(result.tierCalculations.length, 2);

    expect(result.feeCalculations.length, 1);
    expect(result.feeCalculations.first.name, 'Redevance');
    expect(result.feeCalculations.first.amount, 70);

    expect(result.taxCalculations.length, 1);
    expect(result.taxCalculations.first.name, 'Taxe test');

    expect(result.fees, 70);

    expect(result.taxes, result.energyCost * 0.10);

    expect(result.totalCost, result.energyCost + result.fees + result.taxes);
  });

  test('should keep totals consistent with breakdowns', () {
    const engine = TariffEngineImpl();

    final configuration = TariffConfiguration(
      name: 'Configuration test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: 50, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 50, maxKwh: null, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [
        TariffComponent(
          name: 'Redevance',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.perKwh,
          value: 0.7,
          unit: 'FCFA/kWh',
          taxableBase: null,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Frais fixe',
          type: TariffComponentType.fee,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 500,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Taxe énergie',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.percentage,
          value: 10,
          unit: '%',
          taxableBase: TariffTaxableBase.energy,
          includedInTariff: false,
        ),
        TariffComponent(
          name: 'Taxe fixe',
          type: TariffComponentType.tax,
          calculationMethod: TariffCalculationMethod.fixed,
          value: 250,
          unit: 'FCFA',
          taxableBase: null,
          includedInTariff: false,
        ),
      ],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = engine.calculate(
      consumptionKwh: 100,
      configuration: configuration,
    );

    final feeTotal = result.feeCalculations.fold<double>(
      0,
      (sum, calculation) => sum + calculation.amount,
    );

    final taxTotal = result.taxCalculations.fold<double>(
      0,
      (sum, calculation) => sum + calculation.amount,
    );

    final energyTotal = result.tierCalculations.fold<double>(
      0,
      (sum, calculation) => sum + calculation.cost,
    );

    expect(result.energyCost, energyTotal);
    expect(result.fees, feeTotal);
    expect(result.taxes, taxTotal);
    expect(result.totalCost, result.energyCost + result.fees + result.taxes);
  });

  test('should calculate energy only when there are no fees or taxes', () {
    const engine = TariffEngineImpl();

    final configuration = TariffConfiguration(
      name: 'Énergie uniquement',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    final result = engine.calculate(
      consumptionKwh: 100,
      configuration: configuration,
    );

    expect(result.energyCost, 8200);
    expect(result.fees, 0);
    expect(result.taxes, 0);
    expect(result.totalCost, 8200);
    expect(result.feeCalculations, isEmpty);
    expect(result.taxCalculations, isEmpty);
  });

  test('should reject negative consumption', () {
    final configuration = TariffConfiguration(
      name: 'Configuration test',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    expect(
      () => engine.calculate(consumptionKwh: -1, configuration: configuration),
      throwsArgumentError,
    );
  });

  test('should reject an invalid tariff configuration', () {
    final configuration = TariffConfiguration(
      name: 'Configuration invalide',
      customerCategory: 'DPP',
      billingMode: BillingMode.woyofal,
      tiers: const [
        TariffTier(minKwh: 0, maxKwh: null, pricePerKwh: 82, tierOrder: 1),
        TariffTier(minKwh: 150, maxKwh: 250, pricePerKwh: 136.49, tierOrder: 2),
      ],
      components: const [],
      effectiveFrom: DateTime(2026, 1, 1),
      effectiveTo: null,
      isActive: true,
    );

    expect(
      () => engine.calculate(consumptionKwh: 200, configuration: configuration),
      throwsArgumentError,
    );
  });
}
