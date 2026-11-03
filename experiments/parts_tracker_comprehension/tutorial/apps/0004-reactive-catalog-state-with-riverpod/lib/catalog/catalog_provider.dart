import 'dart:convert';
import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'catalog_models.dart';
import 'catalog_persistence.dart';
import 'file_catalog_persistence.dart';

part 'catalog_provider.g.dart';

class SlotOccupiedException implements Exception {
  const SlotOccupiedException({
    required this.containerId,
    required this.slot,
    required this.occupyingPart,
  });

  final String containerId;
  final String slot;
  final Part occupyingPart;

  @override
  String toString() =>
      'Slot "$slot" is already occupied by "${occupyingPart.name}".';
}

class CatalogImportValidationException implements Exception {
  const CatalogImportValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
CatalogPersistence catalogPersistence(Ref ref) {
  return FileCatalogPersistence();
}

@Riverpod(keepAlive: true)
class Catalog extends _$Catalog {
  @override
  Future<CatalogSnapshot> build() async {
    final persistence = ref.watch(catalogPersistenceProvider);
    return persistence.load();
  }

  Future<void> upsertPart(Part part) async {
    final current = await future;
    final normalized = _normalizePart(part);
    if (normalized.containerId != null &&
        !current.containers.any((c) => c.id == normalized.containerId)) {
      throw ArgumentError(
        'Unknown containerId "${normalized.containerId}".',
      );
    }
    final occupying = current.findOccupyingSlotPart(
      normalized.containerId,
      normalized.slot,
      excludingPartId: normalized.id,
    );
    if (occupying != null) {
      throw SlotOccupiedException(
        containerId: normalized.containerId!,
        slot: normalized.slot!,
        occupyingPart: occupying,
      );
    }
    final updatedParts = [...current.parts];
    final existingIdx = updatedParts.indexWhere((p) => p.id == normalized.id);
    if (existingIdx >= 0) {
      updatedParts[existingIdx] = normalized;
    } else {
      updatedParts.add(normalized);
    }
    await _commit(current.copyWith(parts: updatedParts));
  }

  Future<void> upsertContainer(Container container) async {
    final current = await future;
    final name = container.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Container name is required.');
    }
    final normalized = container.copyWith(
      name: name,
      description: _nullIfEmpty(container.description),
    );
    final updatedContainers = [...current.containers];
    final existingIdx =
        updatedContainers.indexWhere((c) => c.id == normalized.id);
    if (existingIdx >= 0) {
      updatedContainers[existingIdx] = normalized;
    } else {
      updatedContainers.add(normalized);
    }
    await _commit(current.copyWith(containers: updatedContainers));
  }

  Future<void> deleteContainer(String containerId) async {
    final current = await future;
    final updatedContainers =
        current.containers.where((c) => c.id != containerId).toList();
    final updatedParts = current.parts.map((part) {
      if (part.containerId == containerId) {
        return part.copyWith(containerId: null, slot: null);
      }
      return part;
    }).toList();
    await _commit(
      current.copyWith(
        containers: updatedContainers,
        parts: updatedParts,
      ),
    );
  }

  Part? findDuplicateLcscPart(String? rawLcscCode, {String? excludingPartId}) {
    final current = state.value;
    if (current == null) return null;
    final normalized = normalizeLcscCodeOrNull(rawLcscCode);
    if (normalized == null) return null;
    for (final part in current.parts) {
      if (part.id == excludingPartId) continue;
      if (part.lcscCode != null &&
          part.lcscCode!.toUpperCase() == normalized) {
        return part;
      }
    }
    return null;
  }

  static String? normalizeLcscCodeOrNull(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final upper = trimmed.toUpperCase();
    final withPrefix = upper.startsWith('C') ? upper : 'C$upper';
    return RegExp(r'^C\d+$').hasMatch(withPrefix) ? withPrefix : null;
  }

  CatalogSnapshot validateImport(String rawJson) => validateCatalogJson(rawJson);

  static CatalogSnapshot validateCatalogJson(String rawJson) {
    final Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      throw CatalogImportValidationException(
        'Malformed JSON file: ${e.message}',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const CatalogImportValidationException(
        'Catalog JSON root must be a JSON object.',
      );
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int || schemaVersion != 1) {
      throw CatalogImportValidationException(
        'Unsupported schemaVersion: $schemaVersion (expected 1).',
      );
    }

    final rawUpdatedAt = decoded['updatedAt'];
    if (rawUpdatedAt is! String || rawUpdatedAt.trim().isEmpty) {
      throw const CatalogImportValidationException(
        'Field "updatedAt" is required and must be an ISO-8601 timestamp string.',
      );
    }
    final parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt);
    if (parsedUpdatedAt == null) {
      throw CatalogImportValidationException(
        'Invalid "updatedAt" timestamp: "$rawUpdatedAt".',
      );
    }
    final updatedAt = parsedUpdatedAt.toUtc();

    final rawContainers = decoded['containers'];
    if (rawContainers is! List) {
      throw const CatalogImportValidationException(
        'Field "containers" must be a JSON list.',
      );
    }
    final rawParts = decoded['parts'];
    if (rawParts is! List) {
      throw const CatalogImportValidationException(
        'Field "parts" must be a JSON list.',
      );
    }

    final containerIds = <String>{};
    final containers = <Container>[];
    for (final item in rawContainers) {
      if (item is! Map<String, dynamic>) {
        throw const CatalogImportValidationException(
          'Each entry in "containers" must be a JSON object.',
        );
      }
      final id = item['id'];
      final name = item['name'];
      if (id is! String || id.trim().isEmpty) {
        throw const CatalogImportValidationException(
          'Every container must have a non-empty string "id".',
        );
      }
      if (name is! String || name.trim().isEmpty) {
        throw CatalogImportValidationException(
          'Container "$id" must have a non-empty string "name".',
        );
      }
      final trimmedId = id.trim();
      if (!containerIds.add(trimmedId)) {
        throw CatalogImportValidationException(
          'Duplicate container id: "$trimmedId".',
        );
      }
      final desc = item['description'];
      if (desc != null && desc is! String) {
        throw CatalogImportValidationException(
          'Container "$trimmedId" description must be a string or null.',
        );
      }
      final trimmedDesc =
          desc is String && desc.trim().isNotEmpty ? desc.trim() : null;
      containers.add(
        Container(
          id: trimmedId,
          name: name.trim(),
          description: trimmedDesc,
        ),
      );
    }

    final partIds = <String>{};
    final occupiedSlots = <String, ({String slot, String partName})>{};
    final parts = <Part>[];
    for (final item in rawParts) {
      if (item is! Map<String, dynamic>) {
        throw const CatalogImportValidationException(
          'Each entry in "parts" must be a JSON object.',
        );
      }
      final id = item['id'];
      final name = item['name'];
      final quantity = item['quantity'];
      if (id is! String || id.trim().isEmpty) {
        throw const CatalogImportValidationException(
          'Every part must have a non-empty string "id".',
        );
      }
      if (name is! String || name.trim().isEmpty) {
        throw CatalogImportValidationException(
          'Part "$id" must have a non-empty string "name".',
        );
      }
      if (quantity is! int || quantity < 0) {
        throw CatalogImportValidationException(
          'Part "$id" must have a non-negative integer "quantity".',
        );
      }
      final trimmedId = id.trim();
      if (!partIds.add(trimmedId)) {
        throw CatalogImportValidationException(
          'Duplicate part id: "$trimmedId".',
        );
      }

      final Part parsedPart;
      try {
        parsedPart = Part.fromJson(item);
      } on Object catch (e) {
        throw CatalogImportValidationException(
          'Invalid fields on part "$trimmedId": $e',
        );
      }
      if (parsedPart.lowStockThreshold != null &&
          parsedPart.lowStockThreshold! < 0) {
        throw CatalogImportValidationException(
          'Part "$trimmedId" cannot have a negative lowStockThreshold.',
        );
      }

      final Part normalizedPart;
      try {
        normalizedPart = _normalizePart(parsedPart.copyWith(id: trimmedId));
      } on ArgumentError catch (e) {
        throw CatalogImportValidationException(
          'Part "$trimmedId" is invalid: ${e.message}',
        );
      }

      final containerId = normalizedPart.containerId;
      if (containerId != null && !containerIds.contains(containerId)) {
        throw CatalogImportValidationException(
          'Part "$trimmedId" references unknown containerId "$containerId".',
        );
      }
      final slot = normalizedPart.slot;
      if (containerId != null && slot != null) {
        final key = '$containerId::${slot.toLowerCase()}';
        final existing = occupiedSlots[key];
        if (existing != null) {
          throw CatalogImportValidationException(
            'Duplicate slot "${existing.slot}" in container "$containerId" (occupied by "${existing.partName}" and "${normalizedPart.name}").',
          );
        }
        occupiedSlots[key] = (slot: slot, partName: normalizedPart.name);
      }

      parts.add(normalizedPart);
    }

    return CatalogSnapshot(
      schemaVersion: 1,
      updatedAt: updatedAt,
      containers: List<Container>.unmodifiable(containers),
      parts: List<Part>.unmodifiable(parts),
    );
  }

  Future<void> importSnapshot(CatalogSnapshot validatedSnapshot) async {
    final current = await future;
    final persistence = ref.read(catalogPersistenceProvider);
    await persistence.savePreImportBackup(current);
    await persistence.save(validatedSnapshot);
    state = AsyncData(validatedSnapshot);
  }

  Future<String> exportBackupFile() async {
    final current = await future;
    final persistence = ref.read(catalogPersistenceProvider);
    return persistence.writeExportFile(current);
  }

  Future<void> shareBackupFile() async {
    final current = await future;
    final persistence = ref.read(catalogPersistenceProvider);
    await persistence.shareExportFile(current);
  }

  Future<void> deletePart(String partId) async {
    final current = await future;
    final updatedParts = current.parts.where((p) => p.id != partId).toList();
    await _commit(current.copyWith(parts: updatedParts));
  }

  Future<void> adjustQuantity(String partId, int delta) async {
    await _updatePartQuantity(partId, (currentQty) => currentQty + delta);
  }

  Future<void> setQuantity(String partId, int exactQuantity) async {
    await _updatePartQuantity(partId, (_) => exactQuantity);
  }

  Future<void> _updatePartQuantity(
    String partId,
    int Function(int currentQty) computeNext,
  ) async {
    final current = await future;
    final idx = current.parts.indexWhere((p) => p.id == partId);
    if (idx < 0) return;
    final part = current.parts[idx];
    final nextQty = math.max(0, computeNext(part.quantity));
    final updatedParts = [...current.parts];
    updatedParts[idx] = part.copyWith(quantity: nextQty);
    await _commit(current.copyWith(parts: updatedParts));
  }

  static Part _normalizePart(Part part) {
    final id = part.id.trim();
    if (id.isEmpty) {
      throw ArgumentError('Part id is required.');
    }
    final name = part.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Part name is required.');
    }
    final containerId = _nullIfEmpty(part.containerId);
    final slot = containerId == null ? null : _nullIfEmpty(part.slot);
    final rawLcsc = _nullIfEmpty(part.lcscCode);
    String? lcscCode;
    if (rawLcsc != null) {
      lcscCode = normalizeLcscCodeOrNull(rawLcsc);
      if (lcscCode == null) {
        throw ArgumentError(
          'Invalid LCSC code "$rawLcsc". Expected format Cxxxxxx (e.g. C14663).',
        );
      }
    }
    final cleanedSpecs = <String, String>{};
    for (final entry in part.specs.entries) {
      final k = entry.key.trim();
      final v = entry.value.trim();
      if (k.isNotEmpty && v.isNotEmpty) {
        cleanedSpecs[k] = v;
      }
    }
    return part.copyWith(
      id: id,
      name: name,
      quantity: math.max(0, part.quantity),
      lcscCode: lcscCode,
      mpn: _nullIfEmpty(part.mpn),
      manufacturer: _nullIfEmpty(part.manufacturer),
      category: _nullIfEmpty(part.category),
      package: _nullIfEmpty(part.package),
      datasheetUrl: _nullIfEmpty(part.datasheetUrl),
      containerId: containerId,
      slot: slot,
      lowStockThreshold: part.lowStockThreshold == null
          ? null
          : math.max(0, part.lowStockThreshold!),
      notes: _nullIfEmpty(part.notes),
      specs: Map<String, String>.unmodifiable(cleanedSpecs),
    );
  }

  static String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _commit(CatalogSnapshot next) async {
    final stamped = next.copyWith(updatedAt: DateTime.now().toUtc());
    final persistence = ref.read(catalogPersistenceProvider);
    await persistence.save(stamped);
    state = AsyncData(stamped);
  }
}
