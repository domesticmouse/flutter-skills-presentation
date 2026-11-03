import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';
import 'package:parts_tracker_skilled/catalog/catalog_persistence.dart';
import 'package:parts_tracker_skilled/catalog/catalog_provider.dart';

void main() {
  group('Catalog Store Seam', () {
    test('loads empty schemaVersion 1 catalog on first launch and upserts a Part with specs', () async {
      final persistence = InMemoryCatalogPersistence();
      final container = ProviderContainer(
        overrides: [
          catalogPersistenceProvider.overrideWithValue(persistence),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(catalogProvider.future);
      expect(initial.schemaVersion, 1);
      expect(initial.containers, isEmpty);
      expect(initial.parts, isEmpty);

      final notifier = container.read(catalogProvider.notifier);
      await notifier.upsertPart(
        const Part(
          id: 'p-c14663',
          name: '  100nF 50V X7R 0603 Capacitor  ',
          quantity: 185,
          lcscCode: 'c14663',
          mpn: 'CC0603KRX7R9BB104',
          manufacturer: 'YAGEO',
          category: 'Ceramic Capacitors',
          package: '0603',
          datasheetUrl: 'https://datasheet.lcsc.com/lcsc/C14663.pdf',
          lowStockThreshold: 50,
          notes: 'Standard decoupling cap',
          specs: {
            'Capacitance': '100nF',
            'Voltage Rated': '50V',
          },
        ),
      );

      final updated = await container.read(catalogProvider.future);
      expect(updated.parts, hasLength(1));
      final savedPart = updated.parts.single;
      expect(savedPart.id, 'p-c14663');
      expect(savedPart.name, '100nF 50V X7R 0603 Capacitor');
      expect(savedPart.lcscCode, 'C14663');
      expect(savedPart.quantity, 185);
      expect(savedPart.specs, {
        'Capacitance': '100nF',
        'Voltage Rated': '50V',
      });

      final persisted = await persistence.load();
      expect(persisted.parts.single.name, '100nF 50V X7R 0603 Capacitor');
    });

    test('adjusts and sets Part quantity with clamping at 0, flags low stock, and deletes a Part', () async {
      final persistence = InMemoryCatalogPersistence();
      final container = ProviderContainer(
        overrides: [
          catalogPersistenceProvider.overrideWithValue(persistence),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(catalogProvider.notifier);
      await notifier.upsertPart(
        const Part(
          id: 'p-1',
          name: '10kΩ 0603 Resistor',
          quantity: 12,
          lowStockThreshold: 10,
        ),
      );

      var part = (await container.read(catalogProvider.future)).parts.single;
      expect(part.isLowStock, isFalse);

      await notifier.adjustQuantity('p-1', -2);
      part = (await container.read(catalogProvider.future)).parts.single;
      expect(part.quantity, 10);
      expect(part.isLowStock, isTrue);

      await notifier.adjustQuantity('p-1', -25);
      part = (await container.read(catalogProvider.future)).parts.single;
      expect(part.quantity, 0);
      expect(part.isLowStock, isTrue);

      await notifier.setQuantity('p-1', 42);
      part = (await container.read(catalogProvider.future)).parts.single;
      expect(part.quantity, 42);
      expect(part.isLowStock, isFalse);

      await notifier.setQuantity('p-1', -5);
      part = (await container.read(catalogProvider.future)).parts.single;
      expect(part.quantity, 0);

      await notifier.deletePart('p-1');
      final afterDelete = await container.read(catalogProvider.future);
      expect(afterDelete.parts, isEmpty);
    });

    test('enforces strict 1-to-1 (Container, Slot) uniqueness, cascades Container deletion to unassign Parts, and finds duplicate lcscCode', () async {
      final persistence = InMemoryCatalogPersistence();
      final container = ProviderContainer(
        overrides: [
          catalogPersistenceProvider.overrideWithValue(persistence),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(catalogProvider.notifier);
      await notifier.upsertContainer(
        const Container(
          id: 'c-binder',
          name: '  SMD Binder #1  ',
          description: '  0603 R/C sample book  ',
        ),
      );

      final afterContainer = await container.read(catalogProvider.future);
      expect(afterContainer.containers.single.name, 'SMD Binder #1');
      expect(afterContainer.containers.single.description, '0603 R/C sample book');

      await expectLater(
        () => notifier.upsertPart(
          const Part(
            id: 'p-orphan-container',
            name: 'Orphan Container Part',
            containerId: 'c-does-not-exist',
          ),
        ),
        throwsArgumentError,
      );

      await notifier.upsertPart(
        const Part(
          id: 'p-1',
          name: '100nF 0603 Cap',
          lcscCode: 'C14663',
          containerId: 'c-binder',
          slot: 'Page 4',
        ),
      );

      await expectLater(
        () => notifier.upsertPart(
          const Part(
            id: 'p-2',
            name: '10kΩ 0603 Resistor',
            containerId: 'c-binder',
            slot: '  page 4 ',
          ),
        ),
        throwsA(
          isA<SlotOccupiedException>().having(
            (e) => e.occupyingPart.name,
            'occupyingPart.name',
            '100nF 0603 Cap',
          ),
        ),
      );

      await notifier.upsertPart(
        const Part(
          id: 'p-bulk-1',
          name: 'Bulk LED Red',
          containerId: 'c-binder',
          slot: null,
        ),
      );
      await notifier.upsertPart(
        const Part(
          id: 'p-bulk-2',
          name: 'Bulk LED Green',
          containerId: 'c-binder',
          slot: '   ',
        ),
      );

      await notifier.upsertPart(
        const Part(
          id: 'p-loose-1',
          name: 'NE555P Timer',
          containerId: null,
          slot: 'Orphan Slot',
        ),
      );
      await notifier.upsertPart(
        const Part(
          id: 'p-loose-2',
          name: 'LM358 OpAmp',
          containerId: null,
          slot: null,
        ),
      );

      final snap = await container.read(catalogProvider.future);
      final loose1 = snap.parts.firstWhere((p) => p.id == 'p-loose-1');
      expect(loose1.containerId, isNull);
      expect(loose1.slot, isNull);

      expect(
        notifier.findDuplicateLcscPart('c14663')?.id,
        'p-1',
      );
      expect(
        notifier.findDuplicateLcscPart('14663')?.id,
        'p-1',
      );
      expect(
        notifier.findDuplicateLcscPart('C14663', excludingPartId: 'p-1'),
        isNull,
      );

      await notifier.deleteContainer('c-binder');
      final afterDeleteContainer = await container.read(catalogProvider.future);
      expect(afterDeleteContainer.containers, isEmpty);
      for (final p in afterDeleteContainer.parts) {
        expect(p.containerId, isNull);
        expect(p.slot, isNull);
      }
    });

    test('validates JSON imports strictly all-or-nothing, backs up existing catalog on import, and exports backup file', () async {
      final persistence = InMemoryCatalogPersistence();
      final container = ProviderContainer(
        overrides: [
          catalogPersistenceProvider.overrideWithValue(persistence),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(catalogProvider.notifier);
      await notifier.upsertPart(
        const Part(id: 'existing-p1', name: 'Existing Part', quantity: 5),
      );

      expect(
        () => notifier.validateImport('{not valid json'),
        throwsA(isA<CatalogImportValidationException>()),
      );

      expect(
        () => notifier.validateImport('''
        {
          "schemaVersion": 2,
          "updatedAt": "2026-11-03T02:35:00.000Z",
          "containers": [],
          "parts": []
        }
        '''),
        throwsA(
          isA<CatalogImportValidationException>().having(
            (e) => e.message,
            'message',
            contains('schemaVersion'),
          ),
        ),
      );

      final validated = notifier.validateImport('''
      {
        "schemaVersion": 1,
        "updatedAt": "2026-11-03T02:35:00.000Z",
        "containers": [
          {"id": "c-binder-1", "name": "SMD Binder #1", "description": "0603 R/C"}
        ],
        "parts": [
          {
            "id": "p-c14663",
            "name": "100nF 50V X7R 0603 Capacitor",
            "quantity": 185,
            "lcscCode": "C14663",
            "mpn": "   ",
            "manufacturer": "",
            "category": "  Ceramic Capacitors  ",
            "package": "   ",
            "datasheetUrl": "   ",
            "notes": "   ",
            "containerId": "c-binder-1",
            "slot": "Page 4",
            "specs": {"  Capacitance  ": "  100nF  ", "   ": "ignored"}
          }
        ]
      }
      ''');

      expect(validated.containers, hasLength(1));
      expect(validated.parts, hasLength(1));
      expect(validated.parts.single.mpn, isNull);
      expect(validated.parts.single.category, 'Ceramic Capacitors');
      expect(validated.parts.single.specs, {'Capacitance': '100nF'});

      await notifier.importSnapshot(validated);
      expect(persistence.lastPreImportBackup?.parts.single.id, 'existing-p1');

      final replaced = await container.read(catalogProvider.future);
      expect(replaced.parts.single.id, 'p-c14663');
    });
  });
}
