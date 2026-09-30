import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/appliance_label_type.dart';
import 'package:sama_courant/features/appliances/domain/entities/confidence_level.dart';
import 'package:sama_courant/features/appliances/domain/entities/power_source.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_parser.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_normalizer.dart';
import '../usecases/scan_appliance_label_test.dart' show createUseCase;

void main() {
  const parser = ApplianceLabelParser();
  const normalizer = LabelTextNormalizer();

  test(
    'real disordered AC OCR associates model without changing power',
    () async {
      const raw = '''VOLTAGE: 115V AC
AMPS: 8.5A
980 W
WATTS:
MODEL NO.:
SERIAL NO.:
AC-GEN-4500S
12345678
REFRIGERANT: R-410A
LOW 250 PSIG
DESIGN PRESSURE: HIGH 550 PSIG
...''';
      final result = await createUseCase(raw)('photo');
      expect(result.model, 'ac-gen-4500s');
      expect(result.applianceType, 'air_conditioner');
      expect(result.powerWatts, 980.0);
      expect(result.powerSource, PowerSource.detected);
      expect(result.confidenceLevel, ConfidenceLevel.high);
    },
  );

  test('exact ML Kit Samsung text with remote labels', () async {
    const raw = '''SAMSUNG REFRIGERADOR
MODELO: RT35K5982SL
HECHO EN MÉXICO
VOLTAJE DE ALIMENTACIÓN:
SAMSUNG ELECTRONICS DIGITAL APPLIANCES MÉXICO,S.A DE C.V.
CORRIENTE:
CONSUMO DE DESHIELO:
REFRIGERANTE:
AGENTE ESPUMANTE:
CONSUiiO DE ENERGİA EN OPERACION:
SIN: OAMCABAHO12P
CE
ERN
Rev.02
NOM ANC
PAGOV
127V~, soHz
2,5 A
170 W
R-600a (52g)
CICLOPENTANO
355 kWhiaño''';
    final normalized = normalizer.normalize(raw, preserveLines: true);
    expect(normalized.split('\n'), hasLength(raw.split('\n').length));
    expect(normalized, contains('2.5 a\n170 w\nr-600a'));
    expect(parser.extractPowerWatts(normalized), isNull);
    final candidate = parser.extractPowerCandidates(normalized).single;
    expect(candidate.score, lessThan(0));
    expect(candidate.context, contains('deshielo'));
    final result = await createUseCase(raw)('photo');
    expect(result.rawOcrText, raw);
    expect(result.applianceType, 'refrigerator');
    expect(result.voltageVolts, 127);
    expect(result.currentAmps, 2.5);
    expect(result.powerWatts, 317.5);
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.medium);
    expect(result.energyConsumptionMetrics, hasLength(1));
    expect(result.energyConsumptionMetrics.single.valueKwh, 355);
    expect(
      result.energyConsumptionMetrics.single.basis,
      EnergyConsumptionBasis.perYear,
    );
    expect(result.annualConsumptionKwh, 355);
  });

  test('Samsung ML Kit annual energy with l separator', () async {
    const raw = '''SAMSUNG REFRIGERADOR
MODELO: RT35K5982SL
HECHO EN MÉXICO
VOLTAJE DE ALIMENTACIÓN:
SAMSUNG ELECTRONICS DIGITAL APPLIANCES MÉXICO,S.A DE C.V.
CORRIENTE:
CONSUMO DE DESHIELO:
REFRIGERANTE:
AGENTE ESPUMANTE:
CONSUiiO DE ENERGİA EN OPERACION:
SIN: OAMCABAHO12P
CE
ERN
Rev.02
NOM ANC
PAGOV
127V~, soHz
2,5 A
170 W
R-600a (52g)
CICLOPENTANO
355 kWhlaño''';
    final result = await createUseCase(raw)('photo');
    expect(result.applianceType, 'refrigerator');
    expect(result.powerWatts, 317.5);
    expect(result.powerSource, PowerSource.calculated);
    expect(result.confidenceLevel, ConfidenceLevel.medium);
    expect(result.energyConsumptionMetrics, hasLength(1));
    expect(result.energyConsumptionMetrics.single.valueKwh, 355);
    expect(
      result.energyConsumptionMetrics.single.basis,
      EnergyConsumptionBasis.perYear,
    );
  });

  for (final unit in [
    'kWh/año',
    'kWh año',
    'kWhiaño',
    'kWh/ano',
    'kWh ano',
    'kWhiano',
  ]) {
    test('real annual OCR unit $unit', () {
      final text = normalizer.normalize('355 $unit', preserveLines: true);
      final metric = parser.extractEnergyConsumptionMetrics(text).single;
      expect(metric.valueKwh, 355);
      expect(metric.basis, EnergyConsumptionBasis.perYear);
    });
  }
  for (final secondary in [
    'deshielo',
    'defrost',
    'heater',
    'standby',
    'veille',
  ]) {
    test('remote secondary $secondary rejects the only wattage', () {
      expect(
        parser.extractPowerWatts('$secondary\nmodel ab12\n127 v\n2.5 a\n170 w'),
        isNull,
      );
      expect(
        parser.extractPowerWatts('170 w\n127 v\nmodel ab12\n$secondary'),
        isNull,
      );
      expect(
        parser.extractPowerWatts('$secondary\nmodel ab12\nrated input 120 w'),
        120,
      );
      expect(
        parser.extractPowerWatts(
          '$secondary 170 w\nmodel ab12\nrated input 120 w',
        ),
        120,
      );
    });
  }
  test(
    'a remote primary label prevents guessing the only wattage is secondary',
    () {
      expect(
        parser.extractPowerWatts(
          'defrost\nrated input\nmodel ab12\n127 v\n120 w',
        ),
        120,
      );
      expect(parser.extractPowerWatts('model ab12\n127 v\n170 w'), 170);
      expect(normalizer.normalize('model kwhiano123'), 'model kwhiano123');
    },
  );

  test(
    'real Spanish refrigerator excludes defrost and retains annual energy',
    () async {
      final result = await createUseCase('''SAMSUNG
REFRIGERADOR
MODELO: RT35K5982SL
127V
2,5 A
170 W
CONSUMO DE DESHIELO
CONSUMO DE ENERGIA EN OPERACION
355 kWh/año''')('photo');
      expect(result.applianceType, 'refrigerator');
      expect(result.model, 'rt35k5982sl');
      expect(result.powerWatts, 317.5);
      expect(result.powerSource, PowerSource.calculated);
      expect(result.confidenceLevel, ConfidenceLevel.medium);
      expect(result.annualConsumptionKwh, 355);
      expect(result.energyConsumptionMetrics, hasLength(1));
      expect(result.labelType, ApplianceLabelType.mixed);
    },
  );

  test('real AC label prefers watts over voltage times current', () async {
    final result = await createUseCase('''VOLTAGE: 115V AC
AMPS: 8.5A
WATTS: 980 W
MODEL NO.: AC-GEN-4500S
REFRIGERANT: R-410A''')('photo');
    expect(result.model, 'ac-gen-4500s');
    expect(result.applianceType, 'air_conditioner');
    expect(result.powerWatts, 980);
    expect(result.powerSource, PowerSource.detected);
  });

  test(
    'real TV label prefers typical and model code without guessing type',
    () async {
      final result = await createUseCase('''SAMSUNG
AC220-240V 50/60Hz 150W
Typical power : 75W
Model : UESORG400AW
Model Code: UE55F6400AWXZF
Type No.: ...''')('photo');
      expect(result.model, 'ue55f6400awxzf');
      expect(result.applianceType, isNull);
      expect(result.powerWatts, 75);
      expect(result.voltageRange!.min, 220);
      expect(result.frequencyOptions, [50, 60]);
    },
  );

  test(
    'real incomplete AEG energy label retains capacity without inventing basis',
    () async {
      final result = await createUseCase('AEG\n45 kWh\n7,0 kg\n3:20\n74 dB')(
        'photo',
      );
      expect(result.energyConsumptionMetrics, isEmpty);
      expect(result.annualConsumptionKwh, isNull);
      expect(result.powerWatts, isNull);
      expect(result.confidenceLevel, ConfidenceLevel.low);
      expect(result.capacities.single.value, 7);
      expect(result.labelType, ApplianceLabelType.energyLabel);
    },
  );

  for (final text in ['', 'refrigerant', 'r410a', 'split', '7 kg']) {
    test('insufficient classification evidence: $text', () async {
      final result = await createUseCase(text)('photo');
      expect(result.applianceType, isNull);
      expect(result.powerWatts, isNull);
    });
  }
  for (final suffix in ['año', 'an', 'année', 'year', 'yr', 'an0', 'a o']) {
    test('annual suffix $suffix', () {
      final text = normalizer.normalize('355 kWh/$suffix');
      expect(parser.extractAnnualConsumptionKwh(text), 355);
      expect(parser.extractEnergyConsumptionMetrics(text).single.valueKwh, 355);
    });
  }
  test('targeted OCR energy correction', () {
    expect(
      parser.extractAnnualConsumptionKwh(normalizer.normalize('355 kVWhiaño')),
      355,
    );
    expect(normalizer.normalize('a o model ABC0'), 'a o model abc0');
  });
  for (final label in [
    'Model',
    'Model No',
    'Model No.',
    'Model Number',
    'Model Code',
    'Modèle',
    'Modelo',
    'Reference',
    'Ref',
    'Mod3l',
  ]) {
    test('explicit model label $label', () {
      expect(
        parser.extractModel(normalizer.normalize('$label:AC-GEN-4500S')),
        'ac-gen-4500s',
      );
    });
  }
  test('model code wins over model number and preserves valid identifiers', () {
    expect(
      parser.extractModel(
        normalizer.normalize('Model No: WRONG123 Model Code: AB_123'),
      ),
      'ab_123',
    );
    expect(parser.extractModel('refrigerator'), isNull);
  });
  test('power contexts do not contaminate following readings', () {
    expect(parser.extractPowerWatts('defrost 170 w rated input 120 w'), 120);
    expect(parser.extractPowerWatts('rated input 120 w standby 1 w'), 120);
    expect(parser.extractPowerWatts('150 w typical power 75 w'), 75);
    expect(parser.extractPowerWatts('max power 200 w rated input 100 w'), 100);
    expect(parser.extractPowerWatts('170 w defrost'), isNull);
    expect(parser.extractPowerWatts('100 w 200 w'), isNull);
    expect(parser.extractPowerWatts('45 kwh/100 cycles'), isNull);
  });
  test('adjacent standalone labels preserve secondary power context', () {
    expect(parser.extractPowerWatts('defrost\n170 w\nrated power\n120 w'), 120);
    expect(
      parser.extractPowerCandidates('rated power 120 w\nstandby 1 w'),
      hasLength(2),
    );
  });
  for (final base in ['100 cycles', 'cycle', '1000h', '1000 hours']) {
    test('explicit energy base $base', () {
      expect(
        parser.extractEnergyConsumptionMetrics('45 kwh/ $base'),
        hasLength(1),
      );
    });
  }
}
