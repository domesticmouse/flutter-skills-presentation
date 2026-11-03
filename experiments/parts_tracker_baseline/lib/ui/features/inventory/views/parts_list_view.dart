import 'package:flutter/material.dart';

import '../../../../domain/models/electronic_part.dart';
import '../../../../domain/models/part_category.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/inventory_view_model.dart';
import 'part_detail_screen.dart';

/// Main inventory view displaying summary metrics, search/filter controls,
/// and the list of electronic parts with quick stock adjustment buttons.
class PartsListView extends StatefulWidget {
  const PartsListView({
    super.key,
    required this.viewModel,
  });

  final InventoryViewModel viewModel;

  @override
  State<PartsListView> createState() => _PartsListViewState();
}

class _PartsListViewState extends State<PartsListView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.viewModel.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    if (_searchController.text != vm.searchQuery) {
      _searchController.value = TextEditingValue(
        text: vm.searchQuery,
        selection: TextSelection.collapsed(offset: vm.searchQuery.length),
      );
    }

    final parts = vm.filteredParts;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Dashboard Summary Metrics
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Parts',
                  value: '${vm.totalDistinctParts}',
                  icon: Icons.memory,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Total Units',
                  value: '${vm.totalUnitsCount}',
                  icon: Icons.layers_outlined,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final next = vm.stockFilter == StockFilter.needsRestock
                        ? StockFilter.all
                        : StockFilter.needsRestock;
                    vm.setStockFilter(next);
                  },
                  child: _MetricTile(
                    label: 'Restock',
                    value: '${vm.restockCount}',
                    icon: Icons.warning_amber_rounded,
                    color: vm.restockCount > 0
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                    isHighlighted: vm.stockFilter == StockFilter.needsRestock,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Est. Value',
                  value: '\$${vm.totalInventoryValue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),

        // Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            key: const Key('parts_search_field'),
            controller: _searchController,
            onChanged: vm.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search part name, value, package, MPN, bin...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: vm.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        vm.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Category Filter Bar
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              FilterChip(
                label: const Text('All Categories'),
                selected: vm.selectedCategory == null,
                onSelected: (_) => vm.setSelectedCategory(null),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              ...PartCategory.values.map((category) {
                final isSelected = vm.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : category.color,
                    ),
                    label: Text(category.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      vm.setSelectedCategory(selected ? category : null);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
            ],
          ),
        ),

        // Active Filter Banner (Location or Stock Filter)
        if (vm.selectedLocation != null ||
            vm.stockFilter != StockFilter.all) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                if (vm.selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      avatar: const Icon(Icons.place, size: 16),
                      label: Text('Bin: ${vm.selectedLocation}'),
                      onDeleted: () => vm.setSelectedLocation(null),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (vm.stockFilter != StockFilter.all)
                  InputChip(
                    avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: Text(vm.stockFilter.label),
                    onDeleted: () => vm.setStockFilter(StockFilter.all),
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),
                TextButton(
                  onPressed: vm.clearFilters,
                  child: const Text('Reset All'),
                ),
              ],
            ),
          ),
        ],

        // Parts List
        Expanded(
          child: parts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          vm.hasActiveFilters
                              ? 'No parts match your active filters'
                              : 'Your parts inventory is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (vm.hasActiveFilters) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: vm.clearFilters,
                            icon: const Icon(Icons.filter_alt_off, size: 18),
                            label: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: parts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final part = parts[index];
                    return _PartListItemCard(
                      part: part,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PartDetailScreen(
                              partId: part.id,
                              viewModel: vm,
                            ),
                          ),
                        );
                      },
                      onDecrement: part.quantity > 0
                          ? () => vm.adjustQuantity(part.id, -1)
                          : null,
                      onIncrement: () => vm.adjustQuantity(part.id, 1),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.16)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? color
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PartListItemCard extends StatelessWidget {
  const _PartListItemCard({
    required this.part,
    required this.onTap,
    required this.onDecrement,
    required this.onIncrement,
  });

  final ElectronicPart part;
  final VoidCallback onTap;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color stockColor;
    if (part.isOutOfStock) {
      stockColor = colorScheme.error;
    } else if (part.isLowStock) {
      stockColor = const Color(0xFFD97706);
    } else {
      stockColor = const Color(0xFF059669);
    }

    return Card(
      key: Key('part_card_${part.id}'),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: part.category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  part.category.icon,
                  color: part.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Part Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (part.package.isNotEmpty) part.package,
                        if (part.valueOrSpecs.isNotEmpty) part.valueOrSpecs,
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (part.storageLocation.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 13,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                part.storageLocation,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (part.supplierName.isNotEmpty)
                          Text(
                            part.supplierName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Stock Counter & Quick +/- Controls
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${part.quantity} pcs',
                      key: Key('part_qty_${part.id}'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton.outlined(
                          key: Key('dec_btn_${part.id}'),
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(Icons.remove),
                          onPressed: onDecrement,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton.filledTonal(
                          key: Key('inc_btn_${part.id}'),
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(Icons.add),
                          onPressed: onIncrement,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
