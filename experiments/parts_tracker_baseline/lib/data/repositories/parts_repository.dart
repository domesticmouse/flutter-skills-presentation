import '../../domain/models/electronic_part.dart';
import '../services/import_export_service.dart';
import '../services/local_storage_service.dart';
import '../services/sample_parts_data.dart';

/// Single source of truth for managing the electronics parts inventory.
class PartsRepository {
  PartsRepository({
    required this._storageService,
    this._importExportService = const ImportExportService(),
    this._seedSampleDataWhenEmpty = true,
  });

  final LocalStorageService _storageService;
  final ImportExportService _importExportService;
  final bool _seedSampleDataWhenEmpty;

  List<ElectronicPart>? _cachedParts;
  Future<void> _writeChain = Future<void>.value();
  int _lastImportedCount = 0;

  /// Number of records processed in the most recent [importData] call.
  int get lastImportedCount => _lastImportedCount;

  /// Loads parts from storage (or initializes with sample data on first run).
  Future<List<ElectronicPart>> getParts() async {
    if (_cachedParts != null) {
      return List<ElectronicPart>.unmodifiable(_cachedParts!);
    }

    final rawList = await _storageService.loadPartsJson();
    if (rawList == null) {
      final initial = _seedSampleDataWhenEmpty
          ? SamplePartsData.getInitialParts()
          : <ElectronicPart>[];
      _cachedParts = List<ElectronicPart>.from(initial);
      await _persist();
      return List<ElectronicPart>.unmodifiable(_cachedParts!);
    }

    final parsed = <ElectronicPart>[];
    for (final map in rawList) {
      try {
        parsed.add(ElectronicPart.fromJson(map));
      } on FormatException {
        // Skip malformed records safely.
      }
    }
    _cachedParts = parsed;
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  /// Adds or updates an [ElectronicPart] and persists the inventory.
  Future<List<ElectronicPart>> savePart(ElectronicPart part) async {
    final current = List<ElectronicPart>.from(await getParts());
    final existingIndex = current.indexWhere((p) => p.id == part.id);
    if (existingIndex >= 0) {
      current[existingIndex] = part;
    } else {
      current.insert(0, part);
    }
    _cachedParts = current;
    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  /// Deletes a part by its [id].
  Future<List<ElectronicPart>> deletePart(String id) async {
    final current = List<ElectronicPart>.from(await getParts());
    current.removeWhere((p) => p.id == id);
    _cachedParts = current;
    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  /// Adjusts the stock quantity of a part by [delta] (clamped at 0).
  Future<List<ElectronicPart>> adjustQuantity(String id, int delta) async {
    final current = List<ElectronicPart>.from(await getParts());
    final index = current.indexWhere((p) => p.id == id);
    if (index == -1) {
      return List<ElectronicPart>.unmodifiable(current);
    }

    final existing = current[index];
    final nextQuantity = existing.quantity + delta;
    current[index] = existing.copyWith(
      quantity: nextQuantity < 0 ? 0 : nextQuantity,
      updatedAt: DateTime.now().toUtc(),
    );
    _cachedParts = current;
    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  /// Renames a storage location across all matching parts.
  Future<List<ElectronicPart>> renameLocation({
    required String oldLocation,
    required String newLocation,
  }) async {
    final current = List<ElectronicPart>.from(await getParts());
    final trimmedOld = _normalizeStorageLocation(oldLocation);
    final trimmedNew = _normalizeStorageLocation(newLocation);
    final now = DateTime.now().toUtc();

    for (var i = 0; i < current.length; i++) {
      if (_normalizeStorageLocation(current[i].storageLocation) == trimmedOld) {
        current[i] = current[i].copyWith(
          storageLocation: trimmedNew,
          updatedAt: now,
        );
      }
    }
    _cachedParts = current;
    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  static String _normalizeStorageLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.toLowerCase() == 'unassigned') {
      return '';
    }
    return trimmed;
  }

  /// Resets the inventory back to the starter sample parts.
  Future<List<ElectronicPart>> resetToSampleData() async {
    _cachedParts = List<ElectronicPart>.from(SamplePartsData.getInitialParts());
    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  /// Exports the current inventory as a formatted JSON string.
  Future<String> exportJson() async {
    final parts = await getParts();
    return _importExportService.exportToJson(parts);
  }

  /// Exports the current inventory as an RFC-4180 CSV string.
  Future<String> exportCsv() async {
    final parts = await getParts();
    return _importExportService.exportToCsv(parts);
  }

  /// Imports parts from JSON or CSV. When [replaceExisting] is false,
  /// merges imported parts by ID (updating matching IDs and adding new ones).
  Future<List<ElectronicPart>> importData({
    required String content,
    required bool isCsv,
    required bool replaceExisting,
  }) async {
    final imported = isCsv
        ? _importExportService.importFromCsv(content)
        : _importExportService.importFromJson(content);
    _lastImportedCount = imported.length;

    if (replaceExisting) {
      _cachedParts = List<ElectronicPart>.from(imported);
    } else {
      final current = List<ElectronicPart>.from(await getParts());
      for (final part in imported) {
        final existingIdx = current.indexWhere((p) => p.id == part.id);
        if (existingIdx >= 0) {
          current[existingIdx] = part;
        } else {
          current.add(part);
        }
      }
      _cachedParts = current;
    }

    await _persist();
    return List<ElectronicPart>.unmodifiable(_cachedParts!);
  }

  Future<void> _persist() {
    final current = _cachedParts ?? const <ElectronicPart>[];
    final jsonMaps = current.map((p) => p.toJson()).toList();
    final nextWrite = _writeChain.then(
      (_) => _storageService.savePartsJson(jsonMaps),
      onError: (_) => _storageService.savePartsJson(jsonMaps),
    );
    _writeChain = nextWrite.catchError((_) {});
    return nextWrite;
  }
}
