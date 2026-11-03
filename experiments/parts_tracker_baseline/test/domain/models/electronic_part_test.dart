import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_baseline/domain/models/electronic_part.dart';
import 'package:parts_tracker_baseline/domain/models/part_category.dart';

void main() {
  group('ElectronicPart', () {
    final sampleDate = DateTime.utc(2026, 11, 2, 10, 30);
    final samplePart = ElectronicPart(
      id: 'res-1',
      name: '4.7kΩ Resistor',
      category: PartCategory.resistors,
      package: '0603',
      valueOrSpecs: '4.7kΩ ±1% 0.1W',
      quantity: 4,
      minStockThreshold: 10,
      storageLocation: 'Drawer A1',
      manufacturerPartNumber: 'RC0603FR-074K7L',
      supplierName: 'DigiKey',
      supplierPartNumber: '311-4.70KHRCT-ND',
      unitPrice: 0.02,
      datasheetUrl: 'https://example.com/datasheet.pdf',
      notes: 'I2C pull-up',
      updatedAt: sampleDate,
    );

    test('serializes to and from JSON accurately', () {
      final json = samplePart.toJson();
      final restored = ElectronicPart.fromJson(json);
      expect(restored, equals(samplePart));
    });

    test('computes stock alerts and total value accurately', () {
      expect(samplePart.isLowStock, isTrue);
      expect(samplePart.isOutOfStock, isFalse);
      expect(samplePart.needsRestock, isTrue);
      expect(samplePart.totalValue, closeTo(0.08, 0.0001));

      final outOfStock = samplePart.copyWith(quantity: 0);
      expect(outOfStock.isOutOfStock, isTrue);
      expect(outOfStock.isLowStock, isFalse);
      expect(outOfStock.needsRestock, isTrue);
    });

    test('matchesQuery searches across name, package, MPN, supplier, and bin', () {
      expect(samplePart.matchesQuery('4.7k'), isTrue);
      expect(samplePart.matchesQuery('0603'), isTrue);
      expect(samplePart.matchesQuery('RC0603'), isTrue);
      expect(samplePart.matchesQuery('drawer a1'), isTrue);
      expect(samplePart.matchesQuery('digikey'), isTrue);
      expect(samplePart.matchesQuery('esp32'), isFalse);
    });

    test('formattedUnitPrice preserves sub-cent precision and standard 2-decimal format', () {
      expect(samplePart.copyWith(unitPrice: 0.02).formattedUnitPrice, '0.02');
      expect(samplePart.copyWith(unitPrice: 3.2).formattedUnitPrice, '3.20');
      expect(samplePart.copyWith(unitPrice: 5.0).formattedUnitPrice, '5.00');
      expect(
        samplePart.copyWith(unitPrice: 0.0045).formattedUnitPrice,
        '0.0045',
      );
    });
  });
}
