import 'package:flutter/material.dart' hide Container;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';
import 'package:parts_tracker_skilled/catalog/catalog_persistence.dart';
import 'package:parts_tracker_skilled/catalog/catalog_provider.dart';
import 'package:parts_tracker_skilled/lcsc/lcsc_client.dart';
import 'package:parts_tracker_skilled/main.dart';

class FakeLcscClient implements LcscClient {
  FakeLcscClient(this.responses);

  final Map<String, LcscPartMetadata> responses;

  @override
  Future<LcscPartMetadata> fetchPart(String rawCode) async {
    final code = LcscClient.normalizeLcscCode(rawCode);
    final found = responses[code];
    if (found == null) {
      throw LcscPartNotFoundException(code);
    }
    return found;
  }
}

void main() {
  CatalogSnapshot buildSampleSnapshot() {
    return CatalogSnapshot(
      schemaVersion: 1,
      updatedAt: DateTime.utc(2026, 11, 3, 2, 0),
      containers: const [
        Container(
          id: 'c-binder-1',
          name: 'SMD Binder #1',
          description: '0603 R/C sample book',
        ),
      ],
      parts: const [
        Part(
          id: 'p-r4k7',
          name: '4.7kΩ 0603 1% SMD Resistor',
          quantity: 5,
          lowStockThreshold: 10,
          lcscCode: 'C23162',
          mpn: 'RC0603FR-074K7L',
          manufacturer: 'YAGEO',
          category: 'Chip Resistors',
          package: '0603',
          containerId: 'c-binder-1',
          slot: 'Page 2',
          specs: {
            'Resistance': '4.7kΩ',
            'Tolerance': '±1%',
          },
        ),
        Part(
          id: 'p-c100n',
          name: '100nF 50V X7R 0603 Capacitor',
          quantity: 100,
          lowStockThreshold: 25,
          lcscCode: 'C14663',
          mpn: 'CL10B104KB8NNNC',
          manufacturer: 'SAMSUNG',
          category: 'Ceramic Capacitors',
          package: '0603',
          datasheetUrl: 'https://datasheet.lcsc.com/lcsc/C14663.pdf',
          containerId: null,
          slot: null,
          specs: {
            'Capacitance': '100nF',
            'Voltage Rated': '50V',
          },
        ),
      ],
    );
  }

  testWidgets(
    'Workbench renders Dark Command Bar & Inline Accordion, adjusts stock inline with clamping, and sets exact quantity in Part Detail sheet',
    (WidgetTester tester) async {
      final persistence = InMemoryCatalogPersistence(buildSampleSnapshot());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogPersistenceProvider.overrideWithValue(persistence),
          ],
          child: const PartsTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Both parts are visible on launch
      expect(find.text('4.7kΩ 0603 1% SMD Resistor'), findsOneWidget);
      expect(find.text('100nF 50V X7R 0603 Capacitor'), findsOneWidget);

      // Tap the 4.7kΩ resistor card to expand its inline accordion
      await tester.tap(find.text('4.7kΩ 0603 1% SMD Resistor'));
      await tester.pumpAndSettle();

      // Spec chips and quick stock adjustment buttons appear
      expect(find.text('Resistance: 4.7kΩ'), findsOneWidget);
      expect(find.text('-10'), findsOneWidget);
      expect(find.text('+10'), findsOneWidget);

      // Tap -10 -> clamps at 0
      await tester.tap(find.text('-10'));
      await tester.pumpAndSettle();
      expect((await persistence.load()).parts.first.quantity, 0);

      // Tap +10 -> becomes 10
      await tester.tap(find.text('+10'));
      await tester.pumpAndSettle();
      expect((await persistence.load()).parts.first.quantity, 10);

      // Open Part Detail sheet and use Set... exact quantity
      await tester.tap(find.text('Details & Edit'));
      await tester.pumpAndSettle();

      expect(find.textContaining('RC0603FR-074K7L'), findsOneWidget);
      await tester.tap(find.text('Set…'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('set_exact_quantity_input')),
        '75',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect((await persistence.load()).parts.first.quantity, 75);
    },
  );

  testWidgets(
    'Add Part sheet fetches LCSC metadata, shows duplicate lcscCode warning with Jump to Part, and enforces (Container, Slot) uniqueness',
    (WidgetTester tester) async {
      final persistence = InMemoryCatalogPersistence(buildSampleSnapshot());
      final fakeLcsc = FakeLcscClient({
        'C9999': const LcscPartMetadata(
          lcscCode: 'C9999',
          name: 'Bare Breakout Board',
        ),
        'C2040': const LcscPartMetadata(
          lcscCode: 'C2040',
          name: 'RP2040 Dual Cortex-M0+ MCU',
          mpn: 'RP2040',
          manufacturer: 'Raspberry Pi',
          category: 'Microcontrollers',
          package: 'LQFN-56',
          datasheetUrl: 'https://datasheet.lcsc.com/lcsc/C2040.pdf',
          specs: {'Core': 'ARM Cortex-M0+', 'Clock': '133MHz'},
        ),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogPersistenceProvider.overrideWithValue(persistence),
            lcscClientProvider.overrideWithValue(fakeLcsc),
          ],
          child: const PartsTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap New Part button
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      // Enter an already-existing LCSC code (C14663) -> duplicate warning banner appears
      await tester.enterText(
        find.byKey(const Key('part_lcsc_input')),
        '14663',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('already in your catalog'), findsOneWidget);
      expect(find.text('Jump to Part'), findsOneWidget);

      // Now enter C2040 and tap Fetch LCSC
      await tester.enterText(
        find.byKey(const Key('part_lcsc_input')),
        '2040',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fetch LCSC'));
      await tester.pumpAndSettle();

      // Verify pre-filled fields, then fetch C9999 (which has null optional fields) to verify stale values are cleared, then re-fetch C2040
      expect(find.text('RP2040 Dual Cortex-M0+ MCU'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('part_lcsc_input')),
        '9999',
      );
      await tester.tap(find.text('Fetch LCSC'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byKey(const Key('part_mpn_input'))).controller?.text,
        isEmpty,
      );

      await tester.enterText(
        find.byKey(const Key('part_lcsc_input')),
        '2040',
      );
      await tester.tap(find.text('Fetch LCSC'));
      await tester.pumpAndSettle();
      expect(find.text('RP2040 Dual Cortex-M0+ MCU'), findsOneWidget);

      // Select SMD Binder #1 and try occupied slot "Page 2"
      await tester.tap(find.byKey(const Key('part_container_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SMD Binder #1').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('part_slot_input')),
        'Page 2',
      );
      await tester.pumpAndSettle();

      // Inline slot occupied error appears naming the occupying Part
      expect(
        find.textContaining('4.7kΩ 0603 1% SMD Resistor'),
        findsWidgets,
      );

      // Change slot to unoccupied "Page 5" and save
      await tester.enterText(
        find.byKey(const Key('part_slot_input')),
        'Page 5',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_part_button')));
      await tester.pumpAndSettle();

      final savedCatalog = await persistence.load();
      expect(savedCatalog.parts, hasLength(3));
      final savedRp2040 =
          savedCatalog.parts.firstWhere((p) => p.lcscCode == 'C2040');
      expect(savedRp2040.name, 'RP2040 Dual Cortex-M0+ MCU');
      expect(savedRp2040.slot, 'Page 5');
      expect(savedRp2040.specs['Core'], 'ARM Cortex-M0+');
    },
  );

  testWidgets(
    'Searches with engineering unit equivalence, filters by chip, groups By Container, and manages Containers',
    (WidgetTester tester) async {
      final persistence = InMemoryCatalogPersistence(buildSampleSnapshot());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogPersistenceProvider.overrideWithValue(persistence),
          ],
          child: const PartsTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Search "0.1uF" -> matches 100nF capacitor only
      await tester.enterText(
        find.byKey(const Key('workbench_search_input')),
        '0.1uF',
      );
      await tester.pumpAndSettle();
      expect(find.text('100nF 50V X7R 0603 Capacitor'), findsOneWidget);
      expect(find.text('4.7kΩ 0603 1% SMD Resistor'), findsNothing);

      // Clear search
      await tester.tap(find.byKey(const Key('clear_search_button')));
      await tester.pumpAndSettle();
      expect(find.text('4.7kΩ 0603 1% SMD Resistor'), findsOneWidget);

      // Toggle By Container mode
      await tester.tap(find.text('By Container'));
      await tester.pumpAndSettle();
      expect(find.text('Unassigned (Loose / Inbox)'), findsOneWidget);
      expect(find.text('SMD Binder #1'), findsOneWidget);

      // Open Manage Containers sheet, create a new container, and delete SMD Binder #1
      await tester.tap(find.byTooltip('Manage Containers'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_container_name_input')),
        'IC Drawer Cabinet',
      );
      await tester.tap(find.byKey(const Key('add_container_button')));
      await tester.pumpAndSettle();

      expect((await persistence.load()).containers, hasLength(2));

      // Delete SMD Binder #1 and confirm cascading unassignment
      await tester.tap(
        find.byKey(const Key('delete_container_c-binder-1')),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1 part currently stored'), findsOneWidget);
      await tester.tap(find.text('Delete & Unassign'));
      await tester.pumpAndSettle();

      final afterDelete = await persistence.load();
      expect(
        afterDelete.containers.map((c) => c.name).toList(),
        ['IC Drawer Cabinet'],
      );
      expect(
        afterDelete.parts.firstWhere((p) => p.id == 'p-r4k7').containerId,
        isNull,
      );
    },
  );

  testWidgets(
    'Backup & Import menu exports backup file, shows non-destructive error dialog on invalid JSON, and confirms & replaces catalog on valid JSON import',
    (WidgetTester tester) async {
      String? pickedRawJson;
      String? sharedFilePath;
      final persistence = InMemoryCatalogPersistence(
        buildSampleSnapshot(),
        () async => pickedRawJson,
        (path) async {
          sharedFilePath = path;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogPersistenceProvider.overrideWithValue(persistence),
          ],
          child: const PartsTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Export Backup triggers writeExportFile and share handler
      await tester.tap(find.byTooltip('Backup & Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export Backup'));
      await tester.pumpAndSettle();
      expect(sharedFilePath, contains('parts-catalog-2026-11-03.json'));

      // 2. Import Backup with invalid JSON shows non-destructive error dialog
      pickedRawJson = '{"schemaVersion": 99}';
      await tester.tap(find.byTooltip('Backup & Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Import Failed'), findsOneWidget);
      expect(find.textContaining('schemaVersion'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Existing catalog is untouched
      expect((await persistence.load()).parts, hasLength(2));

      // 3. Import Backup with valid JSON shows confirmation dialog comparing counts and timestamps
      pickedRawJson = '''
      {
        "schemaVersion": 1,
        "updatedAt": "2026-11-03T05:00:00.000Z",
        "containers": [
          {"id": "c-new", "name": "Imported Cabinet"}
        ],
        "parts": [
          {
            "id": "p-imported",
            "name": "NE555P Timer IC",
            "quantity": 42,
            "lcscCode": "C7593",
            "containerId": "c-new",
            "slot": "Drawer 1"
          }
        ]
      }
      ''';
      await tester.tap(find.byTooltip('Backup & Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Replace Catalog with Backup?'), findsOneWidget);
      expect(find.textContaining('2 parts'), findsOneWidget);
      expect(find.textContaining('Incoming backup: 1 part'), findsOneWidget);

      await tester.tap(find.text('Replace Catalog'));
      await tester.pumpAndSettle();

      // Pre-import safety backup was written and live catalog was replaced
      expect(persistence.lastPreImportBackup?.parts, hasLength(2));
      expect(find.text('NE555P Timer IC'), findsOneWidget);
      expect(find.text('4.7kΩ 0603 1% SMD Resistor'), findsNothing);
    },
  );
}
