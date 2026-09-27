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
}
