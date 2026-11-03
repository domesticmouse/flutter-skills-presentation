import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../view_models/inventory_view_model.dart';
import 'part_detail_screen.dart';

/// Displays all parts that are out of stock or at/below their low-stock
/// threshold, with quick supplier SKU copying and restock controls.
class RestockView extends StatelessWidget {
  const RestockView({
    super.key,
    required this.viewModel,
  });

  final InventoryViewModel viewModel;

  Future<void> _copyPartNumber(BuildContext context, String partNumber) async {
    await Clipboard.setData(ClipboardData(text: partNumber));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$partNumber" to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restockList = viewModel.restockParts;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (restockList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 12),
              Text(
                'All Parts Well Stocked!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Every component in your inventory is above its low-stock threshold.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: restockList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final part = restockList[index];
        final isOut = part.isOutOfStock;
        final badgeColor = isOut ? colorScheme.error : const Color(0xFFD97706);

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PartDetailScreen(
                    partId: part.id,
                    viewModel: viewModel,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOut ? 'OUT OF STOCK' : 'LOW STOCK',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          part.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${part.quantity} / ${part.minStockThreshold} min',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (part.supplierName.isNotEmpty ||
                      part.supplierPartNumber.isNotEmpty ||
                      part.manufacturerPartNumber.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (part.supplierName.isNotEmpty)
                          Chip(
                            avatar: const Icon(
                              Icons.storefront_outlined,
                              size: 14,
                            ),
                            label: Text(part.supplierName),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (part.supplierPartNumber.isNotEmpty)
                          ActionChip(
                            avatar: const Icon(Icons.copy, size: 14),
                            label: Text('SKU: ${part.supplierPartNumber}'),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _copyPartNumber(
                              context,
                              part.supplierPartNumber,
                            ),
                          ),
                        if (part.supplierPartNumber.isEmpty &&
                            part.manufacturerPartNumber.isNotEmpty)
                          ActionChip(
                            avatar: const Icon(Icons.copy, size: 14),
                            label: Text('MPN: ${part.manufacturerPartNumber}'),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _copyPartNumber(
                              context,
                              part.manufacturerPartNumber,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (part.storageLocation.isNotEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  part.storageLocation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () => viewModel.adjustQuantity(part.id, 10),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Restock +10'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
