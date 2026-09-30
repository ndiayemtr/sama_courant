import 'package:flutter_test/flutter_test.dart';
import 'package:sama_courant/features/appliances/domain/entities/energy_consumption_basis.dart';
import 'package:sama_courant/features/appliances/domain/services/appliance_label_parser.dart';
import 'package:sama_courant/features/appliances/domain/services/label_text_normalizer.dart';

void main() {
  const normalizer = LabelTextNormalizer();
  const parser = ApplianceLabelParser();
  final units = <String>{
    'kWh/an',
    'kWh ano',
    'kWh/año',
    'kWh year',
    'kWh/yr',
    'kWh per year',
    'kWh par an',
    'kWh por ano',
    'kWhiano',
    'kWhiaño',
    'kWhlano',
    'kWhlaño',
    for (final separator in ['', '/', ' ', 'i', 'l'])
      for (final annual in ['an', 'ano', 'año', 'year', 'yr', 'annum', 'année'])
        'kWh$separator$annual',
  };
  for (final unit in units) {
    test('annual unit $unit is canonical and extractable', () {
      for (final preserveLines in [false, true]) {
        final text = normalizer.normalize(
          '355 $unit',
          preserveLines: preserveLines,
        );
        expect(text, '355 kwh/an');
        final metric = parser.extractEnergyConsumptionMetrics(text).single;
        expect(metric.valueKwh, 355);
        expect(metric.basis, EnergyConsumptionBasis.perYear);
        expect(parser.extractAnnualConsumptionKwh(text), 355);
      }
    });
  }
  for (final suffix in [
    'ianomaly',
    'lamp',
    'lannual',
    'ixan',
    'yearly',
    'yearbook',
    'anode',
    'ano123',
    'ann',
    'annu',
    'annually',
    'yr2',
    'an_suffix',
    'lano123',
    '/unknown',
    '/100 cycles',
    '/cycle',
    '/1000h',
  ]) {
    test('does not invent annual basis from $suffix', () {
      final raw = '355 kwh$suffix';
      final text = normalizer.normalize(raw);
      expect(text, raw);
      expect(parser.extractAnnualConsumptionKwh(text), isNull);
    });
  }
  for (final entry in {
    '100 cycles': EnergyConsumptionBasis.per100Cycles,
    'cycle': EnergyConsumptionBasis.perCycle,
    '1000h': EnergyConsumptionBasis.per1000Hours,
  }.entries) {
    test('preserves ${entry.key} energy basis', () {
      final text = normalizer.normalize('45 kWh/${entry.key}');
      final metric = parser.extractEnergyConsumptionMetrics(text).single;
      expect(metric.valueKwh, 45);
      expect(metric.basis, entry.value);
    });
  }
  test('preserves line structure and energy without a basis', () {
    expect(
      normalizer.normalize('355 kWhlaño\n45 kWh', preserveLines: true),
      '355 kwh/an\n45 kwh',
    );
    expect(
      parser.extractEnergyConsumptionMetrics(normalizer.normalize('45 kWh')),
      isEmpty,
    );
  });
}
