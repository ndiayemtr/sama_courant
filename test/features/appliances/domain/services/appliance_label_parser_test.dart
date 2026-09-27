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
}
