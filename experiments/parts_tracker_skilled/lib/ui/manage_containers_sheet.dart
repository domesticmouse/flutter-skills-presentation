import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../catalog/catalog_models.dart' as models;
import '../catalog/catalog_models.dart' show CatalogSnapshot;
import '../catalog/catalog_provider.dart';

const _uuid = Uuid();

class ManageContainersSheet extends ConsumerStatefulWidget {
  const ManageContainersSheet({super.key});

  @override
  ConsumerState<ManageContainersSheet> createState() =>
      _ManageContainersSheetState();
}

class _ManageContainersSheetState
    extends ConsumerState<ManageContainersSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _addContainer() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(catalogProvider.notifier).upsertContainer(
          models.Container(
            id: 'c-${_uuid.v4()}',
            name: name,
            description: _descCtrl.text,
          ),
        );
    _nameCtrl.clear();
    _descCtrl.clear();
  }

  Future<void> _editContainerDialog(
    BuildContext context,
    models.Container container,
  ) async {
    final nameCtrl = TextEditingController(text: container.name);
    final descCtrl = TextEditingController(text: container.description ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Container'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Container Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final nextName = nameCtrl.text.trim();
              if (nextName.isEmpty) return;
              await ref.read(catalogProvider.notifier).upsertContainer(
                    container.copyWith(
                      name: nextName,
                      description: descCtrl.text,
                    ),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteContainer(
    BuildContext context,
    models.Container container,
    int partCount,
  ) async {
    final countLabel = partCount == 1 ? '1 part' : '$partCount parts';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${container.name}"?'),
        content: Text(
          '$countLabel currently stored in "${container.name}" will be moved to Unassigned (Loose / Inbox).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete & Unassign'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(catalogProvider.notifier)
          .deleteContainer(container.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot =
        ref.watch(catalogProvider).value ?? CatalogSnapshot.empty();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Physical Containers (${snapshot.containers.length})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in snapshot.containers) ...[
                  Builder(
                    builder: (ctx) {
                      final count = snapshot.parts
                          .where((p) => p.containerId == c.id)
                          .length;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.dns_outlined, size: 18),
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(c.description ?? 'No description'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$count parts',
                              style: const TextStyle(fontFamily: 'Courier'),
                            ),
                            IconButton(
                              key: Key('edit_container_${c.id}'),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _editContainerDialog(ctx, c),
                            ),
                            IconButton(
                              key: Key('delete_container_${c.id}'),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () =>
                                  _confirmDeleteContainer(ctx, c, count),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('new_container_name_input'),
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'New Container Name',
                    hintText: 'e.g. SMD Binder #2',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('new_container_desc_input'),
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('add_container_button'),
                onPressed: _addContainer,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
