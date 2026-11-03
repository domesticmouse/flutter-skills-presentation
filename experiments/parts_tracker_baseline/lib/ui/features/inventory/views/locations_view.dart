import 'package:flutter/material.dart';

import '../../../../domain/models/electronic_part.dart';
import '../../../../domain/models/storage_location_summary.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/inventory_view_model.dart';
import 'part_detail_screen.dart';
import 'part_form_sheet.dart';

/// Displays parts grouped by storage location (bins, drawers, organizers).
class LocationsView extends StatelessWidget {
  const LocationsView({
    super.key,
    required this.viewModel,
    required this.onJumpToPartsTabWithLocation,
  });

  final InventoryViewModel viewModel;
  final ValueChanged<String> onJumpToPartsTabWithLocation;

  Future<void> _showRenameLocationDialog(
    BuildContext context,
    String currentLocation,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameLocationDialog(currentLocation: currentLocation),
    );

    if (newName != null) {
      await viewModel.renameLocation(
        oldLocation: currentLocation == 'Unassigned' ? '' : currentLocation,
        newLocation: newName,
      );
    }
  }

  Future<void> _addPartToLocation(
    BuildContext context,
    String locationName,
  ) async {
    final created = await Navigator.of(context).push<ElectronicPart>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PartFormSheet(
          existingLocations: viewModel.distinctLocationNames,
          presetLocation: locationName == 'Unassigned' ? '' : locationName,
        ),
      ),
    );
    if (created != null) {
      await viewModel.savePart(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaries = viewModel.locationSummaries;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (summaries.isEmpty) {
      return const Center(
        child: Text('No storage locations yet. Add a part to get started!'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: summaries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return _LocationCard(
          summary: summary,
          colorScheme: colorScheme,
          onFilterInPartsTab: () =>
              onJumpToPartsTabWithLocation(summary.locationName),
          onRename: () =>
              _showRenameLocationDialog(context, summary.locationName),
          onAddPartHere: () =>
              _addPartToLocation(context, summary.locationName),
          onOpenPart: (part) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PartDetailScreen(
                  partId: part.id,
                  viewModel: viewModel,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.summary,
    required this.colorScheme,
    required this.onFilterInPartsTab,
    required this.onRename,
    required this.onAddPartHere,
    required this.onOpenPart,
  });

  final StorageLocationSummary summary;
  final ColorScheme colorScheme;
  final VoidCallback onFilterInPartsTab;
  final VoidCallback onRename;
  final VoidCallback onAddPartHere;
  final ValueChanged<ElectronicPart> onOpenPart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnassigned = summary.locationName == 'Unassigned';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnassigned
                ? colorScheme.surfaceContainerHighest
                : colorScheme.primaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isUnassigned ? Icons.help_outline : Icons.inventory_2_outlined,
            color: isUnassigned
                ? colorScheme.onSurfaceVariant
                : colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          summary.locationName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${summary.partTypesCount} ${summary.partTypesCount == 1 ? 'part' : 'parts'} • ${summary.totalUnitsCount} pcs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (summary.lowStockCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${summary.lowStockCount} low/out',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onFilterInPartsTab,
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('Filter in Parts'),
                ),
                TextButton.icon(
                  onPressed: onRename,
                  icon: const Icon(Icons.drive_file_rename_outline, size: 16),
                  label: Text(isUnassigned ? 'Assign Bin' : 'Rename'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Add part to this location',
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: onAddPartHere,
                ),
              ],
            ),
          ),
          ...summary.parts.map((part) {
            return ListTile(
              dense: true,
              leading: Icon(
                part.category.icon,
                color: part.category.color,
                size: 20,
              ),
              title: Text(
                part.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [
                  if (part.package.isNotEmpty) part.package,
                  if (part.valueOrSpecs.isNotEmpty) part.valueOrSpecs,
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${part.quantity} pcs',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: part.isOutOfStock
                      ? colorScheme.error
                      : part.isLowStock
                          ? const Color(0xFFD97706)
                          : colorScheme.onSurface,
                ),
              ),
              onTap: () => onOpenPart(part),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _RenameLocationDialog extends StatefulWidget {
  const _RenameLocationDialog({required this.currentLocation});

  final String currentLocation;

  @override
  State<_RenameLocationDialog> createState() => _RenameLocationDialogState();
}

class _RenameLocationDialogState extends State<_RenameLocationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialText = widget.currentLocation == 'Unassigned'
        ? ''
        : widget.currentLocation;
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnassigned = widget.currentLocation == 'Unassigned';
    return AlertDialog(
      title: Text(
        isUnassigned ? 'Assign Storage Location' : 'Rename Storage Location',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Location Name',
          hintText: 'e.g. Cabinet A - Drawer 3',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
