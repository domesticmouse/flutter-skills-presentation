import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../catalog/catalog_models.dart' show CatalogSnapshot, Part;
import '../catalog/catalog_provider.dart';
import '../lcsc/lcsc_client.dart';
import '../search/workbench_filter_provider.dart';

const _uuid = Uuid();

class AddOrEditPartSheet extends ConsumerStatefulWidget {
  const AddOrEditPartSheet({
    super.key,
    this.existingPart,
    this.initialContainerId,
  });

  final Part? existingPart;
  final String? initialContainerId;

  @override
  ConsumerState<AddOrEditPartSheet> createState() => _AddOrEditPartSheetState();
}

class _AddOrEditPartSheetState extends ConsumerState<AddOrEditPartSheet> {
  late final TextEditingController _lcscCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _packageCtrl;
  late final TextEditingController _mpnCtrl;
  late final TextEditingController _manufacturerCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _lowStockCtrl;
  late final TextEditingController _slotCtrl;
  late final TextEditingController _datasheetCtrl;
  late final TextEditingController _notesCtrl;

  String? _selectedContainerId;
  late List<({TextEditingController key, TextEditingController value})>
      _specRows;

  bool _isFetchingLcsc = false;
  String? _lcscLookupError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPart;
    _lcscCtrl = TextEditingController(text: p?.lcscCode ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _packageCtrl = TextEditingController(text: p?.package ?? '');
    _mpnCtrl = TextEditingController(text: p?.mpn ?? '');
    _manufacturerCtrl = TextEditingController(text: p?.manufacturer ?? '');
    _qtyCtrl = TextEditingController(text: '${p?.quantity ?? 0}');
    _lowStockCtrl = TextEditingController(
      text: p?.lowStockThreshold != null ? '${p!.lowStockThreshold}' : '',
    );
    _selectedContainerId = p?.containerId ?? widget.initialContainerId;
    _slotCtrl = TextEditingController(text: p?.slot ?? '');
    _datasheetCtrl = TextEditingController(text: p?.datasheetUrl ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');

    _specRows = [
      if (p != null)
        for (final entry in p.specs.entries)
          (
            key: TextEditingController(text: entry.key),
            value: TextEditingController(text: entry.value),
          ),
    ];
  }

  @override
  void dispose() {
    _lcscCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _packageCtrl.dispose();
    _mpnCtrl.dispose();
    _manufacturerCtrl.dispose();
    _qtyCtrl.dispose();
    _lowStockCtrl.dispose();
    _slotCtrl.dispose();
    _datasheetCtrl.dispose();
    _notesCtrl.dispose();
    for (final row in _specRows) {
      row.key.dispose();
      row.value.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchFromLcsc() async {
    setState(() {
      _isFetchingLcsc = true;
      _lcscLookupError = null;
    });
    try {
      final client = ref.read(lcscClientProvider);
      final metadata = await client.fetchPart(_lcscCtrl.text);
      if (!mounted) return;
      setState(() {
        _lcscCtrl.text = metadata.lcscCode;
        _nameCtrl.text = metadata.name;
        _mpnCtrl.text = metadata.mpn ?? '';
        _manufacturerCtrl.text = metadata.manufacturer ?? '';
        _categoryCtrl.text = metadata.category ?? '';
        _packageCtrl.text = metadata.package ?? '';
        _datasheetCtrl.text = metadata.datasheetUrl ?? '';
        for (final row in _specRows) {
          row.key.dispose();
          row.value.dispose();
        }
        _specRows = [
          for (final entry in metadata.specs.entries)
            (
              key: TextEditingController(text: entry.key),
              value: TextEditingController(text: entry.value),
            ),
        ];
      });
    } on LcscLookupException catch (e) {
      if (!mounted) return;
      setState(() {
        _lcscLookupError = e.message;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _lcscLookupError = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLcsc = false;
        });
      }
    }
  }

  String? _resolveValidContainerId(CatalogSnapshot snapshot) {
    if (_selectedContainerId == null) return null;
    final exists = snapshot.containers.any((c) => c.id == _selectedContainerId);
    return exists ? _selectedContainerId : null;
  }

  Future<void> _savePart(CatalogSnapshot snapshot) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        _formError = 'Part name is required.';
      });
      return;
    }

    final specs = <String, String>{
      for (final row in _specRows) row.key.text: row.value.text,
    };
    final validContainerId = _resolveValidContainerId(snapshot);

    final part = Part(
      id: widget.existingPart?.id ?? 'p-${_uuid.v4()}',
      name: name,
      quantity: int.tryParse(_qtyCtrl.text.trim()) ?? 0,
      lcscCode: _lcscCtrl.text,
      mpn: _mpnCtrl.text,
      manufacturer: _manufacturerCtrl.text,
      category: _categoryCtrl.text,
      package: _packageCtrl.text,
      datasheetUrl: _datasheetCtrl.text,
      containerId: validContainerId,
      slot: _slotCtrl.text,
      lowStockThreshold: int.tryParse(_lowStockCtrl.text.trim()),
      notes: _notesCtrl.text,
      specs: specs,
    );

    try {
      await ref.read(catalogProvider.notifier).upsertPart(part);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on SlotOccupiedException catch (e) {
      setState(() {
        _formError = e.toString();
      });
    } on Object catch (e) {
      setState(() {
        _formError = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final snapshot =
        ref.watch(catalogProvider).value ?? CatalogSnapshot.empty();
    final view = ref.watch(filteredWorkbenchViewProvider);
    final validContainerId = _resolveValidContainerId(snapshot);

    final duplicateLcscPart = ref
        .read(catalogProvider.notifier)
        .findDuplicateLcscPart(
          _lcscCtrl.text,
          excludingPartId: widget.existingPart?.id,
        );
    final occupyingSlotPart = snapshot.findOccupyingSlotPart(
      validContainerId,
      _slotCtrl.text,
      excludingPartId: widget.existingPart?.id,
    );
    final rawLcscTrimmed = _lcscCtrl.text.trim();
    final hasInvalidLcscFormat = rawLcscTrimmed.isNotEmpty &&
        Catalog.normalizeLcscCodeOrNull(rawLcscTrimmed) == null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingPart == null ? 'Add Part' : 'Edit Part',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  key: const Key('save_part_button'),
                  onPressed:
                      (occupyingSlotPart != null || hasInvalidLcscFormat)
                          ? null
                          : () => _savePart(snapshot),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save Part'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('part_lcsc_input'),
                    controller: _lcscCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: InputDecoration(
                      labelText: 'LCSC Part Code (Cxxxxxx)',
                      hintText: 'e.g. C14663 or 14663',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      errorText: hasInvalidLcscFormat
                          ? 'Expected format Cxxxxxx (e.g. C14663)'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: _isFetchingLcsc ? null : _fetchFromLcsc,
                  icon: _isFetchingLcsc
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download_outlined, size: 18),
                  label: const Text('Fetch LCSC'),
                ),
              ],
            ),
            if (_lcscLookupError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lcscLookupError!,
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
                ),
              ),
            ],
            if (duplicateLcscPart != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${duplicateLcscPart.lcscCode} is already in your catalog ("${duplicateLcscPart.name}").',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(duplicateLcscPart.id);
                      },
                      child: const Text('Jump to Part'),
                    ),
                  ],
                ),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 8),
              Text(
                _formError!,
                style: TextStyle(color: cs.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              key: const Key('part_name_input'),
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Part Name *',
                hintText: 'e.g. 100nF 50V X7R 0603 Capacitor',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('part_qty_input'),
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('part_low_stock_input'),
                    controller: _lowStockCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: const InputDecoration(
                      labelText: 'Low Stock Threshold',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: const Key('part_container_dropdown'),
                    initialValue: validContainerId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Container',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned (Loose / Inbox)'),
                      ),
                      for (final c in snapshot.containers)
                        DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedContainerId = val;
                        if (val == null) {
                          _slotCtrl.clear();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('part_slot_input'),
                    controller: _slotCtrl,
                    enabled: validContainerId != null,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: InputDecoration(
                      labelText: 'Slot (optional)',
                      hintText: 'e.g. Page 4, Drawer A2',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      errorText: occupyingSlotPart != null
                          ? 'Occupied by "${occupyingSlotPart.name}"'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('part_category_input'),
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('part_package_input'),
                    controller: _packageCtrl,
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: const InputDecoration(
                      labelText: 'Package / Footprint',
                      hintText: 'e.g. 0603, SOIC-8',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            if (view.availableCategories.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final cat in view.availableCategories)
                    ActionChip(
                      label: Text(cat, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() {
                          _categoryCtrl.text = cat;
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('part_mpn_input'),
                    controller: _mpnCtrl,
                    style: const TextStyle(fontFamily: 'Courier'),
                    decoration: const InputDecoration(
                      labelText: 'MPN',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('part_manufacturer_input'),
                    controller: _manufacturerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Manufacturer',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('part_datasheet_input'),
              controller: _datasheetCtrl,
              decoration: const InputDecoration(
                labelText: 'Datasheet PDF URL',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('part_notes_input'),
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Workbench Notes',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ELECTRICAL SPECS (${_specRows.length})',
                  style: Theme.of(ctx).textTheme.labelSmall,
                ),
                TextButton.icon(
                  key: const Key('add_spec_row_button'),
                  onPressed: () {
                    setState(() {
                      _specRows.add((
                        key: TextEditingController(),
                        value: TextEditingController(),
                      ));
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Spec'),
                ),
              ],
            ),
            for (var i = 0; i < _specRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: Key('spec_key_$i'),
                        controller: _specRows[i].key,
                        decoration: const InputDecoration(
                          labelText: 'Spec Name',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: Key('spec_value_$i'),
                        controller: _specRows[i].value,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      key: Key('remove_spec_$i'),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          final removed = _specRows.removeAt(i);
                          removed.key.dispose();
                          removed.value.dispose();
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
