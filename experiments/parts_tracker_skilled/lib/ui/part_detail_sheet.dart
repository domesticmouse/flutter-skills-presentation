import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../catalog/catalog_models.dart' show CatalogSnapshot, Part;
import '../catalog/catalog_provider.dart';
import 'workbench_widgets.dart';

Future<void> showPartDetailSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String partId,
  required ValueChanged<Part> onEditPart,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return Consumer(
        builder: (ctx, sheetRef, _) {
          final snapshot =
              sheetRef.watch(catalogProvider).value ?? CatalogSnapshot.empty();
          final part =
              snapshot.parts.where((p) => p.id == partId).firstOrNull;
          if (part == null) {
            return const SizedBox.shrink();
          }
          final containerMap = {
            for (final c in snapshot.containers) c.id: c,
          };
          final container =
              part.containerId == null ? null : containerMap[part.containerId!];
          final cs = Theme.of(ctx).colorScheme;

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.78,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, scrollController) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (part.lcscCode != null)
                                  BadgePill(
                                    text: part.lcscCode!,
                                    color: cs.primaryContainer,
                                    textColor: cs.onPrimaryContainer,
                                    monospace: true,
                                  ),
                                if (part.package != null)
                                  BadgePill(
                                    text: part.package!,
                                    color: cs.secondaryContainer,
                                    textColor: cs.onSecondaryContainer,
                                    monospace: true,
                                  ),
                                if (part.category != null)
                                  BadgePill(
                                    text: part.category!,
                                    color: cs.surfaceContainerHighest,
                                    textColor: cs.onSurfaceVariant,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              part.name,
                              style: Theme.of(ctx)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (part.mpn != null ||
                                part.manufacturer != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (part.mpn != null) 'MPN: ${part.mpn}',
                                  if (part.manufacturer != null)
                                    part.manufacturer!,
                                ].join('  •  '),
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Edit Part',
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onEditPart(part);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        tooltip: 'Delete Part',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: ctx,
                            builder: (dCtx) => AlertDialog(
                              title: const Text('Delete Part?'),
                              content: Text(
                                'Delete "${part.name}" from your catalog?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dCtx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dCtx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && ctx.mounted) {
                            Navigator.of(ctx).pop();
                            await ref
                                .read(catalogProvider.notifier)
                                .deletePart(part.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    color: cs.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                container == null
                                    ? Icons.inbox_outlined
                                    : Icons.inventory_2_outlined,
                                size: 20,
                                color: container == null
                                    ? Colors.amber.shade700
                                    : cs.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  formatPartLocation(part, containerMap),
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Courier',
                                      ),
                                ),
                              ),
                              if (part.isLowStock)
                                BadgePill(
                                  text:
                                      'LOW STOCK (≤${part.lowStockThreshold ?? 0})',
                                  color: cs.errorContainer,
                                  textColor: cs.onErrorContainer,
                                )
                              else if (part.lowStockThreshold != null)
                                BadgePill(
                                  text:
                                      'Low-stock alert ≤${part.lowStockThreshold}',
                                  color: cs.surfaceContainerHighest,
                                  textColor: cs.onSurfaceVariant,
                                  monospace: true,
                                ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'QUANTITY ON HAND',
                                style: Theme.of(ctx).textTheme.labelSmall,
                              ),
                              Text(
                                '${part.quantity}',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Courier',
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              QuantityQuickStepperButtons(
                                onAdjust: (delta) {
                                  ref
                                      .read(catalogProvider.notifier)
                                      .adjustQuantity(part.id, delta);
                                },
                              ),
                              OutlinedButton(
                                onPressed: () =>
                                    _promptSetExactQuantity(ctx, ref, part),
                                child: const Text('Set…'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (part.notes != null && part.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'WORKBENCH NOTES',
                      style: Theme.of(ctx).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(part.notes!),
                  ],
                  if (part.specs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'ELECTRICAL SPECS (${part.specs.length})',
                      style: Theme.of(ctx).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final entry in part.specs.entries)
                            ListTile(
                              dense: true,
                              title: Text(entry.key),
                              trailing: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (part.datasheetUrl != null &&
                      part.datasheetUrl!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(part.datasheetUrl!);
                        if (uri != null) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.inAppBrowserView,
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Open LCSC PDF Datasheet'),
                    ),
                  ],
                ],
              );
            },
          );
        },
      );
    },
  );
}

Future<void> _promptSetExactQuantity(
  BuildContext context,
  WidgetRef ref,
  Part part,
) async {
  final ctrl = TextEditingController(text: '${part.quantity}');
  final newQty = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Set Exact Quantity'),
      content: TextField(
        key: const Key('set_exact_quantity_input'),
        controller: ctrl,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Quantity on hand',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final parsed = int.tryParse(ctrl.text.trim());
            if (parsed != null) {
              Navigator.of(ctx).pop(parsed);
            }
          },
          child: const Text('Apply'),
        ),
      ],
    ),
  );
  if (newQty != null) {
    await ref.read(catalogProvider.notifier).setQuantity(part.id, newQty);
  }
}
