// PROTOTYPE — THROWAWAY CODE FOR ISSUE 04 (Workbench UI flow and visual prototype)
// Question: "How should the iOS app look and feel at the workbench for its core loops?"
// Three structurally distinct Material 3 variants (A, B, C) switchable via the floating bottom bar.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrototypeContainer {
  final String id;
  String name;
  String? description;

  PrototypeContainer({
    required this.id,
    required this.name,
    this.description,
  });
}

class PrototypePart {
  final String id;
  String name;
  int quantity;
  String? lcscCode;
  String? mpn;
  String? manufacturer;
  String? category;
  String? package;
  String? datasheetUrl;
  String? containerId;
  String? slot;
  int? lowStockThreshold;
  String? notes;
  Map<String, String> specs;

  PrototypePart({
    required this.id,
    required this.name,
    required this.quantity,
    this.lcscCode,
    this.mpn,
    this.manufacturer,
    this.category,
    this.package,
    this.datasheetUrl,
    this.containerId,
    this.slot,
    this.lowStockThreshold,
    this.notes,
    Map<String, String>? specs,
  }) : specs = specs ?? {};

  bool get isLowStock =>
      lowStockThreshold != null && quantity <= lowStockThreshold!;

  bool get isUnassigned => containerId == null;
}

class WorkbenchPrototypeScreen extends StatefulWidget {
  final String initialVariant;

  const WorkbenchPrototypeScreen({
    super.key,
    this.initialVariant = 'A',
  });

  @override
  State<WorkbenchPrototypeScreen> createState() =>
      _WorkbenchPrototypeScreenState();
}

class _WorkbenchPrototypeScreenState extends State<WorkbenchPrototypeScreen> {
  static const List<({String key, String label})> _variants = [
    (key: 'A', label: 'A (Split Tabs & Dense Stepper Rows)'),
    (key: 'B', label: 'B (Dark Command Bar & Inline Accordion)'),
    (key: 'C', label: 'C (Physical Container & Slot Grid)'),
  ];

  late String _currentVariant;
  String _lastActionSummary = 'Ready — flip variants or test stock/entry flows';

  late final List<PrototypeContainer> _containers;
  late final List<PrototypePart> _parts;

  @override
  void initState() {
    super.initState();
    _currentVariant = widget.initialVariant;
    _containers = [
      PrototypeContainer(
        id: 'c-binder-1',
        name: 'SMD Binder #1',
        description: '0603 R/C sample book on shelf above scope',
      ),
      PrototypeContainer(
        id: 'c-ic-cab',
        name: 'IC Drawer Cabinet',
        description: 'Akro-Mils 44-drawer cabinet (rows A-F)',
      ),
      PrototypeContainer(
        id: 'c-grid-a',
        name: 'Passives Grid Box A',
        description: 'Clear 24-cell compartment box for power & through-hole',
      ),
    ];

    _parts = [
      PrototypePart(
        id: 'p-1',
        name: '10kΩ 0603 1% SMD Resistor',
        quantity: 145,
        lcscCode: 'C25804',
        mpn: '0603WAF1002T5E',
        manufacturer: 'UNI-ROYAL',
        category: 'Chip Resistor - Surface Mount',
        package: '0603',
        datasheetUrl: 'https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C25804.pdf',
        containerId: 'c-binder-1',
        slot: 'Page 4 · Strip 2',
        lowStockThreshold: 25,
        notes: 'Standard pull-up resistor',
        specs: {
          'Resistance': '10kΩ',
          'Tolerance': '±1%',
          'Power (Watts)': '100mW (1/10W)',
          'Temperature Coefficient': '±100ppm/℃',
        },
      ),
      PrototypePart(
        id: 'p-2',
        name: '4.7kΩ 0603 1% SMD Resistor',
        quantity: 12,
        lcscCode: 'C23162',
        mpn: 'RC0603FR-074K7L',
        manufacturer: 'YAGEO',
        category: 'Chip Resistor - Surface Mount',
        package: '0603',
        datasheetUrl: 'https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C23162.pdf',
        containerId: 'c-binder-1',
        slot: 'Page 2 · Strip 5',
        lowStockThreshold: 20,
        notes: 'I2C pull-up — running low!',
        specs: {
          'Resistance': '4.7kΩ',
          'Tolerance': '±1%',
          'Power (Watts)': '100mW (1/10W)',
        },
      ),
      PrototypePart(
        id: 'p-3',
        name: '100nF 50V X7R 0603 MLCC Capacitor',
        quantity: 310,
        lcscCode: 'C14663',
        mpn: 'CL10B104KB8NNNC',
        manufacturer: 'Samsung Electro-Mechanics',
        category: 'Multilayer Ceramic Capacitors MLCC - SMD/SMT',
        package: '0603',
        datasheetUrl: 'https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C14663.pdf',
        containerId: 'c-binder-1',
        slot: 'Page 9 · Strip 1',
        lowStockThreshold: 50,
        notes: 'Default decoupling cap',
        specs: {
          'Capacitance': '100nF',
          'Voltage Rated': '50V',
          'Tolerance': '±10%',
          'Temperature Coefficient': 'X7R',
        },
      ),
      PrototypePart(
        id: 'p-4',
        name: 'NE555P Precision Timer IC',
        quantity: 4,
        lcscCode: 'C7593',
        mpn: 'NE555P',
        manufacturer: 'Texas Instruments',
        category: 'Timers / Oscillators',
        package: 'DIP-8',
        datasheetUrl: 'https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C7593.pdf',
        containerId: 'c-ic-cab',
        slot: 'Drawer B3',
        lowStockThreshold: 5,
        notes: 'Through-hole DIP in anti-static foam',
        specs: {
          'Supply Voltage': '4.5V ~ 16V',
          'Frequency': '500kHz',
          'Operating Temp': '0℃ ~ +70℃',
        },
      ),
      PrototypePart(
        id: 'p-5',
        name: 'ESP32-S3-WROOM-1-N8R2 Wi-Fi/BLE MCU Module',
        quantity: 6,
        lcscCode: 'C2913202',
        mpn: 'ESP32-S3-WROOM-1-N8R2',
        manufacturer: 'Espressif Systems',
        category: 'RF Transceiver Modules',
        package: 'SMD-41',
        containerId: 'c-ic-cab',
        slot: 'Drawer A1',
        lowStockThreshold: 2,
        specs: {
          'Flash': '8MB',
          'PSRAM': '2MB',
          'Supply Voltage': '3.0V ~ 3.6V',
        },
      ),
      PrototypePart(
        id: 'p-6',
        name: 'AMS1117-3.3 LDO Voltage Regulator 1A',
        quantity: 28,
        lcscCode: 'C6186',
        mpn: 'AMS1117-3.3',
        manufacturer: 'Advanced Monolithic Systems',
        category: 'Linear Voltage Regulators (LDO)',
        package: 'SOT-223',
        containerId: 'c-grid-a',
        slot: 'Cell C4',
        lowStockThreshold: 10,
        specs: {
          'Output Voltage': '3.3V',
          'Output Current': '1A',
          'Max Input Voltage': '15V',
        },
      ),
      PrototypePart(
        id: 'p-7',
        name: 'CH340C USB-to-UART Bridge (Crystal-less)',
        quantity: 9,
        lcscCode: 'C84681',
        mpn: 'CH340C',
        manufacturer: 'WCH (Jiangsu Qin Heng)',
        category: 'USB ICs',
        package: 'SOIC-16',
        containerId: null,
        slot: null,
        lowStockThreshold: 3,
        notes: 'Just arrived in LCSC bag, needs a drawer slot',
        specs: {
          'Supply Voltage': '3.3V / 5V',
          'Interface': 'USB 2.0 Full Speed to UART',
        },
      ),
    ];
  }

  PrototypeContainer? _containerById(String? id) {
    if (id == null) return null;
    for (final c in _containers) {
      if (c.id == id) return c;
    }
    return null;
  }

  String _formatLocation(PrototypePart part) {
    final container = _containerById(part.containerId);
    if (container == null) return 'Unassigned';
    if (part.slot == null || part.slot!.trim().isEmpty) {
      return '${container.name} (Bulk)';
    }
    return '${container.name} · ${part.slot}';
  }

  void _adjustQuantity(PrototypePart part, int delta) {
    setState(() {
      final next = (part.quantity + delta).clamp(0, 999999);
      part.quantity = next;
      final sign = delta >= 0 ? '+$delta' : '$delta';
      _lastActionSummary =
          'Adjusted ${part.lcscCode ?? part.name} ($sign → qty ${part.quantity})';
    });
  }

  void _setQuantity(PrototypePart part, int newQty) {
    setState(() {
      part.quantity = newQty.clamp(0, 999999);
      _lastActionSummary =
          'Set ${part.lcscCode ?? part.name} quantity = ${part.quantity}';
    });
  }

  void _switchVariant(String key) {
    setState(() {
      _currentVariant = key;
      _lastActionSummary = 'Switched to Variant $key';
    });
  }

  void _cycleVariant(int step) {
    final idx = _variants.indexWhere((v) => v.key == _currentVariant);
    final nextIdx = (idx + step + _variants.length) % _variants.length;
    _switchVariant(_variants[nextIdx].key);
  }

  Future<void> _openPartDetailSheet(PrototypePart part) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final container = _containerById(part.containerId);
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
                                    _BadgePill(
                                      text: part.lcscCode!,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .primaryContainer,
                                      textColor: Theme.of(ctx)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  if (part.package != null)
                                    _BadgePill(
                                      text: part.package!,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .secondaryContainer,
                                      textColor: Theme.of(ctx)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  if (part.category != null)
                                    _BadgePill(
                                      text: part.category!,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      textColor: Theme.of(ctx)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                                      ?.copyWith(
                                        color: Theme.of(ctx)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _openAddOrEditPartSheet(existingPart: part);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Part',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Workbench Location & Quick Stock Card
                    Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(ctx).colorScheme.surfaceContainerHigh,
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
                                      : Theme.of(ctx).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatLocation(part),
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (part.isLowStock)
                                  _BadgePill(
                                    text:
                                        'LOW STOCK (≤${part.lowStockThreshold})',
                                    color:
                                        Theme.of(ctx).colorScheme.errorContainer,
                                    textColor: Theme.of(ctx)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'QUANTITY ON HAND',
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(letterSpacing: 0.8),
                                ),
                                Text(
                                  '${part.quantity}',
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: part.isLowStock
                                            ? Theme.of(ctx).colorScheme.error
                                            : null,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final delta in [-10, -1, 1, 10])
                                  FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(48, 38),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                    onPressed: () {
                                      _adjustQuantity(part, delta);
                                      setSheetState(() {});
                                    },
                                    child: Text(
                                      delta > 0 ? '+$delta' : '$delta',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(48, 38),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () async {
                                    final custom =
                                        await _promptCustomDelta(ctx, part);
                                    if (custom != null) {
                                      _setQuantity(part, custom);
                                      setSheetState(() {});
                                    }
                                  },
                                  child: const Text('Set…'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (part.notes != null && part.notes!.isNotEmpty) ...[
                      Text(
                        'Workbench Notes',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(part.notes!),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Electrical & Physical Specs (${part.specs.length})',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (part.specs.isEmpty)
                      const Text('No specs recorded.')
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(ctx).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            for (final (idx, entry)
                                in part.specs.entries.indexed) ...[
                              if (idx > 0)
                                Divider(
                                  height: 1,
                                  color:
                                      Theme.of(ctx).colorScheme.outlineVariant,
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: Theme.of(ctx)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.value,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (part.datasheetUrl != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Prototype: Opens PDF Datasheet (${part.datasheetUrl})'),
                            ),
                          );
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

  Future<int?> _promptCustomDelta(
      BuildContext context, PrototypePart part) async {
    final controller = TextEditingController(text: '${part.quantity}');
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Quantity — ${part.lcscCode ?? part.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New exact quantity on hand',
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
              final parsed = int.tryParse(controller.text.trim());
              Navigator.of(ctx).pop(parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddOrEditPartSheet({
    PrototypePart? existingPart,
    String? preselectedContainerId,
    String? preselectedSlot,
  }) async {
    final lcscController =
        TextEditingController(text: existingPart?.lcscCode ?? '');
    final nameController =
        TextEditingController(text: existingPart?.name ?? '');
    final qtyController =
        TextEditingController(text: '${existingPart?.quantity ?? 10}');
    final mpnController = TextEditingController(text: existingPart?.mpn ?? '');
    final mfgController =
        TextEditingController(text: existingPart?.manufacturer ?? '');
    final categoryController =
        TextEditingController(text: existingPart?.category ?? '');
    final packageController =
        TextEditingController(text: existingPart?.package ?? '');
    final slotController = TextEditingController(
        text: existingPart?.slot ?? preselectedSlot ?? '');
    final lowStockController = TextEditingController(
        text: existingPart?.lowStockThreshold?.toString() ?? '');
    final notesController =
        TextEditingController(text: existingPart?.notes ?? '');

    String? selectedContainerId =
        existingPart?.containerId ?? preselectedContainerId;
    Map<String, String> editableSpecs =
        Map<String, String>.from(existingPart?.specs ?? {});
    bool isFetchingLcsc = false;
    String? lcscStatusBanner;

    // Simulated LCSC lookup presets so the user can test live auto-fill in the prototype
    final simulatedLcscCatalog = <String, Map<String, dynamic>>{
      'C25804': {
        'name': '10kΩ 0603 1% SMD Resistor',
        'mpn': '0603WAF1002T5E',
        'manufacturer': 'UNI-ROYAL',
        'category': 'Chip Resistor - Surface Mount',
        'package': '0603',
        'specs': {
          'Resistance': '10kΩ',
          'Tolerance': '±1%',
          'Power (Watts)': '100mW (1/10W)',
        },
      },
      'C1525': {
        'name': '10nF 50V X7R 0402 MLCC Capacitor',
        'mpn': 'CL05B103KB5NNNC',
        'manufacturer': 'Samsung Electro-Mechanics',
        'category': 'Multilayer Ceramic Capacitors MLCC - SMD/SMT',
        'package': '0402',
        'specs': {
          'Capacitance': '10nF',
          'Voltage Rated': '50V',
          'Tolerance': '±10%',
          'Temperature Coefficient': 'X7R',
        },
      },
      'C2040': {
        'name': 'RP2040 Dual-Core ARM Cortex-M0+ Microcontroller',
        'mpn': 'RP2040',
        'manufacturer': 'Raspberry Pi',
        'category': 'Microcontrollers (MCU/MPU/SOC)',
        'package': 'QFN-56-EP(7x7)',
        'specs': {
          'Core Processor': 'ARM Cortex-M0+',
          'Clock Frequency': '133MHz',
          'RAM Size': '264KB',
          'Operating Voltage': '1.8V ~ 3.3V',
        },
      },
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final normalizedCode = lcscController.text.trim().toUpperCase();
            PrototypePart? duplicateLcscPart;
            if (normalizedCode.isNotEmpty) {
              for (final p in _parts) {
                if (p.id != existingPart?.id &&
                    p.lcscCode?.toUpperCase() == normalizedCode) {
                  duplicateLcscPart = p;
                  break;
                }
              }
            }

            PrototypePart? slotOccupant;
            final trimmedSlot = slotController.text.trim();
            if (selectedContainerId != null && trimmedSlot.isNotEmpty) {
              for (final p in _parts) {
                if (p.id != existingPart?.id &&
                    p.containerId == selectedContainerId &&
                    (p.slot ?? '').trim().toLowerCase() ==
                        trimmedSlot.toLowerCase()) {
                  slotOccupant = p;
                  break;
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 4,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existingPart == null
                          ? 'Add Part to Catalog'
                          : 'Edit Part',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // LCSC Auto-fill row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lcscController,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'LCSC Part Code (optional)',
                              hintText: 'e.g. C1525, C2040, C25804',
                              prefixIcon: Icon(Icons.qr_code_2),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: isFetchingLcsc
                              ? null
                              : () async {
                                  final code =
                                      lcscController.text.trim().toUpperCase();
                                  if (code.isEmpty) return;
                                  setModalState(() {
                                    isFetchingLcsc = true;
                                    lcscStatusBanner = null;
                                  });
                                  await Future<void>.delayed(
                                      const Duration(milliseconds: 250));
                                  final mock = simulatedLcscCatalog[code] ??
                                      {
                                        'name':
                                            '$code Sample Component (Auto-filled)',
                                        'mpn': 'MPN-$code-TR',
                                        'manufacturer': 'LCSC Generic',
                                        'category': 'Integrated Circuits (ICs)',
                                        'package': 'SOIC-8',
                                        'specs': {
                                          'Supply Voltage': '3.3V ~ 5V',
                                          'Package': 'SOIC-8',
                                        },
                                      };
                                  setModalState(() {
                                    isFetchingLcsc = false;
                                    lcscController.text = code;
                                    nameController.text =
                                        mock['name'] as String;
                                    mpnController.text = mock['mpn'] as String;
                                    mfgController.text =
                                        mock['manufacturer'] as String;
                                    categoryController.text =
                                        mock['category'] as String;
                                    packageController.text =
                                        mock['package'] as String;
                                    editableSpecs = Map<String, String>.from(
                                      mock['specs'] as Map<String, String>,
                                    );
                                    lcscStatusBanner =
                                        'Fetched metadata & ${editableSpecs.length} specs from wmsc.lcsc.com for $code';
                                  });
                                },
                          icon: isFetchingLcsc
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_download_outlined),
                          label: const Text('Fetch LCSC'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        Text(
                          'Try sample codes:',
                          style: Theme.of(ctx).textTheme.labelSmall,
                        ),
                        for (final sample in ['C1525', 'C2040', 'C25804'])
                          ActionChip(
                            label: Text(sample,
                                style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setModalState(() {
                                lcscController.text = sample;
                              });
                            },
                          ),
                      ],
                    ),
                    if (lcscStatusBanner != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color:
                                  Theme.of(ctx).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lcscStatusBanner!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (duplicateLcscPart != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 20,
                              color:
                                  Theme.of(ctx).colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Duplicate LCSC code: "${duplicateLcscPart.name}" already in ${_formatLocation(duplicateLcscPart)} (qty ${duplicateLcscPart.quantity}).',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onTertiaryContainer,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final target = duplicateLcscPart!;
                                Navigator.of(ctx).pop();
                                _openPartDetailSheet(target);
                              },
                              child: const Text('Jump to Part'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Part Name *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qty *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Storage Location section (Container + Slot)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedContainerId,
                            decoration: const InputDecoration(
                              labelText: 'Container',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Unassigned (Loose / Inbox)'),
                              ),
                              for (final c in _containers)
                                DropdownMenuItem<String?>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                            ],
                            onChanged: (val) {
                              setModalState(() {
                                selectedContainerId = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: slotController,
                            enabled: selectedContainerId != null,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Slot (1-to-1)',
                              hintText: 'e.g. A1, Drawer 4',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (slotOccupant != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Slot conflict: "${slotOccupant.slot}" already holds ${slotOccupant.name}. Choose a free slot.',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: packageController,
                            decoration: const InputDecoration(
                              labelText: 'Package / Footprint',
                              hintText: '0603, DIP-8, SOT-23',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: mpnController,
                            decoration: const InputDecoration(
                              labelText: 'MPN',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lowStockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Low Stock Alert ≤',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (editableSpecs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Specs (${editableSpecs.length})',
                        style: Theme.of(ctx).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final e in editableSpecs.entries)
                            InputChip(
                              label: Text('${e.key}: ${e.value}',
                                  style: const TextStyle(fontSize: 11)),
                              onDeleted: () {
                                setModalState(() {
                                  editableSpecs.remove(e.key);
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: slotOccupant != null
                              ? null
                              : () {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) return;
                                  final qty =
                                      int.tryParse(qtyController.text.trim()) ??
                                          0;
                                  final low = int.tryParse(
                                      lowStockController.text.trim());
                                  final code =
                                      lcscController.text.trim().toUpperCase();
                                  setState(() {
                                    if (existingPart != null) {
                                      existingPart
                                        ..name = name
                                        ..quantity = qty
                                        ..lcscCode = code.isEmpty ? null : code
                                        ..mpn =
                                            mpnController.text.trim().isEmpty
                                                ? null
                                                : mpnController.text.trim()
                                        ..manufacturer =
                                            mfgController.text.trim().isEmpty
                                                ? null
                                                : mfgController.text.trim()
                                        ..category = categoryController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : categoryController.text.trim()
                                        ..package = packageController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : packageController.text.trim()
                                        ..containerId = selectedContainerId
                                        ..slot = selectedContainerId == null ||
                                                slotController.text
                                                    .trim()
                                                    .isEmpty
                                            ? null
                                            : slotController.text.trim()
                                        ..lowStockThreshold = low
                                        ..notes =
                                            notesController.text.trim().isEmpty
                                                ? null
                                                : notesController.text.trim()
                                        ..specs = editableSpecs;
                                      _lastActionSummary =
                                          'Updated part "$name"';
                                    } else {
                                      _parts.insert(
                                        0,
                                        PrototypePart(
                                          id: 'p-${DateTime.now().millisecondsSinceEpoch}',
                                          name: name,
                                          quantity: qty,
                                          lcscCode: code.isEmpty ? null : code,
                                          mpn: mpnController.text.trim().isEmpty
                                              ? null
                                              : mpnController.text.trim(),
                                          manufacturer:
                                              mfgController.text.trim().isEmpty
                                                  ? null
                                                  : mfgController.text.trim(),
                                          category: categoryController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : categoryController.text.trim(),
                                          package: packageController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : packageController.text.trim(),
                                          containerId: selectedContainerId,
                                          slot: selectedContainerId == null ||
                                                  slotController.text
                                                      .trim()
                                                      .isEmpty
                                              ? null
                                              : slotController.text.trim(),
                                          lowStockThreshold: low,
                                          notes: notesController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : notesController.text.trim(),
                                          specs: editableSpecs,
                                        ),
                                      );
                                      _lastActionSummary =
                                          'Added part "$name" (qty $qty)';
                                    }
                                  });
                                  Navigator.of(ctx).pop();
                                },
                          icon: const Icon(Icons.check),
                          label: Text(existingPart == null
                              ? 'Add to Catalog'
                              : 'Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final focused = FocusManager.instance.primaryFocus;
          final isInputFocused =
              focused?.context?.widget is EditableText ||
              (focused?.debugLabel?.contains('EditableText') ?? false);
          if (!isInputFocused) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _cycleVariant(-1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _cycleVariant(1);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          if (_currentVariant == 'A')
            VariantASplitTabsDenseRows(
              parts: _parts,
              containers: _containers,
              formatLocation: _formatLocation,
              onAdjustQty: _adjustQuantity,
              onOpenPart: _openPartDetailSheet,
              onAddPart: ({containerId, slot}) => _openAddOrEditPartSheet(
                preselectedContainerId: containerId,
                preselectedSlot: slot,
              ),
            )
          else if (_currentVariant == 'B')
            VariantBDarkCommandAccordion(
              parts: _parts,
              containers: _containers,
              formatLocation: _formatLocation,
              onAdjustQty: _adjustQuantity,
              onSetQty: _setQuantity,
              onOpenPart: _openPartDetailSheet,
              onAddPart: ({containerId, slot}) => _openAddOrEditPartSheet(
                preselectedContainerId: containerId,
                preselectedSlot: slot,
              ),
            )
          else
            VariantCPhysicalContainerGrid(
              parts: _parts,
              containers: _containers,
              formatLocation: _formatLocation,
              onAdjustQty: _adjustQuantity,
              onOpenPart: _openPartDetailSheet,
              onAddPart: ({containerId, slot}) => _openAddOrEditPartSheet(
                preselectedContainerId: containerId,
                preselectedSlot: slot,
              ),
            ),
          if (kDebugMode)
            Positioned(
              left: 12,
              right: 12,
              bottom: _currentVariant == 'A' ? 88 : 20,
              child: Center(
                child: PrototypeSwitcher(
                  variants: _variants,
                  currentKey: _currentVariant,
                  stateSummary: _lastActionSummary,
                  onPrevious: () => _cycleVariant(-1),
                  onNext: () => _cycleVariant(1),
                  onSelect: _switchVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// VARIANT A: Split Bottom Tabs (Parts | Storage) + Sticky Search & Stepper Rows
// ============================================================================
class VariantASplitTabsDenseRows extends StatefulWidget {
  final List<PrototypePart> parts;
  final List<PrototypeContainer> containers;
  final String Function(PrototypePart) formatLocation;
  final void Function(PrototypePart, int) onAdjustQty;
  final void Function(PrototypePart) onOpenPart;
  final void Function({String? containerId, String? slot}) onAddPart;

  const VariantASplitTabsDenseRows({
    super.key,
    required this.parts,
    required this.containers,
    required this.formatLocation,
    required this.onAdjustQty,
    required this.onOpenPart,
    required this.onAddPart,
  });

  @override
  State<VariantASplitTabsDenseRows> createState() =>
      _VariantASplitTabsDenseRowsState();
}

class _VariantASplitTabsDenseRowsState
    extends State<VariantASplitTabsDenseRows> {
  int _tabIndex = 0;
  String _query = '';
  String _activeFilter = 'All';

  List<PrototypePart> get _filteredParts {
    return widget.parts.where((p) {
      if (_activeFilter == 'Low Stock' && !p.isLowStock) return false;
      if (_activeFilter == 'Unassigned' && !p.isUnassigned) return false;
      if (_activeFilter == 'Passives' &&
          !(p.category?.toLowerCase().contains('resistor') == true ||
              p.category?.toLowerCase().contains('capacitor') == true)) {
        return false;
      }
      if (_activeFilter == 'ICs & MCUs' &&
          (p.category?.toLowerCase().contains('resistor') == true ||
              p.category?.toLowerCase().contains('capacitor') == true)) {
        return false;
      }
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      final haystack = [
        p.name,
        p.lcscCode ?? '',
        p.mpn ?? '',
        p.package ?? '',
        p.category ?? '',
        widget.formatLocation(p),
        ...p.specs.values,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF005CBB),
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: theme,
      child: Builder(
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _tabIndex == 0 ? 'Workbench Catalog' : 'Storage Containers',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () => widget.onAddPart(),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add Part',
                ),
              ],
            ),
            body: _tabIndex == 0
                ? _buildCatalogTab(ctx, cs)
                : _buildStorageTab(ctx, cs),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (idx) => setState(() => _tabIndex = idx),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.memory_outlined),
                  selectedIcon: const Icon(Icons.memory),
                  label: 'Parts (${widget.parts.length})',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.dns_outlined),
                  selectedIcon: const Icon(Icons.dns),
                  label: 'Storage (${widget.containers.length})',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogTab(BuildContext context, ColorScheme cs) {
    final results = _filteredParts;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search value (4.7k, 100nF), package (0603), C-code…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _query = ''),
                    )
                  : null,
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.65),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final filter in [
                'All',
                'Low Stock',
                'Unassigned',
                'Passives',
                'ICs & MCUs',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(filter, style: const TextStyle(fontSize: 12)),
                    selected: _activeFilter == filter,
                    onSelected: (_) => setState(() => _activeFilter = filter),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: results.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: cs.outlineVariant),
            itemBuilder: (ctx, idx) {
              final part = results[idx];
              return InkWell(
                onTap: () => widget.onOpenPart(part),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (part.package != null) ...[
                                  _BadgePill(
                                    text: part.package!,
                                    color: cs.secondaryContainer,
                                    textColor: cs.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    part.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: part.isUnassigned
                                        ? Colors.amber.shade100
                                        : cs.primaryContainer
                                            .withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        part.isUnassigned
                                            ? Icons.inbox_outlined
                                            : Icons.place_outlined,
                                        size: 13,
                                        color: part.isUnassigned
                                            ? Colors.amber.shade900
                                            : cs.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.formatLocation(part),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: part.isUnassigned
                                              ? Colors.amber.shade900
                                              : cs.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (part.lcscCode != null)
                                  Text(
                                    part.lcscCode!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Courier',
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Inline [-1] Qty [+1] Stepper
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () => widget.onAdjustQty(part, -1),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${part.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: part.isLowStock ? cs.error : null,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => widget.onAdjustQty(part, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageTab(BuildContext context, ColorScheme cs) {
    final unassigned = widget.parts.where((p) => p.isUnassigned).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      children: [
        if (unassigned.isNotEmpty)
          Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: Icon(Icons.inbox, color: Colors.amber.shade900),
              title: Text(
                'Unassigned Workbench Inbox (${unassigned.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
              subtitle: Text(
                unassigned.map((p) => p.name).join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => widget.onOpenPart(unassigned.first),
            ),
          ),
        for (final container in widget.containers) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              container.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (container.description != null)
                              Text(
                                container.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            widget.onAddPart(containerId: container.id),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Slot'),
                      ),
                    ],
                  ),
                  const Divider(),
                  for (final part in widget.parts
                      .where((p) => p.containerId == container.id))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: _BadgePill(
                        text: part.slot ?? 'Bulk',
                        color: cs.primaryContainer,
                        textColor: cs.onPrimaryContainer,
                      ),
                      title: Text(
                        part.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        'Qty ${part.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: part.isLowStock ? cs.error : null,
                        ),
                      ),
                      onTap: () => widget.onOpenPart(part),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// VARIANT B: Dark Industrial Command Search & Inline Expandable Cards
// ============================================================================
class VariantBDarkCommandAccordion extends StatefulWidget {
  final List<PrototypePart> parts;
  final List<PrototypeContainer> containers;
  final String Function(PrototypePart) formatLocation;
  final void Function(PrototypePart, int) onAdjustQty;
  final void Function(PrototypePart, int) onSetQty;
  final void Function(PrototypePart) onOpenPart;
  final void Function({String? containerId, String? slot}) onAddPart;

  const VariantBDarkCommandAccordion({
    super.key,
    required this.parts,
    required this.containers,
    required this.formatLocation,
    required this.onAdjustQty,
    required this.onSetQty,
    required this.onOpenPart,
    required this.onAddPart,
  });

  @override
  State<VariantBDarkCommandAccordion> createState() =>
      _VariantBDarkCommandAccordionState();
}

class _VariantBDarkCommandAccordionState
    extends State<VariantBDarkCommandAccordion> {
  String _query = '';
  String _activeFilter = 'All';
  String? _expandedPartId = 'p-2';
  bool _groupByContainer = false;

  List<String> get _availableCategories {
    final cats = <String>{};
    for (final p in widget.parts) {
      if (p.category != null && p.category!.trim().isNotEmpty) {
        cats.add(p.category!.trim());
      }
    }
    return cats.toList()..sort();
  }

  List<PrototypePart> get _filtered {
    return widget.parts.where((p) {
      if (_activeFilter == 'Low Stock' && !p.isLowStock) return false;
      if (_activeFilter == 'Unassigned' && !p.isUnassigned) return false;
      if (_activeFilter != 'All' &&
          _activeFilter != 'Low Stock' &&
          _activeFilter != 'Unassigned' &&
          p.category != _activeFilter) {
        return false;
      }
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      final hay = [
        p.name,
        p.lcscCode ?? '',
        p.mpn ?? '',
        p.package ?? '',
        p.category ?? '',
        widget.formatLocation(p),
        ...p.specs.entries.map((e) => '${e.key} ${e.value}'),
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  Future<void> _openContainersManageSheet(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Physical Containers (${widget.containers.length})',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (final c in widget.containers)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dns_outlined, size: 18),
                      title: Text(c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c.description ?? 'No description'),
                      trailing: Text(
                        '${widget.parts.where((p) => p.containerId == c.id).length} parts',
                        style: const TextStyle(fontFamily: 'Courier'),
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
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
                          controller: descCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          setState(() {
                            widget.containers.add(
                              PrototypeContainer(
                                id: 'c-${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                description: descCtrl.text.trim().isEmpty
                                    ? null
                                    : descCtrl.text.trim(),
                              ),
                            );
                          });
                          setSheetState(() {
                            nameCtrl.clear();
                            descCtrl.clear();
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00E5FF),
        brightness: Brightness.dark,
      ),
    );

    return Theme(
      data: darkTheme,
      child: Builder(
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          final items = _filtered;

          return Scaffold(
            backgroundColor: const Color(0xFF0E1318),
            body: SafeArea(
              child: Column(
                children: [
                  // Top Command Omnibox + Quick Filter Chips + Container/Backup controls
                  Container(
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
                                onChanged: (v) => setState(() => _query = v),
                                style: const TextStyle(fontFamily: 'Courier'),
                                decoration: InputDecoration(
                                  hintText:
                                      '⌘ Find: "0603 4.7k", "C14663", "Drawer B3"…',
                                  prefixIcon: Icon(Icons.terminal,
                                      color: cs.primary, size: 20),
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
                              onPressed: () => _openContainersManageSheet(ctx),
                              icon: const Icon(Icons.dns_outlined, size: 18),
                            ),
                            const SizedBox(width: 4),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onPressed: () => widget.onAddPart(),
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
                                avatar: const Icon(Icons.folder_copy_outlined,
                                    size: 14),
                                label: const Text('By Container',
                                    style: TextStyle(fontSize: 11)),
                                selected: _groupByContainer,
                                onSelected: (v) =>
                                    setState(() => _groupByContainer = v),
                                visualDensity: VisualDensity.compact,
                              ),
                              const VerticalDivider(width: 14),
                              for (final chip in [
                                'All',
                                'Low Stock',
                                'Unassigned',
                                ..._availableCategories,
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(chip,
                                        style: const TextStyle(fontSize: 11)),
                                    selected: _activeFilter == chip,
                                    onSelected: (_) =>
                                        setState(() => _activeFilter = chip),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _groupByContainer
                        ? _buildGroupedByContainerList(ctx, cs, items)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) =>
                                _buildPartAccordionCard(ctx, cs, items[i]),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedByContainerList(
    BuildContext context,
    ColorScheme cs,
    List<PrototypePart> items,
  ) {
    final unassigned = items.where((p) => p.isUnassigned).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
      children: [
        if (unassigned.isNotEmpty) ...[
          _buildContainerSectionHeader(
            cs,
            title: 'Unassigned (Loose / Inbox)',
            subtitle: '${unassigned.length} parts waiting for a slot',
            containerId: null,
          ),
          for (final p in unassigned) _buildPartAccordionCard(context, cs, p),
          const SizedBox(height: 10),
        ],
        for (final c in widget.containers) ...[
          _buildContainerSectionHeader(
            cs,
            title: c.name,
            subtitle: c.description ??
                '${items.where((p) => p.containerId == c.id).length} parts',
            containerId: c.id,
          ),
          for (final p in items.where((p) => p.containerId == c.id))
            _buildPartAccordionCard(context, cs, p),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildContainerSectionHeader(
    ColorScheme cs, {
    required String title,
    required String subtitle,
    required String? containerId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Icon(
            containerId == null ? Icons.inbox_outlined : Icons.dns_outlined,
            size: 16,
            color: cs.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
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
          if (containerId != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => widget.onAddPart(containerId: containerId),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Slot', style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildPartAccordionCard(
    BuildContext context,
    ColorScheme cs,
    PrototypePart part,
  ) {
    final isExpanded = _expandedPartId == part.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isExpanded ? const Color(0xFF1C2631) : const Color(0xFF141B22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isExpanded
              ? cs.primary
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          '${widget.formatLocation(part)}  •  ${part.package ?? "-"}  •  ${part.lcscCode ?? "No LCSC"}',
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final e in part.specs.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final delta in [-10, -1, 1, 10])
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(42, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => widget.onAdjustQty(part, delta),
                        child: Text(
                          delta > 0 ? '+$delta' : '$delta',
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => widget.onOpenPart(part),
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
}

// ============================================================================
// VARIANT C: Physical Container Carousel & 2-Column Compartment Slot Grid
// ============================================================================
class VariantCPhysicalContainerGrid extends StatefulWidget {
  final List<PrototypePart> parts;
  final List<PrototypeContainer> containers;
  final String Function(PrototypePart) formatLocation;
  final void Function(PrototypePart, int) onAdjustQty;
  final void Function(PrototypePart) onOpenPart;
  final void Function({String? containerId, String? slot}) onAddPart;

  const VariantCPhysicalContainerGrid({
    super.key,
    required this.parts,
    required this.containers,
    required this.formatLocation,
    required this.onAdjustQty,
    required this.onOpenPart,
    required this.onAddPart,
  });

  @override
  State<VariantCPhysicalContainerGrid> createState() =>
      _VariantCPhysicalContainerGridState();
}

class _VariantCPhysicalContainerGridState
    extends State<VariantCPhysicalContainerGrid> {
  String _selectedBucket = 'ALL'; // 'ALL', 'UNASSIGNED', or container.id
  String _search = '';

  List<PrototypePart> get _visibleParts {
    return widget.parts.where((p) {
      if (_selectedBucket == 'UNASSIGNED' && !p.isUnassigned) return false;
      if (_selectedBucket != 'ALL' &&
          _selectedBucket != 'UNASSIGNED' &&
          p.containerId != _selectedBucket) {
        return false;
      }
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase();
      return [
        p.name,
        p.slot ?? '',
        p.lcscCode ?? '',
        p.package ?? '',
      ].join(' ').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E6B4E),
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: theme,
      child: Builder(
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          final items = _visibleParts;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Bench Storage Matrix',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                FilledButton.tonalIcon(
                  onPressed: () => widget.onAddPart(
                    containerId: _selectedBucket != 'ALL' &&
                            _selectedBucket != 'UNASSIGNED'
                        ? _selectedBucket
                        : null,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Part'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal Physical Container Selector Cards
                SizedBox(
                  height: 78,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _ContainerSelectorCard(
                        title: 'All Bench Bins',
                        subtitle: '${widget.parts.length} parts total',
                        icon: Icons.apps,
                        selected: _selectedBucket == 'ALL',
                        onTap: () => setState(() => _selectedBucket = 'ALL'),
                      ),
                      for (final c in widget.containers)
                        _ContainerSelectorCard(
                          title: c.name,
                          subtitle:
                              '${widget.parts.where((p) => p.containerId == c.id).length} occupied slots',
                          icon: Icons.grid_view_rounded,
                          selected: _selectedBucket == c.id,
                          onTap: () => setState(() => _selectedBucket = c.id),
                        ),
                      _ContainerSelectorCard(
                        title: 'Unassigned Tray',
                        subtitle:
                            '${widget.parts.where((p) => p.isUnassigned).length} loose parts',
                        icon: Icons.inbox_outlined,
                        selected: _selectedBucket == 'UNASSIGNED',
                        onTap: () =>
                            setState(() => _selectedBucket = 'UNASSIGNED'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText:
                          'Filter slots or values in selected container…',
                      prefixIcon: const Icon(Icons.filter_alt_outlined),
                      isDense: true,
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 96),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.18,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final part = items[i];
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: cs.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: part.isLowStock
                                ? cs.error
                                : cs.outlineVariant,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => widget.onOpenPart(part),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: part.isUnassigned
                                              ? Colors.amber.shade200
                                              : cs.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          part.slot ?? 'Unassigned',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: part.isUnassigned
                                                ? Colors.amber.shade900
                                                : cs.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (part.package != null)
                                      Text(
                                        part.package!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    part.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton.filledTonal(
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                          minWidth: 30, minHeight: 30),
                                      padding: EdgeInsets.zero,
                                      onPressed: () =>
                                          widget.onAdjustQty(part, -1),
                                      icon: const Icon(Icons.remove, size: 15),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${part.quantity}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: part.isLowStock
                                                ? cs.error
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          'pcs',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton.filledTonal(
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                          minWidth: 30, minHeight: 30),
                                      padding: EdgeInsets.zero,
                                      onPressed: () =>
                                          widget.onAdjustQty(part, 1),
                                      icon: const Icon(Icons.add, size: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContainerSelectorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ContainerSelectorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 165,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? cs.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon,
                      size: 16,
                      color:
                          selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: selected ? cs.onPrimaryContainer : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? cs.onPrimaryContainer.withValues(alpha: 0.8)
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED FLOATING PROTOTYPE SWITCHER BAR
// ============================================================================
class PrototypeSwitcher extends StatelessWidget {
  final List<({String key, String label})> variants;
  final String currentKey;
  final String stateSummary;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<String> onSelect;

  const PrototypeSwitcher({
    super.key,
    required this.variants,
    required this.currentKey,
    required this.stateSummary,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final current = variants.firstWhere(
      (v) => v.key == currentKey,
      orElse: () => variants.first,
    );

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      color: const Color(0xFF111827),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  tooltip: 'Previous Variant (←)',
                ),
                PopupMenuButton<String>(
                  onSelected: onSelect,
                  itemBuilder: (ctx) => [
                    for (final v in variants)
                      PopupMenuItem<String>(
                        value: v.key,
                        child: Text(v.label),
                      ),
                  ],
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      current.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  tooltip: 'Next Variant (→)',
                ),
              ],
            ),
            Text(
              stateSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _BadgePill({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
