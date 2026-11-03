import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/catalog_models.dart' as models;
import '../catalog/catalog_models.dart' show CatalogSnapshot, Part;
import '../catalog/catalog_provider.dart';
import '../search/workbench_filter_provider.dart';
import 'add_or_edit_part_sheet.dart';
import 'manage_containers_sheet.dart';
import 'part_detail_sheet.dart';
import 'workbench_widgets.dart';

class WorkbenchScreen extends ConsumerStatefulWidget {
  const WorkbenchScreen({super.key});

  @override
  ConsumerState<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class _WorkbenchScreenState extends ConsumerState<WorkbenchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _expandedPartId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleExportBackup() async {
    try {
      await ref.read(catalogProvider.notifier).shareBackupFile();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _handleImportBackup() async {
    String? rawJson;
    try {
      rawJson = await ref.read(catalogPersistenceProvider).pickImportJson();
    } on Object catch (e) {
      if (!mounted) return;
      await _showImportErrorDialog('Could not read selected file: $e');
      return;
    }

    if (rawJson == null || !mounted) return;

    final CatalogSnapshot validated;
    try {
      validated = Catalog.validateCatalogJson(rawJson);
    } on CatalogImportValidationException catch (e) {
      if (!mounted) return;
      await _showImportErrorDialog(e.message);
      return;
    } on Object catch (e) {
      if (!mounted) return;
      await _showImportErrorDialog('$e');
      return;
    }

    final current =
        ref.read(catalogProvider).value ?? CatalogSnapshot.empty();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Replace Catalog with Backup?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A safety copy (parts_catalog.backup.json) will be saved before replacing your catalog.',
              ),
              const SizedBox(height: 12),
              Text(
                'Current catalog: ${pluralizeCount(current.parts.length, 'part')}, '
                '${pluralizeCount(current.containers.length, 'container')} '
                '(updated ${_formatTimestamp(current.updatedAt)})',
              ),
              const SizedBox(height: 6),
              Text(
                'Incoming backup: ${pluralizeCount(validated.parts.length, 'part')}, '
                '${pluralizeCount(validated.containers.length, 'container')} '
                '(updated ${_formatTimestamp(validated.updatedAt)})',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Replace Catalog'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await ref.read(catalogProvider.notifier).importSnapshot(validated);
    }
  }

  Future<void> _showImportErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Failed'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final iso = dt.toUtc().toIso8601String();
    return iso.length >= 16 ? '${iso.substring(0, 16)}Z' : iso;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final view = ref.watch(filteredWorkbenchViewProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedFacet = ref.watch(selectedFacetProvider);
    final groupByContainer = ref.watch(groupByContainerProvider);

    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E1318),
      body: SafeArea(
        child: Column(
          children: [
            _buildCommandHeader(
              context,
              cs: cs,
              view: view,
              query: query,
              selectedFacet: selectedFacet,
              groupByContainer: groupByContainer,
            ),
            Expanded(
              child: groupByContainer
                  ? _buildGroupedByContainerList(context, cs, view)
                  : _buildFlatPartList(context, cs, view),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandHeader(
    BuildContext context, {
    required ColorScheme cs,
    required FilteredWorkbenchView view,
    required String query,
    required WorkbenchFacet selectedFacet,
    required bool groupByContainer,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161D24),
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('workbench_search_input'),
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).setQuery(value);
                  },
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '⌘ Find: "4k7 0603", "0.1uF 50V", "C14663"…',
                    prefixIcon: Icon(
                      Icons.terminal,
                      color: cs.primary,
                      size: 20,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            key: const Key('clear_search_button'),
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(searchQueryProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF0E1318),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: 'Manage Containers',
                onPressed: () => _openManageContainersSheet(context),
                icon: const Icon(Icons.dns_outlined, size: 18),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'Backup & Import',
                icon: const Icon(Icons.import_export, size: 20),
                onSelected: (action) {
                  if (action == 'export') {
                    _handleExportBackup();
                  } else if (action == 'import') {
                    _handleImportBackup();
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem<String>(
                    value: 'export',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.ios_share_outlined, size: 18),
                      title: Text('Export Backup'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'import',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.file_open_outlined, size: 18),
                      title: Text('Import Backup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () => _openAddOrEditPartSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  avatar: const Icon(Icons.folder_copy_outlined, size: 14),
                  label: const Text(
                    'By Container',
                    style: TextStyle(fontSize: 11),
                  ),
                  selected: groupByContainer,
                  onSelected: (val) {
                    ref
                        .read(groupByContainerProvider.notifier)
                        .setGrouped(val);
                  },
                  visualDensity: VisualDensity.compact,
                ),
                const VerticalDivider(width: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      'All (${view.totalCount})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: selectedFacet is WorkbenchFacetAll,
                    onSelected: (_) {
                      ref
                          .read(selectedFacetProvider.notifier)
                          .setFacet(const WorkbenchFacet.all());
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      'Low Stock (${view.lowStockCount})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: selectedFacet is WorkbenchFacetLowStock,
                    onSelected: (_) {
                      ref
                          .read(selectedFacetProvider.notifier)
                          .setFacet(const WorkbenchFacet.lowStock());
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      'Unassigned (${view.unassignedCount})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: selectedFacet is WorkbenchFacetUnassigned,
                    onSelected: (_) {
                      ref
                          .read(selectedFacetProvider.notifier)
                          .setFacet(const WorkbenchFacet.unassigned());
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                for (final category in view.availableCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: selectedFacet is WorkbenchFacetCategory &&
                          selectedFacet.category.toLowerCase() ==
                              category.toLowerCase(),
                      onSelected: (_) {
                        ref
                            .read(selectedFacetProvider.notifier)
                            .setFacet(WorkbenchFacet.category(category));
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatPartList(
    BuildContext context,
    ColorScheme cs,
    FilteredWorkbenchView view,
  ) {
    if (view.flatParts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            view.totalCount == 0
                ? 'Your workbench catalog is empty. Tap + New to add your first Part.'
                : 'No matching Parts found.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
      itemCount: view.flatParts.length,
      itemBuilder: (ctx, i) => _buildPartAccordionCard(
        ctx,
        cs: cs,
        part: view.flatParts[i],
        containerMap: view.containerMap,
      ),
    );
  }

  Widget _buildGroupedByContainerList(
    BuildContext context,
    ColorScheme cs,
    FilteredWorkbenchView view,
  ) {
    if (view.containerGroups.isEmpty) {
      return Center(
        child: Text(
          'No matching Containers or Parts.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
      children: [
        for (final group in view.containerGroups) ...[
          _buildContainerSectionHeader(
            context,
            cs: cs,
            group: group,
          ),
          if (group.parts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 24),
              child: Text(
                'Empty container',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final part in group.parts)
              _buildPartAccordionCard(
                context,
                cs: cs,
                part: part,
                containerMap: view.containerMap,
              ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildContainerSectionHeader(
    BuildContext context, {
    required ColorScheme cs,
    required ContainerPartGroup group,
  }) {
    final container = group.container;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Icon(
            container == null ? Icons.inbox_outlined : Icons.dns_outlined,
            size: 16,
            color: cs.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  group.subtitle ?? pluralizeCount(group.parts.length, 'part'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (container != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => _openAddOrEditPartSheet(
                context,
                initialContainerId: container.id,
              ),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('+ Add Slot', style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildPartAccordionCard(
    BuildContext context, {
    required ColorScheme cs,
    required Part part,
    required Map<String, models.Container> containerMap,
  }) {
    final isExpanded = _expandedPartId == part.id;
    return Card(
      key: Key('part_card_${part.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      color: isExpanded ? const Color(0xFF1C2631) : const Color(0xFF141B22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isExpanded
              ? const Color(0xFF00E5FF)
              : cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _expandedPartId = isExpanded ? null : part.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    key: Key('qty_badge_${part.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: part.isLowStock
                          ? cs.errorContainer
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${part.quantity}',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        color: part.isLowStock
                            ? cs.onErrorContainer
                            : cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          part.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatPartLocation(part, containerMap)}  •  ${part.package ?? "-"}  •  ${part.lcscCode ?? "No LCSC"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Courier',
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const Divider(height: 18),
                if (part.specs.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final e in part.specs.entries)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E1318),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    QuantityQuickStepperButtons(
                      compact: true,
                      onAdjust: (delta) {
                        ref
                            .read(catalogProvider.notifier)
                            .adjustQuantity(part.id, delta);
                      },
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _openPartDetailSheet(context, part.id),
                      icon: const Icon(Icons.open_in_full, size: 14),
                      label: const Text(
                        'Details & Edit',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPartDetailSheet(
    BuildContext context,
    String partId,
  ) async {
    await showPartDetailSheet(
      context,
      ref: ref,
      partId: partId,
      onEditPart: (part) => _openAddOrEditPartSheet(
        context,
        existingPart: part,
      ),
    );
  }

  Future<void> _openAddOrEditPartSheet(
    BuildContext context, {
    Part? existingPart,
    String? initialContainerId,
  }) async {
    final jumpedToPartId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => AddOrEditPartSheet(
        existingPart: existingPart,
        initialContainerId: initialContainerId,
      ),
    );

    if (jumpedToPartId != null && context.mounted) {
      setState(() {
        _expandedPartId = jumpedToPartId;
      });
      await _openPartDetailSheet(context, jumpedToPartId);
    }
  }

  Future<void> _openManageContainersSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => const ManageContainersSheet(),
    );
  }
}
