import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_parser.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_normalizer.dart';
import '../usecases/scan_appliance_label_test.dart' show createUseCase;

void main() {
  const parser = ApplianceLabelParser();
  const normalizer = LabelTextNormalizer();
  String? model(String text) =>
      parser.extractModel(normalizer.normalize(text, preserveLines: true));

  test('model code accepts its immediately preceding identifier', () {
    expect(model('UE55F6400AWXZF\nModel Code:'), 'ue55f6400awxzf');
    expect(model('XY_12/3.4-Z\nModel Code:'), 'xy_12/3.4-z');
    expect(
      model('UE55F6400AWXZF\nModel Code:\n02\nVersion No'),
      'ue55f6400awxzf',
    );
  });
  for (final value in [
    '75W',
    '220-240V',
    'AC220-240V',
    '12345678',
    '50/60Hz',
    '8.5A',
    '250PSIG',
    '35C',
    '7kg',
    '12000BTU/h',
    'R-410A',
    'Version',
    'Serial',
    'Type',
    'SAMSUNG',
    'SIN: ZANY3SAD800581E',
    'Serial-AB123',
  ]) {
    test('preceding model code rejects $value', () {
      expect(model('$value\nModel Code:'), isNull);
      expect(model('Model: TV123\n...\n$value\nModel Code:'), 'tv123');
    });
  }
  for (final label in ['Serial No.', 'SIN', 'S/N', 'Type No.', 'Version No.']) {
    test('preceding model code does not steal the value of $label', () {
      expect(model('$label:\nAB123XYZ\nModel Code:'), isNull);
    });
  }
  test('preceding model code is local and rejects competing values', () {
    expect(model('AB123\n...\nModel Code:'), isNull);
    expect(parser.extractModel('ab123\n\nmodel code:'), isNull);
    expect(model('12345678\nAB123\nModel Code:'), isNull);
    expect(model('AB123\nModel Code:\nCD456'), isNull);
    expect(model('AB123\nModel Code:\n...\nCD456\nModel Code:'), isNull);
    expect(model('Version No:\n02'), isNull);
  });
  test('model code priority includes a safe preceding value', () {
    expect(model('Model: TV123\n...\nAB123\nModel Code:'), 'ab123');
    expect(model('AB123\nModel Code:\nModel No.: TV123'), 'ab123');
    expect(model('Reference: REF123\n...\nAB123\nModel Code:'), 'ab123');
    expect(model('AB123\nModel Code:\nModel Code: CD456'), 'cd456');
    expect(model('Model Code: CD456\n...\nAB123\nModel Code:'), 'cd456');
  });

  test('sequential model and serial retain their own values', () {
    final result = model('MODEL NO.:\nSERIAL NO.:\nAC-GEN-4500S\n12345678');
    expect(result, 'ac-gen-4500s');
    expect(result, isNot('12345678'));
    expect(model('SERIAL NO.:\nMODEL NO.:\n12345678\nAB-123'), 'ab-123');
    expect(
      model('Model:\nSerial:\nVersion No:\nAB_12/3.4\n123456\n02'),
      'ab_12/3.4',
    );
  });

  for (final values in [
    '12345678\n87654321',
    '12345678\nAB123',
    'AB123',
    'AB123\n12345678\nEXTRA99',
    'Version No\n12345678',
    '115V\n12345678',
    '8.5A\n12345678',
    '980W\n12345678',
    '50/60Hz\n12345678',
    '250PSIG\n12345678',
    '35C\n12345678',
    '7kg\n12345678',
    'R-410A\n12345678',
    'AB123\n115V',
  ]) {
    test('sequential association rejects ambiguous values $values', () {
      expect(model('MODEL NO.:\nSERIAL NO.:\n$values'), isNull);
    });
  }
  test('conflicting blocks and multiple model labels are ambiguous', () {
    expect(
      model(
        'Model:\nSerial:\nAB123\n123456\nEND\n'
        'Model:\nSerial:\nCD456\n987654',
      ),
      isNull,
    );
    expect(model('Model:\nModel Code:\nAB123\nCD456'), isNull);
  });
  test('explicit model remains preferred over sequential association', () {
    expect(
      model('Model: TV123\nModel Code:\nSerial No.:\nAB123\n123456'),
      'tv123',
    );
  });
  for (final entry in {
    'Model: UE55F6400AW': 'ue55f6400aw',
    'Model Code: UE55F6400AWXZF': 'ue55f6400awxzf',
    'MODELO: RT35K5982SL': 'rt35k5982sl',
    'Model No.: AC-GEN-4500S': 'ac-gen-4500s',
    'Model Code:\nVersion No': null,
  }.entries) {
    test('preserves explicit model handling ${entry.key}', () {
      expect(model(entry.key), entry.value);
    });
  }

  test('sequential model and serial retain their own values', () {
    final result = model('MODEL NO.:\nSERIAL NO.:\nAC-GEN-4500S\n12345678');
    expect(result, 'ac-gen-4500s');
    expect(result, isNot('12345678'));
    expect(model('SERIAL NO.:\nMODEL NO.:\n12345678\nAB-123'), 'ab-123');
    expect(
      model('Model:\nSerial:\nVersion No:\nAB_12/3.4\n123456\n02'),
      'ab_12/3.4',
    );
  });

  for (final values in [
    '12345678\n87654321',
    '12345678\nAB123',
    'AB123',
    'AB123\n12345678\nEXTRA99',
    'Version No\n12345678',
    '115V\n12345678',
    '8.5A\n12345678',
    '980W\n12345678',
    '50/60Hz\n12345678',
    '250PSIG\n12345678',
    '35C\n12345678',
    '7kg\n12345678',
    'R-410A\n12345678',
    'AB123\n115V',
  ]) {
    test('sequential association rejects ambiguous values $values', () {
      expect(model('MODEL NO.:\nSERIAL NO.:\n$values'), isNull);
    });
  }
  test('conflicting blocks and multiple model labels are ambiguous', () {
    expect(
      model(
        'Model:\nSerial:\nAB123\n123456\nEND\n'
        'Model:\nSerial:\nCD456\n987654',
      ),
      isNull,
    );
    expect(model('Model:\nModel Code:\nAB123\nCD456'), isNull);
  });
  test('explicit model remains preferred over sequential association', () {
    expect(
      model('Model: TV123\nModel Code:\nSerial No.:\nAB123\n123456'),
      'tv123',
    );
  });
  for (final entry in {
    'Model: UE55F6400AW': 'ue55f6400aw',
    'Model Code: UE55F6400AWXZF': 'ue55f6400awxzf',
    'MODELO: RT35K5982SL': 'rt35k5982sl',
    'Model No.: AC-GEN-4500S': 'ac-gen-4500s',
    'Model Code:\nVersion No': null,
  }.entries) {
    test('preserves explicit model handling ${entry.key}', () {
      expect(model(entry.key), entry.value);
    });
  }

  test('exact Samsung TV OCR retains the explicit model', () async {
    const raw = '''SAMSUNG
AC220-240V- 50/60Hz 150W
Typical power : 75W
Model : UE55F6400AW
Type No.: UE55F6400
...
UE55F6400ANXZF
02
Model Code :
Version No
SIN: ZANY3SAD800581E''';
    expect(model(raw), 'ue55f6400aw');
    final result = await createUseCase(raw)('photo');
    expect(result.rawOcrText, raw);
    expect(result.brand, 'samsung');
    expect(result.model, 'ue55f6400aw');
    expect(result.powerWatts, 75);
  });

  for (final reserved in [
    'version',
    'serial',
    'type',
    'model',
    'code',
    'number',
    'no',
    'sin',
    's/n',
  ]) {
    for (final label in [
      'Model Code',
      'Model',
      'Model No.',
      'Reference',
      'Ref',
    ]) {
      test('$label rejects reserved value $reserved on its own line', () {
        expect(model('$label: $reserved'), isNull);
        expect(model('$label:\n$reserved'), isNull);
      });
    }
    test('invalid model code $reserved falls back to explicit model', () {
      expect(model('Model Code: $reserved\nModel: AB123'), 'ab123');
      expect(model('Model Code:\n$reserved No\nModel: AB123'), 'ab123');
    });
  }

  test('valid model code wins independently of reading order', () {
    expect(model('Model: AB123\nModel Code: AB123-XYZ'), 'ab123-xyz');
    expect(model('Model Code: AB123-XYZ\nModel: AB123'), 'ab123-xyz');
  });
  test('explicit model wins over other references', () {
    expect(
      model('Model No.: REF999\nReference: REF888\nModel: AB123'),
      'ab123',
    );
    expect(model('Model Code:\nVersion No\nReference: REF888'), 'ref888');
  });
  test('invalid candidate does not hide a later valid candidate', () {
    expect(model('Model Code: Version\nModel Code: AB123'), 'ab123');
    expect(model('Model Code: Model Code: AB123'), 'ab123');
    expect(model('Model: Serial\nModel: AB123'), 'ab123');
  });
  test('unlabelled neighbouring codes are not assigned speculatively', () {
    expect(model('AB123XYZ\n02\nModel Code:\nVersion No'), isNull);
    expect(model('Model Code:\nAB123XYZ\nModel: AB123'), 'ab123');
  });
  test('reserved words are rejected even in flattened text', () {
    expect(parser.extractModel('model code version no model ab123'), 'ab123');
  });
  test('valid identifiers containing label words remain valid', () {
    expect(model('Model Code: VERSION-123'), 'version-123');
    expect(model('Model: TYPE123'), 'type123');
  });
}
