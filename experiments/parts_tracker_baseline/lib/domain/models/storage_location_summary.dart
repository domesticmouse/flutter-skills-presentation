import 'electronic_part.dart';

/// Aggregated summary of parts stored in a specific storage bin/location.
class StorageLocationSummary {
  const StorageLocationSummary({
    required this.locationName,
    required this.parts,
  });

  /// Display name of the storage location, or 'Unassigned' if empty.
  final String locationName;

  /// Parts stored in this location.
  final List<ElectronicPart> parts;

  /// Number of distinct part types in this location.
  int get partTypesCount => parts.length;

  /// Total quantity of individual components stored here.
  int get totalUnitsCount =>
      parts.fold<int>(0, (sum, part) => sum + part.quantity);

  /// Number of parts in this location that need restocking.
  int get lowStockCount => parts.where((part) => part.needsRestock).length;

  /// Total value of parts stored in this location.
  double get totalValue =>
      parts.fold<double>(0.0, (sum, part) => sum + part.totalValue);
}
