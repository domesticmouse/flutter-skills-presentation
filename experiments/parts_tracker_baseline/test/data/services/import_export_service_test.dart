import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_baseline/data/services/import_export_service.dart';
import 'package:parts_tracker_baseline/domain/models/electronic_part.dart';
import 'package:parts_tracker_baseline/domain/models/part_category.dart';

void main() {
  group('ImportExportService', () {
    const service = ImportExportService();
    final now = DateTime.utc(2026, 11, 2, 12, 0);

    final parts = [
      ElectronicPart(
        id: 'p1',
        name: 'NE555 Timer, Precision',
        category: PartCategory.icsAndMcus,
        package: 'DIP-8',
        valueOrSpecs: '4.5V to 16V, 2mA',
        quantity: 12,
        minStockThreshold: 5,
        storageLocation: 'IC Tray 1, Row B',
        manufacturerPartNumber: 'NE555P',
        supplierName: 'Mouser',
        supplierPartNumber: '595-NE555P',
        unitPrice: 0.45,
        datasheetUrl: 'https://ti.com/ne555.pdf',
        notes: 'Classic "555" astable/monostable timer',
        updatedAt: now,
      ),
    ];

    test('round-trips JSON export and import', () {
      final jsonStr = service.exportToJson(parts);
      final imported = service.importFromJson(jsonStr);
      expect(imported.length, 1);
      expect(imported.first, equals(parts.first));
    });

    test('round-trips CSV export and import with commas, quotes, and sub-cent unit price', () {
      final subCentParts = [
        parts.first.copyWith(unitPrice: 0.0045),
      ];
      final csvStr = service.exportToCsv(subCentParts);
      final imported = service.importFromCsv(csvStr);
      expect(imported.length, 1);
      expect(imported.first.id, 'p1');
      expect(imported.first.name, 'NE555 Timer, Precision');
      expect(imported.first.storageLocation, 'IC Tray 1, Row B');
      expect(imported.first.notes, 'Classic "555" astable/monostable timer');
      expect(imported.first.unitPrice, closeTo(0.0045, 0.000001));
    });
  });
}
