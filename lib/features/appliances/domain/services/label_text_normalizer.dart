class LabelTextNormalizer {
  const LabelTextNormalizer();

  String normalize(String text, {bool preserveLines = false}) {
    var normalized = text.toLowerCase();

    normalized = normalized
        .replaceAll(',', '.')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('å', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('í', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');

    // Corrections ciblées de lectures OCR fréquentes.
    normalized = normalized
        .replaceAll(RegExp(r'\bkvwhi(?=ano\b|\s|$)'), 'kwh ')
        .replaceAll(RegExp(r'\bkvwh\b'), 'kwh')
        .replaceAll(RegExp(r'\bk\s+w\s*h\b'), 'kwh')
        .replaceAll(RegExp(r'(?<=kwh)/a\s+o\b'), '/ano')
        .replaceAll(RegExp(r'(?<=kwh)/an0\b'), '/ano');

    // Supprime les caractères non exploitables.
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s._/+-]'), ' ');

    // Réduit les espaces, tabulations et retours à la ligne.
    normalized = preserveLines
        ? normalized
              .split(RegExp(r'[\r\n]+'))
              .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
              .join('\n')
        : normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.trim();
  }
}
