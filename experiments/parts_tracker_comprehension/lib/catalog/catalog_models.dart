import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Container with _$Container {
  const Container._();

  const factory Container({
    required String id,
    required String name,
    String? description,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}

@freezed
abstract class Part with _$Part {
  const Part._();

  const factory Part({
    required String id,
    required String name,
    @Default(0) int quantity,
    String? lcscCode,
    String? mpn,
    String? manufacturer,
    String? category,
    String? package,
    String? datasheetUrl,
    String? containerId,
    String? slot,
    int? lowStockThreshold,
    String? notes,
    @Default(<String, String>{}) Map<String, String> specs,
  }) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  bool get isLowStock => quantity <= (lowStockThreshold ?? 0);

  bool get isUnassigned => containerId == null;
}

@freezed
abstract class CatalogSnapshot with _$CatalogSnapshot {
  const CatalogSnapshot._();

  const factory CatalogSnapshot({
    @Default(1) int schemaVersion,
    required DateTime updatedAt,
    @Default(<Container>[]) List<Container> containers,
    @Default(<Part>[]) List<Part> parts,
  }) = _CatalogSnapshot;

  factory CatalogSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CatalogSnapshotFromJson(json);

  factory CatalogSnapshot.empty({DateTime? now}) => CatalogSnapshot(
        schemaVersion: 1,
        updatedAt: (now ?? DateTime.now()).toUtc(),
        containers: const [],
        parts: const [],
      );

  String get exportFileName {
    final dateStr = updatedAt.toUtc().toIso8601String().split('T').first;
    return 'parts-catalog-$dateStr.json';
  }

  Part? findOccupyingSlotPart(
    String? containerId,
    String? slot, {
    String? excludingPartId,
  }) {
    final cleanContainerId = containerId?.trim();
    final cleanSlot = slot?.trim();
    if (cleanContainerId == null ||
        cleanContainerId.isEmpty ||
        cleanSlot == null ||
        cleanSlot.isEmpty) {
      return null;
    }
    final slotLower = cleanSlot.toLowerCase();
    for (final existing in parts) {
      if (existing.id == excludingPartId) continue;
      if (existing.containerId == cleanContainerId &&
          existing.slot != null &&
          existing.slot!.toLowerCase() == slotLower) {
        return existing;
      }
    }
    return null;
  }
}
