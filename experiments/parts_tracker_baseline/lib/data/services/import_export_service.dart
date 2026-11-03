import 'dart:convert';

import '../../domain/models/electronic_part.dart';
import '../../domain/models/part_category.dart';

/// Stateless service for exporting and importing [ElectronicPart] lists
/// in JSON and CSV formats.
class ImportExportService {
  const ImportExportService();

  static const List<String> csvHeaders = [
    'id',
    'name',
    'category',
    'package',
    'valueOrSpecs',
    'quantity',
    'minStockThreshold',
    'storageLocation',
    'manufacturerPartNumber',
    'supplierName',
    'supplierPartNumber',
    'unitPrice',
    'datasheetUrl',
    'notes',
    'updatedAt',
  ];

  /// Exports [parts] into a formatted JSON string.
  String exportToJson(List<ElectronicPart> parts) {
    final payload = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'parts': parts.map((p) => p.toJson()).toList(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  /// Imports [ElectronicPart] items from a JSON string.
  /// Supports either a top-level array `[...]` or an object `{"parts": [...]}`.
  List<ElectronicPart> importFromJson(String jsonContent) {
    final trimmed = jsonContent.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('JSON input cannot be empty.');
    }

    final Object? decoded = jsonDecode(trimmed);
    final List<dynamic> rawList;

    if (decoded is List<dynamic>) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['parts'] is List<dynamic>) {
      rawList = decoded['parts'] as List<dynamic>;
    } else {
      throw const FormatException(
        'Expected a JSON array of parts or an object with a "parts" array.',
      );
    }

    final imported = <ElectronicPart>[];
    for (final item in rawList) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Each entry in JSON must be an object.');
      }
      imported.add(ElectronicPart.fromJson(item));
    }
    return imported;
  }

  /// Exports [parts] into an RFC-4180 compliant CSV string.
  String exportToCsv(List<ElectronicPart> parts) {
    final buffer = StringBuffer();
    buffer.writeln(csvHeaders.join(','));

    for (final part in parts) {
      final row = <String>[
        _escapeCsvField(part.id),
        _escapeCsvField(part.name),
        _escapeCsvField(part.category.id),
        _escapeCsvField(part.package),
        _escapeCsvField(part.valueOrSpecs),
        part.quantity.toString(),
        part.minStockThreshold.toString(),
        _escapeCsvField(part.storageLocation),
        _escapeCsvField(part.manufacturerPartNumber),
        _escapeCsvField(part.supplierName),
        _escapeCsvField(part.supplierPartNumber),
        part.formattedUnitPrice,
        _escapeCsvField(part.datasheetUrl),
        _escapeCsvField(part.notes),
        _escapeCsvField(part.updatedAt.toIso8601String()),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Imports [ElectronicPart] items from a CSV string.
  List<ElectronicPart> importFromCsv(String csvContent) {
    final trimmed = csvContent.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('CSV input cannot be empty.');
    }

    final rows = _parseCsvRows(trimmed);
    if (rows.length < 2) {
      throw const FormatException(
        'CSV must include a header row and at least one part row.',
      );
    }

    final headerRow =
        rows.first.map((col) => col.trim().toLowerCase()).toList();
    final nameIndex = headerRow.indexOf('name');
    if (nameIndex == -1) {
      throw const FormatException('CSV header must contain a "name" column.');
    }

    String readCell(List<String> row, String columnName) {
      final idx = headerRow.indexOf(columnName.toLowerCase());
      if (idx == -1 || idx >= row.length) return '';
      return row[idx].trim();
    }

    final imported = <ElectronicPart>[];
    final now = DateTime.now().toUtc();

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.every((cell) => cell.trim().isEmpty)) {
        continue;
      }

      final name = readCell(row, 'name');
      if (name.isEmpty) {
        throw FormatException('Row ${i + 1} is missing a part name.');
      }

      final rawId = readCell(row, 'id');
      final id = rawId.isNotEmpty
          ? rawId
          : 'csv-${now.microsecondsSinceEpoch}-$i';

      final categoryStr = readCell(row, 'category');
      final quantity = int.tryParse(readCell(row, 'quantity')) ?? 0;
      final minStock = int.tryParse(readCell(row, 'minStockThreshold')) ?? 5;
      final unitPrice = double.tryParse(readCell(row, 'unitPrice')) ?? 0.0;
      final updatedAtStr = readCell(row, 'updatedAt');
      final updatedAt = DateTime.tryParse(updatedAtStr) ?? now;

      imported.add(
        ElectronicPart(
          id: id,
          name: name,
          category: PartCategory.fromString(categoryStr),
          package: readCell(row, 'package'),
          valueOrSpecs: readCell(row, 'valueOrSpecs'),
          quantity: quantity < 0 ? 0 : quantity,
          minStockThreshold: minStock < 0 ? 0 : minStock,
          storageLocation: readCell(row, 'storageLocation'),
          manufacturerPartNumber: readCell(row, 'manufacturerPartNumber'),
          supplierName: readCell(row, 'supplierName'),
          supplierPartNumber: readCell(row, 'supplierPartNumber'),
          unitPrice: unitPrice < 0 ? 0.0 : unitPrice,
          datasheetUrl: readCell(row, 'datasheetUrl'),
          notes: readCell(row, 'notes'),
          updatedAt: updatedAt,
        ),
      );
    }

    return imported;
  }

  String _escapeCsvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }

  List<List<String>> _parseCsvRows(String input) {
    final rows = <List<String>>[];
    var currentRow = <String>[];
    final currentCell = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            currentCell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          currentCell.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
        } else if (char == '\r') {
          if (i + 1 < input.length && input[i + 1] == '\n') {
            i++;
          }
          currentRow.add(currentCell.toString());
          currentCell.clear();
          rows.add(currentRow);
          currentRow = <String>[];
        } else if (char == '\n') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
          rows.add(currentRow);
          currentRow = <String>[];
        } else {
          currentCell.write(char);
        }
      }
    }

    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      rows.add(currentRow);
    }

    return rows;
  }
}
