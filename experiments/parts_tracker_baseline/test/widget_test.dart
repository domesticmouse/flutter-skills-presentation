import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_baseline/data/repositories/parts_repository.dart';
import 'package:parts_tracker_baseline/data/services/local_storage_service.dart';
import 'package:parts_tracker_baseline/main.dart';
import 'package:parts_tracker_baseline/ui/features/inventory/view_models/inventory_view_model.dart';

void main() {
  testWidgets('PartsTrackerApp renders inventory, searches, and adds a part', (
    WidgetTester tester,
  ) async {
    final repository = PartsRepository(
      storageService: InMemoryLocalStorageService(),
      seedSampleDataWhenEmpty: true,
    );
    final viewModel = InventoryViewModel(repository: repository);
    await viewModel.loadInventory();

    await tester.pumpWidget(PartsTrackerApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Verify main inventory header and starter parts are displayed.
    expect(find.text('Electronics Inventory'), findsOneWidget);
    expect(find.text('0.96" I2C OLED Display (SSD1306)'), findsOneWidget);

    // Increment quantity of top item: 0.96" I2C OLED Display (0 -> 1)
    await tester.tap(find.byKey(const Key('inc_btn_part-disp-ssd1306')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('part_card_part-disp-ssd1306')),
        matching: find.text('1 pcs'),
      ),
      findsOneWidget,
    );

    // Search for ESP32
    await tester.enterText(
      find.byKey(const Key('parts_search_field')),
      'ESP32',
    );
    await tester.pump();
    expect(find.text('ESP32-WROOM-32E Module'), findsOneWidget);
    expect(find.text('10kΩ SMD Resistor'), findsNothing);

    // Clear search
    viewModel.setSearchQuery('');
    await tester.pump();

    // Open Add Part sheet and create a new part
    await tester.tap(find.byKey(const Key('add_part_fab')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('part_name_field')),
      'ATmega328P-PU',
    );
    await tester.enterText(
      find.byKey(const Key('part_package_field')),
      'DIP-28',
    );
    await tester.enterText(
      find.byKey(const Key('part_quantity_field')),
      '15',
    );
    await tester.tap(find.byKey(const Key('save_part_button')));
    await tester.pumpAndSettle();

    // Search for the newly added part to bring it into the viewport
    await tester.enterText(
      find.byKey(const Key('parts_search_field')),
      'ATmega328',
    );
    await tester.pump();
    expect(find.text('ATmega328P-PU'), findsOneWidget);

    // Switch to Locations tab
    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();
    expect(find.text('Storage Locations'), findsOneWidget);
    expect(find.text('Cabinet A - Drawer 2'), findsOneWidget);

    // Switch to Restock tab
    await tester.tap(find.text('Restock'));
    await tester.pumpAndSettle();
    expect(find.text('Restock List'), findsOneWidget);
    expect(find.text('0.96" I2C OLED Display (SSD1306)'), findsOneWidget);
  });
}
