import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';

void main() {
  group('Catalog Freezed Domain Models', () {
    test('Part supports value equality, copyWith (including setting nullable fields to null), isLowStock, and JSON round-trip', () {
      const resistor = Part(
        id: 'p-r10k',
        name: '10kΩ 0603 1% Resistor',
        quantity: 8,
        lowStockThreshold: 10,
        containerId: 'c-binder-1',
        slot: 'Page 1',
        specs: {'Resistance': '10kΩ', 'Tolerance': '±1%'},
      );

      expect(resistor.isLowStock, isTrue);
      expect(resistor.isUnassigned, isFalse);

      final restocked = resistor.copyWith(quantity: 50);
      expect(restocked.isLowStock, isFalse);
      expect(restocked.name, '10kΩ 0603 1% Resistor');

      final unassigned = restocked.copyWith(containerId: null, slot: null);
      expect(unassigned.isUnassigned, isTrue);
      expect(unassigned.slot, isNull);

      final roundTripped = Part.fromJson(resistor.toJson());
      expect(roundTripped, equals(resistor));
    });

    test('CatalogSnapshot computes exportFileName and detects case-insensitive (Container, Slot) collisions', () {
      final snapshot = CatalogSnapshot(
        updatedAt: DateTime.utc(2026, 11, 3, 14, 30),
        containers: const [
          Container(id: 'c-1', name: 'SMD Binder #1'),
        ],
        parts: const [
          Part(
            id: 'p-1',
            name: '100nF 0603 Cap',
            containerId: 'c-1',
            slot: 'Page 4',
          ),
        ],
      );

      expect(snapshot.exportFileName, 'parts-catalog-2026-11-03.json');
      expect(
        snapshot.findOccupyingSlotPart('c-1', '  page 4 ')?.id,
        'p-1',
      );
      expect(
        snapshot.findOccupyingSlotPart('c-1', 'page 4', excludingPartId: 'p-1'),
        isNull,
      );
      expect(snapshot.findOccupyingSlotPart('c-1', null), isNull);
    });
  });
}
