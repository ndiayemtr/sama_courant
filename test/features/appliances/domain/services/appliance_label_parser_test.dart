import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_parser.dart';

void main() {
  final parser = ApplianceLabelParser();

  group('extractPowerWatts', () {
    test('extrait une puissance en watts', () {
      expect(parser.extractPowerWatts('power 180 w'), 180);
    });

    test('convertit les kilowatts en watts', () {
      expect(parser.extractPowerWatts('rated power 2.2 kw'), 2200);
    });

    test('accepte une valeur sans espace avant unité', () {
      expect(parser.extractPowerWatts('1600w'), 1600);
    });

    test('retourne null sans puissance', () {
      expect(parser.extractPowerWatts('220 v 50 hz'), isNull);
    });
  });

  group('extractVoltageVolts', () {
    test('extrait la tension', () {
      expect(parser.extractVoltageVolts('voltage 220 v'), 220);
    });

    test('ne choisit pas arbitrairement une valeur dans une plage', () {
      expect(parser.extractVoltageVolts('220-240 v'), isNull);
    });
  });

  group('extractCurrentAmps', () {
    test('extrait le courant', () {
      expect(parser.extractCurrentAmps('current 0.8 a'), 0.8);
    });
  });

  group('extractFrequencyHz', () {
    test('extrait la fréquence', () {
      expect(parser.extractFrequencyHz('frequency 50 hz'), 50);
    });
  });

  group('ranges et valeurs multiples', () {
    test('extrait une plage de tension', () {
      final range = parser.extractVoltageRange('input 220-240 v');

      expect(range, isNotNull);
      expect(range!.min, 220);
      expect(range.max, 240);
    });

    test('extrait une plage de courant', () {
      final range = parser.extractCurrentRange('current 0.8-1.2 a');

      expect(range, isNotNull);
      expect(range!.min, 0.8);
      expect(range.max, 1.2);
    });

    test('extrait les fréquences 50/60 hz', () {
      expect(parser.extractFrequencyOptions('frequency 50/60 hz'), [50, 60]);
    });

    test('retourne une liste vide pour une fréquence simple', () {
      expect(parser.extractFrequencyOptions('frequency 50 hz'), isEmpty);
    });
  });

  group('power factor', () {
    test('extrait un facteur de puissance avec PF', () {
      expect(parser.extractPowerFactor('230 v 2 a pf 0.85'), 0.85);
    });

    test('extrait un facteur de puissance explicite', () {
      expect(parser.extractPowerFactor('power factor 0.92'), 0.92);
    });

    test('rejette un facteur de puissance supérieur à 1', () {
      expect(parser.extractPowerFactor('pf 1.5'), isNull);
    });
  });

  group('consommation annuelle', () {
    test('extrait kwh par an', () {
      expect(parser.extractAnnualConsumptionKwh('250 kwh/year'), 250);
    });

    test('extrait une consommation annuelle en français normalisé', () {
      expect(
        parser.extractAnnualConsumptionKwh('consommation annuelle 180 kwh'),
        180,
      );
    });

    test('ne confond pas une simple valeur kwh avec consommation annuelle', () {
      expect(parser.extractAnnualConsumptionKwh('energy 25 kwh'), isNull);
    });
  });

  group('capacity', () {
    test('extrait une capacité en btu', () {
      expect(parser.extractCapacity('cooling capacity 12000 btu'), '12000 btu');
    });

    test('extrait une capacité en litres', () {
      expect(parser.extractCapacity('capacity 300 l'), '300 l');
    });

    test('extrait une capacité en kg', () {
      expect(parser.extractCapacity('wash capacity 8 kg'), '8 kg');
    });

    test('retourne null sans capacité reconnue', () {
      expect(parser.extractCapacity('220 v 50 hz 180 w'), isNull);
    });
  });

  group('model', () {
    test('extrait un modele avec le libelle model', () {
      expect(parser.extractModel('samsung model rt38 220 v 50 hz'), 'rt38');
    });

    test('extrait un modele avec model no', () {
      expect(parser.extractModel('model no: ac12xyz 230 v'), 'ac12xyz');
    });

    test('extrait une reference explicite', () {
      expect(
        parser.extractModel('reference hwd90-b14959 220 v'),
        'hwd90-b14959',
      );
    });

    test('extrait un modele avec modele en francais normalise', () {
      expect(parser.extractModel('modele rt42k5000s8 220 v'), 'rt42k5000s8');
    });

    test('ne devine pas un modele sans libelle explicite', () {
      expect(parser.extractModel('samsung rt38 refrigerator 220 v'), isNull);
    });

    test('retourne null si aucun modele n est present', () {
      expect(parser.extractModel('refrigerator 220 v 50 hz 180 w'), isNull);
    });
  });

  group('brand', () {
    test('extrait une marque avec brand', () {
      expect(parser.extractBrand('brand samsung model rt38'), 'samsung');
    });

    test('extrait une marque avec marque', () {
      expect(parser.extractBrand('marque lg modele abc123'), 'lg');
    });

    test('extrait une marque avec manufacturer', () {
      expect(parser.extractBrand('manufacturer haier 220 v'), 'haier');
    });

    test('extrait une marque avec fabricant', () {
      expect(parser.extractBrand('fabricant hisense 50 hz'), 'hisense');
    });

    test('ne devine pas la marque sans libelle explicite', () {
      const text = 'samsung electronics digital appliances';

      final result = parser.extractBrand(text);

      expect(result, 'samsung');
    });
    test('reste null si aucune marque connue ou explicite', () {
      const text = 'refrigerador 127v 60hz 170w';

      final result = parser.extractBrand(text);

      expect(result, isNull);
    });

    test('model extrait un modele avec le libelle espagnol modelo', () {
      const text = 'modelo: rt35k5982sl';

      final result = parser.extractModel(text);

      expect(result, 'rt35k5982sl');
    });

    test('retourne null si aucune marque n est presente', () {
      expect(parser.extractBrand('refrigerator 220 v 180 w'), isNull);
    });
  });

  group('energy consumption metrics', () {
    test('extrait une consommation annuelle kwh par annum', () {
      final metrics = parser.extractEnergyConsumptionMetrics(
        'energy 216 kwh/annum',
      );

      expect(metrics, hasLength(1));
      expect(metrics.single.valueKwh, 216);
      expect(metrics.single.basis, EnergyConsumptionBasis.perYear);
    });

    test('extrait une consommation annuelle en francais', () {
      final metrics = parser.extractEnergyConsumptionMetrics(
        'consommation annuelle 180 kwh',
      );

      expect(metrics, hasLength(1));
      expect(metrics.single.valueKwh, 180);
      expect(metrics.single.basis, EnergyConsumptionBasis.perYear);
    });

    test('extrait une consommation pour 100 cycles', () {
      final metrics = parser.extractEnergyConsumptionMetrics(
        '55 kwh/100 cycles',
      );

      expect(metrics, hasLength(1));
      expect(metrics.single.valueKwh, 55);
      expect(metrics.single.basis, EnergyConsumptionBasis.per100Cycles);
    });

    test('extrait une consommation pour 1000 heures', () {
      final metrics = parser.extractEnergyConsumptionMetrics('65 kwh/1000 h');

      expect(metrics, hasLength(1));
      expect(metrics.single.valueKwh, 65);
      expect(metrics.single.basis, EnergyConsumptionBasis.per1000Hours);
    });

    test('extrait une consommation par cycle', () {
      final metrics = parser.extractEnergyConsumptionMetrics('0.8 kwh/cycle');

      expect(metrics, hasLength(1));
      expect(metrics.single.valueKwh, 0.8);
      expect(metrics.single.basis, EnergyConsumptionBasis.perCycle);
    });

    test('peut extraire plusieurs metriques du meme texte', () {
      final metrics = parser.extractEnergyConsumptionMetrics(
        '55 kwh/100 cycles 0.8 kwh/cycle',
      );

      expect(metrics, hasLength(2));

      expect(
        metrics.map((metric) => metric.basis),
        containsAll([
          EnergyConsumptionBasis.per100Cycles,
          EnergyConsumptionBasis.perCycle,
        ]),
      );
    });

    test('ignore une valeur kwh sans base de reference', () {
      final metrics = parser.extractEnergyConsumptionMetrics(
        'energy consumption 25 kwh',
      );

      expect(metrics, isEmpty);
    });
  });

  group('capacities', () {
    test('extrait plusieurs capacites en litres', () {
      final capacities = parser.extractCapacities('375 l 105 l');

      expect(capacities, hasLength(2));

      expect(capacities[0].value, 375);
      expect(capacities[0].unit, 'l');

      expect(capacities[1].value, 105);
      expect(capacities[1].unit, 'l');
    });

    test('extrait une capacite en kg', () {
      final capacities = parser.extractCapacities('wash capacity 8 kg');

      expect(capacities, hasLength(1));
      expect(capacities.single.value, 8);
      expect(capacities.single.unit, 'kg');
    });

    test('extrait une capacite en btu', () {
      final capacities = parser.extractCapacities('cooling capacity 12000 btu');

      expect(capacities, hasLength(1));
      expect(capacities.single.value, 12000);
      expect(capacities.single.unit, 'btu');
    });
  });

  test('power extrait une puissance principale sans contexte particulier', () {
    const text = 'refrigerator 220 v 50 hz 150 w';

    final result = parser.extractPowerWatts(text);

    expect(result, 150);
  });

  test('power privilegie une puissance nominale face au degivrage', () {
    const text = 'rated power 120 w refrigerador consumo de deshielo 170 w';

    final result = parser.extractPowerWatts(text);

    expect(result, 120);
  });

  test('power ignore une puissance uniquement liee au degivrage', () {
    const text = 'refrigerador consumo de deshielo 170 w 60 hz';

    final result = parser.extractPowerWatts(text);

    expect(result, isNull);
  });

  test('power ignore une puissance de defrost', () {
    const text = 'refrigerator defrost heater 200 w 220 v 60 hz';

    final result = parser.extractPowerWatts(text);

    expect(result, isNull);
  });

  test('power convertit toujours les kilowatts', () {
    const text = 'rated power 1.5 kw';

    final result = parser.extractPowerWatts(text);

    expect(result, 1500);
  });

  test('annual consumption extrait kWh par an en espagnol', () {
    const text = 'consumo de energia en operacion 355 kwh/ano';

    final result = parser.extractAnnualConsumptionKwh(text);

    expect(result, 355);
  });

  test('energy metrics extrait kWh par an en espagnol', () {
    const text = 'consumo de energia en operacion 355 kwh/ano';

    final result = parser.extractEnergyConsumptionMetrics(text);

    expect(result, hasLength(1));
    expect(result.single.valueKwh, 355);
    expect(result.single.basis, EnergyConsumptionBasis.perYear);
  });

  test('energy metrics reconnait consumo de energia sans suffixe annuel', () {
    const text = 'consumo de energia en operacion 355 kwh';

    final result = parser.extractEnergyConsumptionMetrics(text);

    expect(result, hasLength(1));
    expect(result.single.valueKwh, 355);
    expect(result.single.basis, EnergyConsumptionBasis.perYear);
  });

  test(
    'power ignore une puissance de degivrage quand OCR separe libelle et valeur',
    () {
      const text =
          'refrigerador consumo de deshielo refrigerante '
          '127 v 60 hz 2.5 a 170 w';

      final result = parser.extractPowerWatts(text);

      expect(result, isNull);
    },
  );

  test('model extrait MODEL NO avec point', () {
    const text = 'model no.: ac-gen-4500s';

    final result = parser.extractModel(text);

    expect(result, 'ac-gen-4500s');
  });

  test('model extrait model code', () {
    const text = 'model code: ue55f6400anxzf';

    final result = parser.extractModel(text);

    expect(result, 'ue55f6400anxzf');
  });

  test('model extrait model simple', () {
    const text = 'model: uessfg400a';

    final result = parser.extractModel(text);

    expect(result, 'uessfg400a');
  });

  test('model extrait modelo espagnol', () {
    const text = 'modelo: rt35k5982sl';

    final result = parser.extractModel(text);

    expect(result, 'rt35k5982sl');
  });
}
