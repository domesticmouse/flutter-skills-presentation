import 'dart:math' as math;

import '../catalog/catalog_models.dart';

enum EngineeringDimension {
  resistance,
  capacitance,
  inductance,
  voltage,
  current,
  power,
  frequency,
  dimensionlessSi,
}

class EngineeringValue {
  const EngineeringValue(this.dimension, this.baseValue);

  final EngineeringDimension dimension;
  final double baseValue;

  bool matches(EngineeringValue other) {
    final dimCompatible = _dimensionsCompatible(dimension, other.dimension);
    if (!dimCompatible) return false;

    final maxAbs = math.max(baseValue.abs(), other.baseValue.abs());
    if (maxAbs == 0) return baseValue == other.baseValue;
    return (baseValue - other.baseValue).abs() <= 1e-6 * maxAbs;
  }

  static bool _dimensionsCompatible(
    EngineeringDimension a,
    EngineeringDimension b,
  ) {
    if (a == b) return true;
    // A prefix-only SI shorthand (like "4.7k", "100n", "4u7") matches passive
    // RLC component values (Resistance, Capacitance, Inductance) of the same
    // base magnitude without falsely matching Voltage/Current/Power.
    const passiveDimensions = <EngineeringDimension>{
      EngineeringDimension.resistance,
      EngineeringDimension.capacitance,
      EngineeringDimension.inductance,
      EngineeringDimension.dimensionlessSi,
    };
    if (a == EngineeringDimension.dimensionlessSi &&
        passiveDimensions.contains(b)) {
      return true;
    }
    if (b == EngineeringDimension.dimensionlessSi &&
        passiveDimensions.contains(a)) {
      return true;
    }
    return false;
  }

  @override
  String toString() => 'EngineeringValue($dimension, $baseValue)';
}

class PartSearchEngine {
  const PartSearchEngine._();

  static String _normalizeElectricalSymbols(
    String input, {
    required String ohmReplacement,
  }) {
    return input
        .replaceAll('±', '')
        .replaceAll('\u00B5', 'u') // µ micro sign
        .replaceAll('\u03BC', 'u') // μ greek small letter mu
        .replaceAll('\u2126', ohmReplacement) // Ω ohm sign
        .replaceAll('\u03A9', ohmReplacement) // Ω greek capital letter omega
        .replaceAll('\u03C9', ohmReplacement); // ω greek small letter omega
  }

  /// Folds text to lowercase, normalizes Unicode micro (`µ`/`μ` -> `u`) and
  /// ohm (`Ω`/`ω`/`ohm`/`ohms` -> `r`), and strips `±`.
  static String foldText(String input) {
    if (input.isEmpty) return '';
    var s = _normalizeElectricalSymbols(input, ohmReplacement: 'r').toLowerCase();

    // Replace standalone or suffix "ohms" / "ohm" after digits/prefixes with "r"
    s = s.replaceAllMapped(
      RegExp(r'(\d[a-z0-9.]*)\s*ohms?\b'),
      (m) => '${m.group(1)}r',
    );
    s = s.replaceAll(RegExp(r'\bohms?\b'), 'r');
    return s;
  }

  /// Extracts all canonical engineering values from a text string (such as a
  /// Part's `name` or a `Spec` value).
  static List<EngineeringValue> extractEngineeringValues(String text) {
    if (text.trim().isEmpty) return const [];
    final tokens = text
        .split(RegExp(r'[\s,;/()\[\]]+'))
        .where((t) => t.isNotEmpty);
    final results = <EngineeringValue>[];
    for (final token in tokens) {
      final parsed = parseEngineeringToken(token);
      if (parsed != null) {
        results.add(parsed);
      }
    }
    return results;
  }

  /// Parses a single token into a canonical [EngineeringValue], or returns
  /// `null` if the token is not an explicit engineering value (e.g. bare 3-digit
  /// integers like `"104"` or `"472"` return `null`).
  static EngineeringValue? parseEngineeringToken(String rawToken) {
    final cleanedRaw = _normalizeElectricalSymbols(
      rawToken.trim(),
      ohmReplacement: 'R',
    );
    if (cleanedRaw.isEmpty) return null;

    final normalizedRaw = cleanedRaw.replaceFirst(
      RegExp(r'ohms?$', caseSensitive: false),
      'R',
    );

    // 1. Check EE-infix notation: e.g. 4k7, 4K7, 4r7, 3v3, 2n2, 4u7, 1M5, 4k7R, 2n2F
    final infixMatch = RegExp(
      r'^(\d+)([pPnNuUmMkKgGrRvVfFhH])(\d+)([rRfFhHvVaAwW]|[hH][zZ])?$',
    ).firstMatch(normalizedRaw);
    if (infixMatch != null) {
      final intPart = infixMatch.group(1)!;
      final marker = infixMatch.group(2)!;
      final fracPart = infixMatch.group(3)!;
      final trailingUnit = infixMatch.group(4)?.toLowerCase();

      final mantissa = double.tryParse('$intPart.$fracPart');
      if (mantissa == null) return null;

      final markerLower = marker.toLowerCase();
      if (markerLower == 'r') {
        return EngineeringValue(EngineeringDimension.resistance, mantissa);
      }
      if (markerLower == 'v') {
        return EngineeringValue(EngineeringDimension.voltage, mantissa);
      }
      if (markerLower == 'f') {
        return EngineeringValue(EngineeringDimension.capacitance, mantissa);
      }
      if (markerLower == 'h') {
        return EngineeringValue(EngineeringDimension.inductance, mantissa);
      }

      final double multiplier;
      if (marker == 'M') {
        multiplier = 1e6;
      } else if (marker == 'm') {
        multiplier = 1e-3;
      } else {
        multiplier = _siMultiplier(markerLower)!;
      }

      final resolved = _resolveDimensionForInfix(
        markerLower: markerLower,
        trailingUnit: trailingUnit,
        multiplier: multiplier,
      );
      return EngineeringValue(resolved.dimension, mantissa * resolved.multiplier);
    }

    // 2. Check standard numeric + optional SI prefix + optional unit suffix:
    // Must have AT LEAST a prefix OR a unit suffix (bare numbers like "104" are rejected!).
    final stdMatch = RegExp(
      r'^(\d+(?:\.\d+)?)([pPnNuUmMkKgG])?([hH][zZ]|[rRfFhHvVaAwW])?$',
    ).firstMatch(normalizedRaw);
    if (stdMatch != null) {
      final numStr = stdMatch.group(1)!;
      final prefix = stdMatch.group(2);
      final unit = stdMatch.group(3);
      if (prefix == null && unit == null) {
        return null;
      }
      final mantissa = double.tryParse(numStr);
      if (mantissa == null) return null;

      final unitLower = unit?.toLowerCase();
      double multiplier = 1.0;
      if (prefix != null) {
        if (prefix == 'M') {
          multiplier = 1e6;
        } else if (prefix == 'm') {
          multiplier = (unitLower == 'hz') ? 1e6 : 1e-3;
        } else {
          multiplier = _siMultiplier(prefix.toLowerCase()) ?? 1.0;
        }
      }

      final EngineeringDimension dimension;
      if (unitLower == null) {
        dimension = EngineeringDimension.dimensionlessSi;
      } else {
        final mapped = _unitToDimension(unitLower);
        if (mapped == null) return null;
        dimension = mapped;
      }

      return EngineeringValue(dimension, mantissa * multiplier);
    }

    return null;
  }

  static double? _siMultiplier(String prefixLower) {
    switch (prefixLower) {
      case 'p':
        return 1e-12;
      case 'n':
        return 1e-9;
      case 'u':
        return 1e-6;
      case 'm':
        return 1e-3;
      case 'k':
        return 1e3;
      case 'g':
        return 1e9;
      default:
        return null;
    }
  }

  static EngineeringDimension? _unitToDimension(String unitLower) {
    switch (unitLower) {
      case 'r':
        return EngineeringDimension.resistance;
      case 'f':
        return EngineeringDimension.capacitance;
      case 'h':
        return EngineeringDimension.inductance;
      case 'v':
        return EngineeringDimension.voltage;
      case 'a':
        return EngineeringDimension.current;
      case 'w':
        return EngineeringDimension.power;
      case 'hz':
        return EngineeringDimension.frequency;
      default:
        return null;
    }
  }

  static DimensionAndMultiplier _resolveDimensionForInfix({
    required String markerLower,
    required String? trailingUnit,
    required double multiplier,
  }) {
    if (trailingUnit != null) {
      final dim = _unitToDimension(trailingUnit);
      if (dim != null) {
        return DimensionAndMultiplier(dim, multiplier);
      }
    }
    if (markerLower == 'k' || markerLower == 'g') {
      return DimensionAndMultiplier(EngineeringDimension.resistance, multiplier);
    }
    // Infix p/n/u without an explicit F/H unit (e.g. 2n2, 4u7) uses
    // dimensionlessSi so 2n2 matches 2.2nF and 4u7 matches both 4.7uF and 4.7uH.
    return DimensionAndMultiplier(
      EngineeringDimension.dimensionlessSi,
      multiplier,
    );
  }

  static int? matchTokenTier({
    required String rawToken,
    required Part part,
    required String? containerName,
  }) {
    final foldedToken = foldText(rawToken.trim());
    if (foldedToken.isEmpty) return 1;

    final queryEngValue = parseEngineeringToken(rawToken);

    final foldedLcsc = foldText(part.lcscCode ?? '');
    final foldedMpn = foldText(part.mpn ?? '');
    final lcscWithoutC =
        foldedLcsc.startsWith('c') ? foldedLcsc.substring(1) : foldedLcsc;
    if ((foldedLcsc.isNotEmpty &&
            (foldedLcsc.startsWith(foldedToken) ||
                lcscWithoutC.startsWith(foldedToken))) ||
        (foldedMpn.isNotEmpty && foldedMpn.startsWith(foldedToken))) {
      return 1;
    }

    final foldedName = foldText(part.name);
    if (foldedName.contains(foldedToken)) {
      return 2;
    }
    for (final entry in part.specs.entries) {
      if (foldText(entry.key).contains(foldedToken) ||
          foldText(entry.value).contains(foldedToken)) {
        return 2;
      }
    }
    if (queryEngValue != null) {
      final nameValues = extractEngineeringValues(part.name);
      if (nameValues.any(queryEngValue.matches)) {
        return 2;
      }
      for (final specValue in part.specs.values) {
        final specEngValues = extractEngineeringValues(specValue);
        if (specEngValues.any(queryEngValue.matches)) {
          return 2;
        }
      }
    }

    final tier3Fields = <String?>[
      part.lcscCode,
      part.mpn,
      part.slot,
      containerName,
      part.package,
      part.category,
      part.manufacturer,
      part.notes,
    ];
    for (final field in tier3Fields) {
      if (field != null && foldText(field).contains(foldedToken)) {
        return 3;
      }
    }

    return null;
  }

  static int? evaluateQueryRank({
    required String query,
    required Part part,
    required String? containerName,
  }) {
    final tokens = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return 1;

    var bestTier = 3;
    for (final token in tokens) {
      final tier = matchTokenTier(
        rawToken: token,
        part: part,
        containerName: containerName,
      );
      if (tier == null) {
        return null;
      }
      if (tier < bestTier) {
        bestTier = tier;
      }
    }
    return bestTier;
  }

  static int compareNaturalSlot(String? a, String? b) {
    final aClean = a?.trim() ?? '';
    final bClean = b?.trim() ?? '';
    if (aClean.isEmpty && bClean.isEmpty) return 0;
    if (aClean.isEmpty) return 1;
    if (bClean.isEmpty) return -1;

    final aChunks = _splitAlphaNumericChunks(aClean.toLowerCase());
    final bChunks = _splitAlphaNumericChunks(bClean.toLowerCase());
    final len = math.min(aChunks.length, bChunks.length);
    for (var i = 0; i < len; i++) {
      final ca = aChunks[i];
      final cb = bChunks[i];
      final aNum = int.tryParse(ca);
      final bNum = int.tryParse(cb);
      final int cmp;
      if (aNum != null && bNum != null) {
        cmp = aNum.compareTo(bNum);
      } else {
        cmp = ca.compareTo(cb);
      }
      if (cmp != 0) return cmp;
    }
    return aChunks.length.compareTo(bChunks.length);
  }

  static List<String> _splitAlphaNumericChunks(String input) {
    return RegExp(r'\d+|\D+')
        .allMatches(input)
        .map((m) => m.group(0)!)
        .toList();
  }
}

class DimensionAndMultiplier {
  const DimensionAndMultiplier(this.dimension, this.multiplier);

  final EngineeringDimension dimension;
  final double multiplier;
}
