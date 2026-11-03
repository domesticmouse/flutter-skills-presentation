import 'part_category.dart';

/// Represents an individual electronics component in the user's inventory.
class ElectronicPart {
  const ElectronicPart({
    required this.id,
    required this.name,
    required this.category,
    required this.package,
    required this.valueOrSpecs,
    required this.quantity,
    this.minStockThreshold = 5,
    this.storageLocation = '',
    this.manufacturerPartNumber = '',
    this.supplierName = '',
    this.supplierPartNumber = '',
    this.unitPrice = 0.0,
    this.datasheetUrl = '',
    this.notes = '',
    required this.updatedAt,
  });

  final String id;
  final String name;
  final PartCategory category;
  final String package;
  final String valueOrSpecs;
  final int quantity;
  final int minStockThreshold;
  final String storageLocation;
  final String manufacturerPartNumber;
  final String supplierName;
  final String supplierPartNumber;
  final double unitPrice;
  final String datasheetUrl;
  final String notes;
  final DateTime updatedAt;

  /// True when the part has zero units in stock.
  bool get isOutOfStock => quantity <= 0;

  /// True when the part is in stock but at or below [minStockThreshold].
  bool get isLowStock => quantity > 0 && quantity <= minStockThreshold;

  /// True when the part is either out of stock or low on stock.
  bool get needsRestock => quantity <= minStockThreshold;

  /// Total monetary value of the current stock for this part.
  double get totalValue => quantity * unitPrice;

  /// Formats [unitPrice] with at least 2 decimal places, preserving sub-cent
  /// precision (up to 6 decimal places) when present.
  String get formattedUnitPrice {
    final fixed6 = unitPrice.toStringAsFixed(6);
    var trimmed = fixed6.replaceFirst(RegExp(r'0+$'), '');
    if (trimmed.endsWith('.')) {
      trimmed = '${trimmed}00';
    } else {
      final dotIndex = trimmed.indexOf('.');
      if (dotIndex != -1 && trimmed.length - dotIndex - 1 < 2) {
        trimmed = '${trimmed}0';
      }
    }
    return trimmed;
  }

  /// Creates a copy of this [ElectronicPart] with updated fields.
  ElectronicPart copyWith({
    String? id,
    String? name,
    PartCategory? category,
    String? package,
    String? valueOrSpecs,
    int? quantity,
    int? minStockThreshold,
    String? storageLocation,
    String? manufacturerPartNumber,
    String? supplierName,
    String? supplierPartNumber,
    double? unitPrice,
    String? datasheetUrl,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ElectronicPart(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      package: package ?? this.package,
      valueOrSpecs: valueOrSpecs ?? this.valueOrSpecs,
      quantity: quantity ?? this.quantity,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      storageLocation: storageLocation ?? this.storageLocation,
      manufacturerPartNumber:
          manufacturerPartNumber ?? this.manufacturerPartNumber,
      supplierName: supplierName ?? this.supplierName,
      supplierPartNumber: supplierPartNumber ?? this.supplierPartNumber,
      unitPrice: unitPrice ?? this.unitPrice,
      datasheetUrl: datasheetUrl ?? this.datasheetUrl,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Deserializes an [ElectronicPart] from a JSON map.
  factory ElectronicPart.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) {
      throw const FormatException(
        'Failed to load ElectronicPart: missing id or name.',
      );
    }

    final rawQuantity = json['quantity'];
    final quantity = switch (rawQuantity) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v) ?? 0,
      _ => 0,
    };

    final rawThreshold = json['minStockThreshold'];
    final minStockThreshold = switch (rawThreshold) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v) ?? 5,
      _ => 5,
    };

    final rawPrice = json['unitPrice'];
    final unitPrice = switch (rawPrice) {
      double v => v,
      num v => v.toDouble(),
      String v => double.tryParse(v) ?? 0.0,
      _ => 0.0,
    };

    final updatedAtStr = json['updatedAt'] as String?;
    final updatedAt = updatedAtStr != null
        ? (DateTime.tryParse(updatedAtStr) ??
            DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);

    return ElectronicPart(
      id: id,
      name: name,
      category: PartCategory.fromString(
        (json['category'] as String?) ?? 'other',
      ),
      package: (json['package'] as String?) ?? '',
      valueOrSpecs: (json['valueOrSpecs'] as String?) ?? '',
      quantity: quantity < 0 ? 0 : quantity,
      minStockThreshold: minStockThreshold < 0 ? 0 : minStockThreshold,
      storageLocation: (json['storageLocation'] as String?) ?? '',
      manufacturerPartNumber:
          (json['manufacturerPartNumber'] as String?) ?? '',
      supplierName: (json['supplierName'] as String?) ?? '',
      supplierPartNumber: (json['supplierPartNumber'] as String?) ?? '',
      unitPrice: unitPrice < 0 ? 0.0 : unitPrice,
      datasheetUrl: (json['datasheetUrl'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      updatedAt: updatedAt,
    );
  }

  /// Serializes this [ElectronicPart] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.id,
      'package': package,
      'valueOrSpecs': valueOrSpecs,
      'quantity': quantity,
      'minStockThreshold': minStockThreshold,
      'storageLocation': storageLocation,
      'manufacturerPartNumber': manufacturerPartNumber,
      'supplierName': supplierName,
      'supplierPartNumber': supplierPartNumber,
      'unitPrice': unitPrice,
      'datasheetUrl': datasheetUrl,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Checks whether this part matches a free-text search query.
  bool matchesQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;

    return name.toLowerCase().contains(trimmed) ||
        category.label.toLowerCase().contains(trimmed) ||
        package.toLowerCase().contains(trimmed) ||
        valueOrSpecs.toLowerCase().contains(trimmed) ||
        storageLocation.toLowerCase().contains(trimmed) ||
        manufacturerPartNumber.toLowerCase().contains(trimmed) ||
        supplierName.toLowerCase().contains(trimmed) ||
        supplierPartNumber.toLowerCase().contains(trimmed) ||
        notes.toLowerCase().contains(trimmed);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElectronicPart &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.package == package &&
        other.valueOrSpecs == valueOrSpecs &&
        other.quantity == quantity &&
        other.minStockThreshold == minStockThreshold &&
        other.storageLocation == storageLocation &&
        other.manufacturerPartNumber == manufacturerPartNumber &&
        other.supplierName == supplierName &&
        other.supplierPartNumber == supplierPartNumber &&
        other.unitPrice == unitPrice &&
        other.datasheetUrl == datasheetUrl &&
        other.notes == notes &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        package,
        valueOrSpecs,
        quantity,
        minStockThreshold,
        storageLocation,
        manufacturerPartNumber,
        supplierName,
        supplierPartNumber,
        unitPrice,
        datasheetUrl,
        notes,
        updatedAt,
      );
}
