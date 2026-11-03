import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_baseline/data/repositories/parts_repository.dart';
import 'package:parts_tracker_baseline/data/services/local_storage_service.dart';
import 'package:parts_tracker_baseline/domain/models/electronic_part.dart';
import 'package:parts_tracker_baseline/domain/models/part_category.dart';
import 'package:parts_tracker_baseline/ui/features/inventory/view_models/inventory_view_model.dart';

void main() {
  group('InventoryViewModel', () {
    late InMemoryLocalStorageService storageService;
    late PartsRepository repository;
    late InventoryViewModel viewModel;

    setUp(() async {
      storageService = InMemoryLocalStorageService();
      repository = PartsRepository(
        storageService: storageService,
        seedSampleDataWhenEmpty: true,
      );
      viewModel = InventoryViewModel(repository: repository);
      await viewModel.loadInventory();
    });

    test('loads starter sample parts on initial run', () {
      expect(viewModel.totalDistinctParts, greaterThan(0));
      expect(viewModel.restockCount, greaterThan(0));
    });

    test('saves a new part and updates metrics', () async {
      final initialCount = viewModel.totalDistinctParts;
      final newPart = ElectronicPart(
        id: 'test-led-1',
        name: 'Red 5mm LED',
        category: PartCategory.ledsAndDisplays,
        package: 'Through-Hole 5mm',
        valueOrSpecs: '2.0V Vf 20mA',
        quantity: 50,
        minStockThreshold: 10,
        storageLocation: 'LED Drawer',
        updatedAt: DateTime.utc(2026, 11, 2),
      );

      await viewModel.savePart(newPart);
      expect(viewModel.totalDistinctParts, initialCount + 1);
      expect(viewModel.getPartById('test-led-1')?.quantity, 50);
    });

    test('adjusts quantity and clamps at zero', () async {
      final firstId = viewModel.allParts.first.id;
      final initialQty = viewModel.allParts.first.quantity;

      await viewModel.adjustQuantity(firstId, 5);
      expect(viewModel.getPartById(firstId)?.quantity, initialQty + 5);

      await viewModel.adjustQuantity(firstId, -99999);
      expect(viewModel.getPartById(firstId)?.quantity, 0);
    });

    test('renames storage location across matching parts and updates selectedLocation', () async {
      await viewModel.renameLocation(
        oldLocation: 'SMD Book 1 - Page 4',
        newLocation: 'SMD Binder A',
      );
      expect(viewModel.distinctLocationNames, contains('SMD Binder A'));
      expect(
        viewModel.distinctLocationNames,
        isNot(contains('SMD Book 1 - Page 4')),
      );

      // Verify renaming Unassigned parts updates selectedLocation filter
      await viewModel.savePart(
        ElectronicPart(
          id: 'unassigned-part',
          name: 'Loose Jumper Wire',
          category: PartCategory.connectors,
          package: 'Dupont',
          valueOrSpecs: '20cm M-M',
          quantity: 10,
          storageLocation: '',
          updatedAt: DateTime.utc(2026, 11, 2),
        ),
      );
      viewModel.setSelectedLocation('Unassigned');
      expect(viewModel.selectedLocation, 'Unassigned');

      await viewModel.renameLocation(
        oldLocation: '',
        newLocation: 'Bin Z9',
      );
      expect(viewModel.selectedLocation, 'Bin Z9');
      expect(viewModel.getPartById('unassigned-part')?.storageLocation, 'Bin Z9');
    });

    test('importData merge mode returns imported record count when updating existing IDs', () async {
      final existing = viewModel.allParts.first;
      final jsonPayload = '''
[
  {
    "id": "${existing.id}",
    "name": "${existing.name}",
    "category": "${existing.category.id}",
    "quantity": 999
  }
]
''';
      final importedCount = await viewModel.importData(
        content: jsonPayload,
        isCsv: false,
        replaceExisting: false,
      );
      expect(importedCount, 1);
      expect(viewModel.getPartById(existing.id)?.quantity, 999);
    });

    test('corrupt storage file sets errorMessage instead of overwriting with sample data', () async {
      final tempDir = await Directory.systemTemp.createTemp('parts_test_');
      addTearDown(() => tempDir.delete(recursive: true));
      final corruptFile = File('${tempDir.path}/corrupt_inventory.json');
      await corruptFile.writeAsString('{not_valid_json');

      final corruptRepo = PartsRepository(
        storageService: FileLocalStorageService(
          customFilePath: corruptFile.path,
        ),
      );
      final corruptVm = InventoryViewModel(repository: corruptRepo);
      await corruptVm.loadInventory();

      expect(corruptVm.errorMessage, isNotNull);
      expect(await corruptFile.readAsString(), '{not_valid_json');

      corruptVm.clearError();
      expect(corruptVm.errorMessage, isNull);
    });
  });
}
