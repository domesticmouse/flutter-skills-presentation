import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/electronic_part.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/inventory_view_model.dart';
import 'part_form_sheet.dart';

/// Detailed view of a single [ElectronicPart] with live stock controls
/// and supplier/datasheet reference actions.
class PartDetailScreen extends StatelessWidget {
  const PartDetailScreen({
    super.key,
    required this.partId,
    required this.viewModel,
  });

  final String partId;
  final InventoryViewModel viewModel;

  Future<void> _copyToClipboard(
    BuildContext context,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSetQuantityDialog(
    BuildContext context,
    ElectronicPart part,
  ) async {
    final nextQty = await showDialog<int>(
      context: context,
      builder: (_) => _SetQuantityDialog(initialQuantity: part.quantity),
    );

    if (nextQty != null) {
      await viewModel.setExactQuantity(part.id, nextQty);
    }
  }

  Future<void> _handleEdit(BuildContext context, ElectronicPart part) async {
    final updated = await Navigator.of(context).push<ElectronicPart>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PartFormSheet(
          initialPart: part,
          existingLocations: viewModel.distinctLocationNames,
        ),
      ),
    );

    if (updated != null) {
      await viewModel.savePart(updated);
    }
  }

  Future<void> _handleDelete(BuildContext context, ElectronicPart part) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Part?'),
          content: Text(
            'Are you sure you want to remove "${part.name}" from your inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await viewModel.deletePart(part.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final part = viewModel.getPartById(partId);
        if (part == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Part Not Found')),
            body: const Center(
              child: Text('This part is no longer in the inventory.'),
            ),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final Color statusColor;
        final String statusLabel;
        if (part.isOutOfStock) {
          statusColor = colorScheme.error;
          statusLabel = 'Out of Stock';
        } else if (part.isLowStock) {
          statusColor = const Color(0xFFD97706);
          statusLabel = 'Low Stock (Min: ${part.minStockThreshold})';
        } else {
          statusColor = const Color(0xFF059669);
          statusLabel = 'In Stock (Min: ${part.minStockThreshold})';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              part.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                key: const Key('edit_part_button'),
                tooltip: 'Edit Part',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _handleEdit(context, part),
              ),
              IconButton(
                key: const Key('delete_part_button'),
                tooltip: 'Delete Part',
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () => _handleDelete(context, part),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // Header & Stock Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: part.category.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              part.category.icon,
                              color: part.category.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  part.category.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: part.category.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  part.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CURRENT STOCK',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        letterSpacing: 0.8,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () =>
                                          _showSetQuantityDialog(context, part),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${part.quantity}',
                                            key: const Key(
                                              'detail_quantity_text',
                                            ),
                                            style: theme
                                                .textTheme.headlineMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: statusColor,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'pcs',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: part.quantity > 0
                                        ? () => viewModel.adjustQuantity(
                                              part.id,
                                              -10,
                                            )
                                        : null,
                                    child: const Text('-10'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    key: const Key('detail_decrement_button'),
                                    onPressed: part.quantity > 0
                                        ? () => viewModel.adjustQuantity(
                                              part.id,
                                              -1,
                                            )
                                        : null,
                                    child: const Text('-1'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.tonal(
                                    key: const Key('detail_increment_button'),
                                    onPressed: () =>
                                        viewModel.adjustQuantity(part.id, 1),
                                    child: const Text('+1'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () =>
                                        viewModel.adjustQuantity(part.id, 10),
                                    child: const Text('+10'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Specifications & Location Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specifications & Storage',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.tune,
                        label: 'Value / Specs',
                        value: part.valueOrSpecs.isEmpty
                            ? 'Not specified'
                            : part.valueOrSpecs,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.straighten,
                        label: 'Package / Footprint',
                        value: part.package.isEmpty
                            ? 'Not specified'
                            : part.package,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: 'Storage Location',
                        value: part.storageLocation.isEmpty
                            ? 'Unassigned'
                            : part.storageLocation,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Supplier & Part Numbers Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier & Ordering Info',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: 'Supplier',
                        value: part.supplierName.isEmpty
                            ? 'Not specified'
                            : part.supplierName,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.tag,
                        label: 'Supplier Part #',
                        value: part.supplierPartNumber.isEmpty
                            ? 'Not specified'
                            : part.supplierPartNumber,
                        onCopy: part.supplierPartNumber.isNotEmpty
                            ? () => _copyToClipboard(
                                  context,
                                  'Supplier Part #',
                                  part.supplierPartNumber,
                                )
                            : null,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.precision_manufacturing_outlined,
                        label: 'Manufacturer Part # (MPN)',
                        value: part.manufacturerPartNumber.isEmpty
                            ? 'Not specified'
                            : part.manufacturerPartNumber,
                        onCopy: part.manufacturerPartNumber.isNotEmpty
                            ? () => _copyToClipboard(
                                  context,
                                  'MPN',
                                  part.manufacturerPartNumber,
                                )
                            : null,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Unit Price / Total Value',
                        value: part.unitPrice > 0
                            ? '\$${part.formattedUnitPrice} each  •  \$${part.totalValue.toStringAsFixed(2)} total'
                            : 'Not specified',
                      ),
                      if (part.datasheetUrl.isNotEmpty) ...[
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.description_outlined,
                          label: 'Datasheet URL',
                          value: part.datasheetUrl,
                          onCopy: () => _copyToClipboard(
                            context,
                            'Datasheet URL',
                            part.datasheetUrl,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (part.notes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pinout & Workbench Notes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          part.notes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            tooltip: 'Copy $label',
            icon: const Icon(Icons.copy, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: onCopy,
          ),
      ],
    );
  }
}

class _SetQuantityDialog extends StatefulWidget {
  const _SetQuantityDialog({required this.initialQuantity});

  final int initialQuantity;

  @override
  State<_SetQuantityDialog> createState() => _SetQuantityDialogState();
}

class _SetQuantityDialogState extends State<_SetQuantityDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Exact Stock Count'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Quantity',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final parsed = int.tryParse(_controller.text.trim());
            Navigator.of(context).pop(parsed);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
