import 'package:flutter_test/flutter_test.dart';
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
}
