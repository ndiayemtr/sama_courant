import 'package:flutter/material.dart';

class ApplianceChartColors {
  static const List<Color> palette = [
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFFC62828),
    Color(0xFF00838F),
    Color(0xFF5D4037),
    Color(0xFFAD1457),
  ];

  static Color forApplianceId(int? applianceId, String name) {
    if (applianceId != null) {
      return palette[applianceId.abs() % palette.length];
    }

    if (name == 'Autres') {
      return Colors.grey;
    }

    final hash = name.codeUnits.fold<int>(
      0,
      (value, element) => value + element,
    );

    return palette[hash.abs() % palette.length];
  }
}
