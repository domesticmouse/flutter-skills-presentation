import 'package:flutter/material.dart';

import '../../../../domain/models/electronic_part.dart';
import '../view_models/inventory_view_model.dart';
import 'import_export_sheet.dart';
import 'locations_view.dart';
import 'part_form_sheet.dart';
import 'parts_list_view.dart';
import 'restock_view.dart';

/// Top-level home screen with bottom navigation for Parts, Storage Locations,
/// and Restock Alerts.
class InventoryHomeScreen extends StatefulWidget {
  const InventoryHomeScreen({
    super.key,
    required this.viewModel,
  });

  final InventoryViewModel viewModel;

  @override
  State<InventoryHomeScreen> createState() => _InventoryHomeScreenState();
}

class _InventoryHomeScreenState extends State<InventoryHomeScreen> {
  int _selectedTabIndex = 0;

  Future<void> _openAddPartSheet() async {
    final created = await Navigator.of(context).push<ElectronicPart>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PartFormSheet(
          existingLocations: widget.viewModel.distinctLocationNames,
          presetLocation: widget.viewModel.selectedLocation == 'Unassigned'
              ? null
              : widget.viewModel.selectedLocation,
        ),
      ),
    );
    if (created != null) {
      await widget.viewModel.savePart(created);
    }
  }

  void _openImportExportSheet() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ImportExportSheet(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final titles = const [
          'Electronics Inventory',
          'Storage Locations',
          'Restock List',
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              titles[_selectedTabIndex],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              if (_selectedTabIndex == 0)
                PopupMenuButton<PartSortOrder>(
                  key: const Key('sort_menu_button'),
                  tooltip: 'Sort Parts',
                  icon: const Icon(Icons.sort),
                  initialValue: vm.sortOrder,
                  onSelected: vm.setSortOrder,
                  itemBuilder: (context) => PartSortOrder.values.map((order) {
                    return PopupMenuItem<PartSortOrder>(
                      value: order,
                      child: Row(
                        children: [
                          Icon(
                            vm.sortOrder == order
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(order.label),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              IconButton(
                key: const Key('import_export_button'),
                tooltip: 'Export / Import (JSON & CSV)',
                icon: const Icon(Icons.import_export),
                onPressed: _openImportExportSheet,
              ),
              IconButton(
                key: const Key('theme_toggle_button'),
                tooltip: 'Switch Theme Mode',
                icon: Icon(
                  switch (vm.themeMode) {
                    ThemeMode.system => Icons.brightness_auto_outlined,
                    ThemeMode.dark => Icons.dark_mode_outlined,
                    ThemeMode.light => Icons.light_mode_outlined,
                  },
                ),
                onPressed: vm.toggleThemeMode,
              ),
            ],
          ),
          body: Column(
            children: [
              if (vm.errorMessage != null)
                MaterialBanner(
                  key: const Key('inventory_error_banner'),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  leading: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  content: Text(
                    vm.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: vm.clearError,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
                        index: _selectedTabIndex,
                        children: [
                          PartsListView(viewModel: vm),
                          LocationsView(
                            viewModel: vm,
                            onJumpToPartsTabWithLocation: (locationName) {
                              vm.setSelectedLocation(locationName);
                              setState(() => _selectedTabIndex = 0);
                            },
                          ),
                          RestockView(viewModel: vm),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('add_part_fab'),
            onPressed: _openAddPartSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add Part'),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedTabIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedTabIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.memory_outlined),
                selectedIcon: Icon(Icons.memory),
                label: 'Parts',
              ),
              const NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Locations',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: vm.restockCount > 0,
                  label: Text('${vm.restockCount}'),
                  child: const Icon(Icons.shopping_cart_checkout_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: vm.restockCount > 0,
                  label: Text('${vm.restockCount}'),
                  child: const Icon(Icons.shopping_cart_checkout),
                ),
                label: 'Restock',
              ),
            ],
          ),
        );
      },
    );
  }
}
