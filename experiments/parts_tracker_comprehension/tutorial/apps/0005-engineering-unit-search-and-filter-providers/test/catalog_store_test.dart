import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';
import 'package:parts_tracker_skilled/catalog/catalog_persistence.dart';
import 'package:parts_tracker_skilled/catalog/catalog_provider.dart';
import 'package:parts_tracker_skilled/search/workbench_filter_provider.dart';

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

      // Attempting to assign a Part to an unknown containerId throws ArgumentError
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

      // Assign first Part to (c-binder, Page 4)
      await notifier.upsertPart(
        const Part(
          id: 'p-1',
          name: '100nF 0603 Cap',
          lcscCode: 'C14663',
          containerId: 'c-binder',
          slot: 'Page 4',
        ),
      );

      // Attempting to assign a different Part to the same (Container, Slot) (case-insensitive) fails and names the occupying Part
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

      // Multiple bulk slotless Parts in the same Container are permitted
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

      // Multiple unassigned Parts are permitted, and slot is cleared if containerId is null
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

      // Duplicate lcscCode detection (case-insensitive, excluding self when editing)
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

      // Deleting c-binder atomically unassigns p-1, p-bulk-1, and p-bulk-2
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

      // 1. Malformed JSON
      expect(
        () => notifier.validateImport('{not valid json'),
        throwsA(isA<CatalogImportValidationException>()),
      );

      // 2. Unsupported schemaVersion
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

      // 3. Negative quantity
      expect(
        () => notifier.validateImport('''
        {
          "schemaVersion": 1,
          "updatedAt": "2026-11-03T02:35:00.000Z",
          "containers": [],
          "parts": [
            {"id": "p1", "name": "Bad Qty", "quantity": -1}
          ]
        }
        '''),
        throwsA(
          isA<CatalogImportValidationException>().having(
            (e) => e.message,
            'message',
            contains('quantity'),
          ),
        ),
      );

      // 4. Duplicate Part ID
      expect(
        () => notifier.validateImport('''
        {
          "schemaVersion": 1,
          "updatedAt": "2026-11-03T02:35:00.000Z",
          "containers": [],
          "parts": [
            {"id": "dup", "name": "Part A", "quantity": 1},
            {"id": "dup", "name": "Part B", "quantity": 2}
          ]
        }
        '''),
        throwsA(
          isA<CatalogImportValidationException>().having(
            (e) => e.message,
            'message',
            contains('Duplicate part id'),
          ),
        ),
      );

      // 5. Broken containerId reference
      expect(
        () => notifier.validateImport('''
        {
          "schemaVersion": 1,
          "updatedAt": "2026-11-03T02:35:00.000Z",
          "containers": [],
          "parts": [
            {"id": "p1", "name": "Orphan Part", "quantity": 1, "containerId": "missing-c"}
          ]
        }
        '''),
        throwsA(
          isA<CatalogImportValidationException>().having(
            (e) => e.message,
            'message',
            contains('missing-c'),
          ),
        ),
      );

      // 6. Duplicate non-empty (containerId, slot) pair
      expect(
        () => notifier.validateImport('''
        {
          "schemaVersion": 1,
          "updatedAt": "2026-11-03T02:35:00.000Z",
          "containers": [
            {"id": "c1", "name": "Binder 1"}
          ],
          "parts": [
            {"id": "p1", "name": "Part A", "quantity": 1, "containerId": "c1", "slot": "Page 1"},
            {"id": "p2", "name": "Part B", "quantity": 2, "containerId": "c1", "slot": "page 1"}
          ]
        }
        '''),
        throwsA(
          isA<CatalogImportValidationException>().having(
            (e) => e.message,
            'message',
            contains('Page 1'),
          ),
        ),
      );

      // Existing catalog remains untouched after failed validations
      final untouched = await container.read(catalogProvider.future);
      expect(untouched.parts.single.id, 'existing-p1');

      // 7. Valid import snapshot (including whitespace-only optional fields and untrimmed specs)
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
      expect(validated.parts.single.manufacturer, isNull);
      expect(validated.parts.single.category, 'Ceramic Capacitors');
      expect(validated.parts.single.package, isNull);
      expect(validated.parts.single.datasheetUrl, isNull);
      expect(validated.parts.single.notes, isNull);
      expect(validated.parts.single.specs, {'Capacitance': '100nF'});

      await notifier.importSnapshot(validated);
      expect(persistence.lastPreImportBackup?.parts.single.id, 'existing-p1');

      final replaced = await container.read(catalogProvider.future);
      expect(replaced.parts.single.id, 'p-c14663');
      expect(replaced.containers.single.id, 'c-binder-1');

      final exportPath = await notifier.exportBackupFile();
      expect(exportPath, contains('parts-catalog-'));
    });

    test('searches across 10 fields with multi-token AND, Unicode folding, SI & EE-infix equivalence, non-expansion of 104, 3-tier ranking, filter chips, and natural By Container grouping', () async {
      final persistence = InMemoryCatalogPersistence();
      final container = ProviderContainer(
        overrides: [
          catalogPersistenceProvider.overrideWithValue(persistence),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(catalogProvider.notifier);
      await notifier.upsertContainer(
        const Container(id: 'c-b', name: 'SMD Binder #1'),
      );
      await notifier.upsertContainer(
        const Container(id: 'c-a', name: 'IC Drawer Cabinet'),
      );
      await notifier.upsertContainer(
        const Container(id: 'c-empty', name: 'Empty Tote'),
      );

      // Part 1: 4.7kΩ 0603 resistor in Page 10
      await notifier.upsertPart(
        const Part(
          id: 'p-r4k7',
          name: '4.7kΩ ±1% 0603 Resistor',
          quantity: 12,
          lowStockThreshold: 20, // Low stock!
          lcscCode: 'C23162',
          mpn: 'RC0603FR-074K7L',
          manufacturer: 'YAGEO',
          category: 'Chip Resistor - Surface Mount',
          package: '0603',
          containerId: 'c-b',
          slot: 'Page 10',
          notes: 'I2C pull-up',
          specs: {
            'Resistance': '4.7kΩ',
            'Tolerance': '±1%',
          },
        ),
      );

      // Part 2: 100nF 50V X7R capacitor in Page 2
      await notifier.upsertPart(
        const Part(
          id: 'p-c100n',
          name: '100nF 50V X7R 0603 Capacitor',
          quantity: 180,
          lowStockThreshold: 50,
          lcscCode: 'C14663',
          mpn: 'CL10B104KB8NNNC',
          manufacturer: 'SAMSUNG',
          category: 'Ceramic Capacitors',
          package: '0603',
          containerId: 'c-b',
          slot: 'Page 2',
          notes: 'Decoupling cap',
          specs: {
            'Capacitance': '100nF',
            'Voltage Rated': '50V',
            'Temperature Coefficient': 'X7R',
          },
        ),
      );

      // Part 3: 10µF 25V capacitor (Unicode µ, stored in bulk in SMD Binder #1)
      await notifier.upsertPart(
        const Part(
          id: 'p-c10u',
          name: '10µF 25V X5R 0805 Capacitor',
          quantity: 40,
          lowStockThreshold: 10,
          lcscCode: 'C15850',
          mpn: 'CL21A106KAYNNNE',
          manufacturer: 'SAMSUNG',
          category: 'Ceramic Capacitors',
          package: '0805',
          containerId: 'c-b',
          slot: null,
          specs: {
            'Capacitance': '10μF',
            'Voltage Rated': '25V',
          },
        ),
      );

      // Part 4: 3.3V LDO regulator (Unassigned)
      await notifier.upsertPart(
        const Part(
          id: 'p-ldo',
          name: 'AMS1117-3.3 LDO Regulator',
          quantity: 0, // Low stock (0 <= 0) & Unassigned
          lcscCode: 'C6186',
          mpn: 'AMS1117-3.3',
          manufacturer: 'AMS',
          category: 'Linear Voltage Regulators',
          package: 'SOT-223',
          containerId: null,
          slot: null,
          notes: 'Mentioned 4700R feedback in notes',
          specs: {
            'Output Voltage': '3.3V',
          },
        ),
      );

      // Part 5: 4.7Ω sense resistor in IC Drawer Cabinet
      await notifier.upsertPart(
        const Part(
          id: 'p-r4r7',
          name: '4.7Ω 1% 0805 Sense Resistor',
          quantity: 25,
          lcscCode: 'C17710',
          mpn: '4700R-TEST-MPN',
          manufacturer: 'UNI-ROYAL',
          category: 'Chip Resistor - Surface Mount',
          package: '0805',
          containerId: 'c-a',
          slot: 'Drawer A2',
          specs: {
            'Resistance': '4.7Ω',
            'Filter Capacitor': '2.2nF',
          },
        ),
      );

      await container.read(catalogProvider.future);

      List<Part> searchParts(String query) {
        container.read(searchQueryProvider.notifier).setQuery(query);
        return container.read(filteredWorkbenchViewProvider).flatParts;
      }

      // Engineering unit equivalence: "4k7" and uppercase "4K7" / "4.7KΩ" match "4.7kΩ"
      expect(searchParts('4k7').map((p) => p.id), contains('p-r4k7'));
      expect(searchParts('4K7').map((p) => p.id), contains('p-r4k7'));
      expect(searchParts('4.7KΩ').map((p) => p.id), contains('p-r4k7'));
      // Engineering unit equivalence: "4700R" ranks Tier 1 MPN match ('4700R-TEST-MPN') first, then Tier 2 engineering value match ('p-r4k7'), then Tier 3 notes match ('p-ldo')
      expect(
        searchParts('4700R').map((p) => p.id).toList(),
        ['p-r4r7', 'p-r4k7', 'p-ldo'],
      );

      // Engineering unit equivalence: "0.1uF 50V" and uppercase "0.1UF" / "100NF" match "100nF" + "50V"
      expect(
        searchParts('0.1uF 50V').map((p) => p.id).toList(),
        ['p-c100n'],
      );
      expect(
        searchParts('0.1UF 100NF').map((p) => p.id).toList(),
        ['p-c100n'],
      );
      expect(
        searchParts('100000pF x7r').map((p) => p.id).toList(),
        ['p-c100n'],
      );

      // Engineering unit equivalence: "3v3" matches "3.3V"
      expect(
        searchParts('3v3').map((p) => p.id).toList(),
        ['p-ldo'],
      );

      // Engineering unit equivalence: "4r7" matches "4.7Ω" and "2n2" matches "2.2nF"
      expect(
        searchParts('4r7 2n2').map((p) => p.id).toList(),
        ['p-r4r7'],
      );

      // Unicode folding: "10uF" matches "10µF" / "10μF"
      expect(
        searchParts('10uF').map((p) => p.id).toList(),
        ['p-c10u'],
      );

      // Bare 3-digit EIA number "104" matches MPN substring "CL10B104KB8NNNC" ONLY, without expanding into 100nF or 100kΩ
      expect(
        searchParts('104').map((p) => p.id).toList(),
        ['p-c100n'],
      );
      // And "472" (which would be 4.7kΩ if expanded) does NOT match p-r4k7
      expect(searchParts('472'), isEmpty);

      // Search across Container.name, slot, and notes ("binder page 10 i2c" and "cabinet a2")
      expect(
        searchParts('binder page 10 i2c').map((p) => p.id).toList(),
        ['p-r4k7'],
      );
      expect(
        searchParts('cabinet a2').map((p) => p.id).toList(),
        ['p-r4r7'],
      );

      // Reset search query and test Filter Chips
      container.read(searchQueryProvider.notifier).setQuery('');
      container.read(selectedFacetProvider.notifier).setFacet(
            const WorkbenchFacet.lowStock(),
          );
      expect(
        container.read(filteredWorkbenchViewProvider).flatParts.map((p) => p.id).toSet(),
        {'p-r4k7', 'p-ldo'},
      );

      container.read(selectedFacetProvider.notifier).setFacet(
            const WorkbenchFacet.unassigned(),
          );
      expect(
        container.read(filteredWorkbenchViewProvider).flatParts.map((p) => p.id).toList(),
        ['p-ldo'],
      );

      container.read(selectedFacetProvider.notifier).setFacet(
            const WorkbenchFacet.category('Ceramic Capacitors'),
          );
      expect(
        container.read(filteredWorkbenchViewProvider).flatParts.map((p) => p.id).toSet(),
        {'p-c100n', 'p-c10u'},
      );

      // By Container grouping with All facet and empty search:
      // Shows Unassigned first, then alphabetical Containers (Empty Tote, IC Drawer Cabinet, SMD Binder #1),
      // and natural Slot ordering inside SMD Binder #1 ("Page 2", "Page 10", then null slot last).
      container.read(selectedFacetProvider.notifier).setFacet(
            const WorkbenchFacet.all(),
          );
      container.read(groupByContainerProvider.notifier).setGrouped(true);

      final groupedAll = container.read(filteredWorkbenchViewProvider).containerGroups;
      expect(
        groupedAll.map((g) => g.title).toList(),
        [
          'Unassigned (Loose / Inbox)',
          'Empty Tote',
          'IC Drawer Cabinet',
          'SMD Binder #1',
        ],
      );
      final binderGroup = groupedAll.firstWhere((g) => g.title == 'SMD Binder #1');
      expect(
        binderGroup.parts.map((p) => p.id).toList(),
        ['p-c100n', 'p-r4k7', 'p-c10u'], // Page 2, Page 10, null slot
      );

      // When a filter or search query is active in By Container mode, empty Containers are hidden
      container.read(selectedFacetProvider.notifier).setFacet(
            const WorkbenchFacet.lowStock(),
          );
      final groupedLowStock = container.read(filteredWorkbenchViewProvider).containerGroups;
      expect(
        groupedLowStock.map((g) => g.title).toList(),
        [
          'Unassigned (Loose / Inbox)',
          'SMD Binder #1',
        ],
      );
    });
  });
}
