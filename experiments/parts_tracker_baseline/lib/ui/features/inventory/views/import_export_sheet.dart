import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../view_models/inventory_view_model.dart';

/// Full-screen modal sheet for JSON and CSV inventory export & import.
class ImportExportSheet extends StatefulWidget {
  const ImportExportSheet({
    super.key,
    required this.viewModel,
  });

  final InventoryViewModel viewModel;

  @override
  State<ImportExportSheet> createState() => _ImportExportSheetState();
}

class _ImportExportSheetState extends State<ImportExportSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _exportAsCsv = false;
  String _exportedText = '';

  bool _importAsCsv = false;
  bool _replaceExisting = false;
  final TextEditingController _importController = TextEditingController();
  String? _importError;
  String? _importSuccess;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshExportPreview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importController.dispose();
    super.dispose();
  }

  Future<void> _refreshExportPreview() async {
    final output = _exportAsCsv
        ? await widget.viewModel.exportCsv()
        : await widget.viewModel.exportJson();
    if (!mounted) return;
    setState(() {
      _exportedText = output;
    });
  }

  Future<void> _copyExportToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _exportedText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_exportAsCsv ? 'CSV' : 'JSON'} inventory copied to clipboard',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      setState(() {
        _importController.text = text;
        _importError = null;
        _importSuccess = null;
      });
    }
  }

  Future<void> _handleImport() async {
    setState(() {
      _importError = null;
      _importSuccess = null;
    });

    try {
      final importedCount = await widget.viewModel.importData(
        content: _importController.text,
        isCsv: _importAsCsv,
        replaceExisting: _replaceExisting,
      );
      await _refreshExportPreview();
      if (!mounted) return;
      setState(() {
        _importSuccess =
            'Successfully imported $importedCount ${importedCount == 1 ? 'part' : 'parts'} (${widget.viewModel.totalDistinctParts} total parts).';
      });
    } on FormatException catch (e) {
      setState(() {
        _importError = e.message;
      });
    } on Object catch (e) {
      setState(() {
        _importError = 'Invalid data format: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup: Export & Import'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: 'Export'),
            Tab(icon: Icon(Icons.download_for_offline_outlined), text: 'Import'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Export Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Format:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('JSON'),
                            icon: Icon(Icons.data_object, size: 18),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('CSV'),
                            icon: Icon(Icons.table_chart_outlined, size: 18),
                          ),
                        ],
                        selected: {_exportAsCsv},
                        onSelectionChanged: (selection) {
                          setState(() => _exportAsCsv = selection.first);
                          _refreshExportPreview();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('copy_export_button'),
                  onPressed: _copyExportToClipboard,
                  icon: const Icon(Icons.copy),
                  label: Text(
                    'Copy ${_exportAsCsv ? 'CSV' : 'JSON'} to Clipboard',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _exportedText,
                        key: const Key('export_preview_text'),
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Import Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text(
                    'Format:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('JSON'),
                          icon: Icon(Icons.data_object, size: 18),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('CSV'),
                          icon: Icon(Icons.table_chart_outlined, size: 18),
                        ),
                      ],
                      selected: {_importAsCsv},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _importAsCsv = selection.first;
                          _importError = null;
                          _importSuccess = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Replace existing inventory'),
                subtitle: const Text(
                  'When off, imported parts are merged by ID with your current parts.',
                ),
                value: _replaceExisting,
                onChanged: (value) {
                  setState(() => _replaceExisting = value);
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paste ${_importAsCsv ? 'CSV' : 'JSON'} Data',
                    style: theme.textTheme.labelLarge,
                  ),
                  TextButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste, size: 16),
                    label: const Text('Paste Clipboard'),
                  ),
                ],
              ),
              TextField(
                key: const Key('import_text_field'),
                controller: _importController,
                maxLines: 9,
                style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                decoration: InputDecoration(
                  hintText: _importAsCsv
                      ? 'name,category,package,valueOrSpecs,quantity,storageLocation\n"1k Resistor",resistors,0805,"1kΩ 1%",100,"Bin A1"'
                      : '[\n  {\n    "id": "part-1",\n    "name": "1kΩ Resistor",\n    "category": "resistors",\n    "quantity": 100\n  }\n]',
                ),
              ),
              if (_importError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _importError!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
              if (_importSuccess != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _importSuccess!,
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('run_import_button'),
                onPressed: _handleImport,
                icon: const Icon(Icons.download_done),
                label: const Text('Import Parts'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('reset_sample_data_button'),
                onPressed: _handleResetToSampleData,
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Starter Sample Parts'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetToSampleData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset to Sample Data?'),
          content: const Text(
            'This will replace your current inventory with the default starter parts.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.viewModel.resetToSampleData();
      await _refreshExportPreview();
      if (!mounted) return;
      setState(() {
        _importError = null;
        _importSuccess =
            'Inventory reset to starter sample parts (${widget.viewModel.totalDistinctParts} parts).';
      });
    }
  }
}
