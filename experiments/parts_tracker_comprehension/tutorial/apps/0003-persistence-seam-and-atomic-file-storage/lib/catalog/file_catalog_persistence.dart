import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'catalog_models.dart';
import 'catalog_persistence.dart';

class FileCatalogPersistence implements CatalogPersistence {
  FileCatalogPersistence({
    Future<Directory> Function()? documentsDirectoryProvider,
    Future<Directory> Function()? temporaryDirectoryProvider,
  })  : _documentsDirectoryProvider =
            documentsDirectoryProvider ?? getApplicationDocumentsDirectory,
        _temporaryDirectoryProvider =
            temporaryDirectoryProvider ?? getTemporaryDirectory;

  static const String catalogFileName = 'parts_catalog.json';
  static const String catalogTempFileName = 'parts_catalog.json.tmp';
  static const String backupFileName = 'parts_catalog.backup.json';

  final Future<Directory> Function() _documentsDirectoryProvider;
  final Future<Directory> Function() _temporaryDirectoryProvider;

  static const JsonEncoder _prettyEncoder = JsonEncoder.withIndent('  ');

  Future<void> _writeQueue = Future<void>.value();

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _writeQueue = _writeQueue.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } on Object catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  @override
  Future<CatalogSnapshot> load() {
    return _enqueue(() async {
      final dir = await _documentsDirectoryProvider();
      final file = File('${dir.path}/$catalogFileName');
      if (!await file.exists()) {
        final initial = CatalogSnapshot.empty();
        await _writeAtomically(dir, catalogFileName, initial);
        return initial;
      }
      final rawJson = await file.readAsString();
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return CatalogSnapshot.fromJson(decoded);
    });
  }

  @override
  Future<void> save(CatalogSnapshot snapshot) {
    return _enqueue(() async {
      final dir = await _documentsDirectoryProvider();
      await _writeAtomically(dir, catalogFileName, snapshot);
    });
  }

  @override
  Future<void> savePreImportBackup(CatalogSnapshot currentSnapshot) {
    return _enqueue(() async {
      final dir = await _documentsDirectoryProvider();
      await _writeAtomically(dir, backupFileName, currentSnapshot);
    });
  }

  @override
  Future<String> writeExportFile(CatalogSnapshot snapshot) {
    return _enqueue(() async {
      final dir = await _temporaryDirectoryProvider();
      final fileName = snapshot.exportFileName;
      await _writeAtomically(dir, fileName, snapshot);
      return '${dir.path}/$fileName';
    });
  }

  @override
  Future<void> shareExportFile(CatalogSnapshot snapshot) async {
    final path = await writeExportFile(snapshot);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: 'Parts Tracker Catalog Backup',
      ),
    );
  }

  @override
  Future<String?> pickImportJson() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    final filePath = result.singleOrNull?.path;
    if (filePath == null) return null;
    return File(filePath).readAsString();
  }

  Future<void> _writeAtomically(
    Directory dir,
    String targetFileName,
    CatalogSnapshot snapshot,
  ) async {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final tempFile = File('${dir.path}/$targetFileName.tmp');
    final targetFile = File('${dir.path}/$targetFileName');
    final jsonMap = <String, dynamic>{
      'schemaVersion': snapshot.schemaVersion,
      'updatedAt': snapshot.updatedAt.toUtc().toIso8601String(),
      'containers': snapshot.containers.map((c) => c.toJson()).toList(),
      'parts': snapshot.parts.map((p) => p.toJson()).toList(),
    };
    final formatted = '${_prettyEncoder.convert(jsonMap)}\n';
    await tempFile.writeAsString(formatted, flush: true);
    await tempFile.rename(targetFile.path);
  }
}
