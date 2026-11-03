import 'package:flutter/material.dart';

import '../../../../domain/models/electronic_part.dart';
import '../../../../domain/models/part_category.dart';
import '../../../core/theme/app_theme.dart';

/// Modal form for creating or editing an [ElectronicPart].
class PartFormSheet extends StatefulWidget {
  const PartFormSheet({
    super.key,
    this.initialPart,
    this.existingLocations = const [],
    this.presetLocation,
  });

  final ElectronicPart? initialPart;
  final List<String> existingLocations;
  final String? presetLocation;

  @override
  State<PartFormSheet> createState() => _PartFormSheetState();
}

class _PartFormSheetState extends State<PartFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _packageController;
  late final TextEditingController _valueOrSpecsController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;
  late final TextEditingController _locationController;
  late final TextEditingController _mpnController;
  late final TextEditingController _supplierNameController;
  late final TextEditingController _supplierPartNumberController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _datasheetUrlController;
  late final TextEditingController _notesController;

  late PartCategory _selectedCategory;

  static const List<String> _commonPackages = [
    '0402',
    '0603',
    '0805',
    '1206',
    'SOT-23',
    'SOT-223',
    'SOIC-8',
    'QFP-32',
    'DIP-8',
    'Through-Hole',
    'Module',
  ];

  static const List<String> _commonSuppliers = [
    'DigiKey',
    'Mouser',
    'LCSC',
    'Adafruit',
    'SparkFun',
    'Newark',
    'AliExpress',
  ];

  bool get _isEditing => widget.initialPart != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPart;
    _selectedCategory = p?.category ?? PartCategory.resistors;
    _nameController = TextEditingController(text: p?.name ?? '');
    _packageController = TextEditingController(text: p?.package ?? '');
    _valueOrSpecsController =
        TextEditingController(text: p?.valueOrSpecs ?? '');
    _quantityController =
        TextEditingController(text: (p?.quantity ?? 10).toString());
    _minStockController =
        TextEditingController(text: (p?.minStockThreshold ?? 5).toString());
    _locationController = TextEditingController(
      text: p?.storageLocation ?? widget.presetLocation ?? '',
    );
    _mpnController =
        TextEditingController(text: p?.manufacturerPartNumber ?? '');
    _supplierNameController =
        TextEditingController(text: p?.supplierName ?? '');
    _supplierPartNumberController =
        TextEditingController(text: p?.supplierPartNumber ?? '');
    _unitPriceController = TextEditingController(
      text: p != null && p.unitPrice > 0 ? p.formattedUnitPrice : '',
    );
    _datasheetUrlController =
        TextEditingController(text: p?.datasheetUrl ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _packageController.dispose();
    _valueOrSpecsController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _mpnController.dispose();
    _supplierNameController.dispose();
    _supplierPartNumberController.dispose();
    _unitPriceController.dispose();
    _datasheetUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final now = DateTime.now().toUtc();
    final id = widget.initialPart?.id ?? 'part-${now.microsecondsSinceEpoch}';
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final minStock = int.tryParse(_minStockController.text.trim()) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;

    final part = ElectronicPart(
      id: id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      package: _packageController.text.trim(),
      valueOrSpecs: _valueOrSpecsController.text.trim(),
      quantity: quantity < 0 ? 0 : quantity,
      minStockThreshold: minStock < 0 ? 0 : minStock,
      storageLocation: _locationController.text.trim(),
      manufacturerPartNumber: _mpnController.text.trim(),
      supplierName: _supplierNameController.text.trim(),
      supplierPartNumber: _supplierPartNumberController.text.trim(),
      unitPrice: unitPrice < 0 ? 0.0 : unitPrice,
      datasheetUrl: _datasheetUrlController.text.trim(),
      notes: _notesController.text.trim(),
      updatedAt: now,
    );

    Navigator.of(context).pop(part);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Part' : 'Add Electronic Part'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              key: const Key('save_part_button'),
              onPressed: _handleSave,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset),
            children: [
              _SectionHeader(
                icon: Icons.memory,
                title: 'Part Identification & Specs',
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_name_field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Part Name *',
                  hintText: 'e.g. 10kΩ SMD Resistor, ESP32-WROOM-32E',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a part name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PartCategory>(
                key: const Key('part_category_dropdown'),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: PartCategory.values.map((category) {
                  return DropdownMenuItem<PartCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 18, color: category.color),
                        const SizedBox(width: 10),
                        Text(category.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_specs_field'),
                controller: _valueOrSpecsController,
                decoration: const InputDecoration(
                  labelText: 'Value / Key Specifications',
                  hintText: 'e.g. 10kΩ ±1% 0.125W, 100nF 50V X7R, 3.3V 1A LDO',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_package_field'),
                controller: _packageController,
                decoration: const InputDecoration(
                  labelText: 'Package / Footprint',
                  hintText: 'e.g. 0805, SOT-23, DIP-8, Through-Hole',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonPackages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final pkg = _commonPackages[index];
                    return ActionChip(
                      label: Text(pkg, style: theme.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => _packageController.text = pkg);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.inventory_2_outlined,
                title: 'Inventory & Storage Location',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('part_quantity_field'),
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity in Stock *',
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Enter 0 or more';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('part_min_stock_field'),
                      controller: _minStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Low-Stock Alert At',
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Enter 0 or more';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_location_field'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location (Bin / Drawer / Book)',
                  hintText: 'e.g. Cabinet A - Drawer 2, SMD Book 1 - Page 4',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              if (widget.existingLocations.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.existingLocations.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final loc = widget.existingLocations[index];
                      return ActionChip(
                        avatar: const Icon(Icons.folder_outlined, size: 14),
                        label: Text(loc, style: theme.textTheme.labelSmall),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => _locationController.text = loc);
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.local_shipping_outlined,
                title: 'Supplier, Part Numbers & Datasheet',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: const Key('part_supplier_name_field'),
                      controller: _supplierNameController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Name',
                        hintText: 'DigiKey, Mouser, LCSC...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('part_unit_price_field'),
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (\$)',
                        hintText: '0.10',
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) return null;
                        final parsed = double.tryParse(trimmed);
                        if (parsed == null || parsed < 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonSuppliers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final sup = _commonSuppliers[index];
                    return ActionChip(
                      label: Text(sup, style: theme.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => _supplierNameController.text = sup);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_supplier_pn_field'),
                controller: _supplierPartNumberController,
                decoration: const InputDecoration(
                  labelText: 'Supplier Part Number (SKU)',
                  hintText: 'e.g. 311-10.0KCRCT-ND, C6186',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_mpn_field'),
                controller: _mpnController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer Part Number (MPN)',
                  hintText: 'e.g. RC0805FR-0710KL',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_datasheet_field'),
                controller: _datasheetUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Datasheet URL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('part_notes_field'),
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pinout / Workbench Notes',
                  hintText: 'Pinout reminders, voltage limits, project notes...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
