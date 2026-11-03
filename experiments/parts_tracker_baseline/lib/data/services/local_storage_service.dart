import 'dart:convert';
import 'dart:io';

/// Service abstraction for reading and writing raw inventory data locally.
abstract class LocalStorageService {
  /// Loads the raw list of serialized JSON part maps, or `null` if no saved
  /// inventory exists yet.
  Future<List<Map<String, dynamic>>?> loadPartsJson();

  /// Persists the list of serialized JSON part maps to local storage.
  Future<void> savePartsJson(List<Map<String, dynamic>> parts);
}

/// Persists inventory data to a JSON file in the device's local documents
/// directory (or system temp directory as fallback).
class FileLocalStorageService implements LocalStorageService {
  FileLocalStorageService({this._customFilePath});

  final String? _customFilePath;
  static const String _fileName = 'electronics_parts_inventory_v1.json';

  Future<File> _resolveStorageFile() async {
    final customPath = _customFilePath;
    if (customPath != null) {
      return File(customPath);
    }

    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) {
      final docsDir = Directory('$home/Documents');
      try {
        if (!await docsDir.exists()) {
          await docsDir.create(recursive: true);
        }
        return File('${docsDir.path}/$_fileName');
      } on FileSystemException {
        // Fall through to systemTemp if Documents is not writable.
      }
    }

    return File('${Directory.systemTemp.path}/$_fileName');
  }

  @override
  Future<List<Map<String, dynamic>>?> loadPartsJson() async {
    final file = await _resolveStorageFile();
    if (!await file.exists()) {
      return null;
    }

    final rawContent = await file.readAsString();
    if (rawContent.trim().isEmpty) {
      return null;
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(rawContent);
    } on FormatException catch (e) {
      throw FormatException(
        'Inventory storage file is corrupted (${file.path}): ${e.message}',
      );
    }

    if (decoded is List<dynamic>) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    if (decoded is Map<String, dynamic> && decoded['parts'] is List<dynamic>) {
      final partsList = decoded['parts'] as List<dynamic>;
      return partsList.whereType<Map<String, dynamic>>().toList();
    }

    throw FormatException(
      'Unexpected JSON structure in inventory storage file (${file.path}).',
    );
  }

  @override
  Future<void> savePartsJson(List<Map<String, dynamic>> parts) async {
    final file = await _resolveStorageFile();
    final payload = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'parts': parts,
    };
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(payload), flush: true);
  }
}

/// In-memory implementation of [LocalStorageService] for fast, isolated testing.
class InMemoryLocalStorageService implements LocalStorageService {
  InMemoryLocalStorageService({List<Map<String, dynamic>>? initialData})
      : _storedParts = initialData != null
            ? List<Map<String, dynamic>>.from(initialData)
            : null;

  List<Map<String, dynamic>>? _storedParts;

  @override
  Future<List<Map<String, dynamic>>?> loadPartsJson() async {
    final stored = _storedParts;
    if (stored == null) return null;
    return List<Map<String, dynamic>>.from(stored);
  }

  @override
  Future<void> savePartsJson(List<Map<String, dynamic>> parts) async {
    _storedParts = List<Map<String, dynamic>>.from(parts);
  }
}
