import 'catalog_models.dart';

abstract class CatalogPersistence {
  Future<CatalogSnapshot> load();
  Future<void> save(CatalogSnapshot snapshot);
  Future<void> savePreImportBackup(CatalogSnapshot currentSnapshot);
  Future<String> writeExportFile(CatalogSnapshot snapshot);
  Future<void> shareExportFile(CatalogSnapshot snapshot);
  Future<String?> pickImportJson();
}

class InMemoryCatalogPersistence implements CatalogPersistence {
  InMemoryCatalogPersistence([
    CatalogSnapshot? initial,
    this.onPickImportJson,
    this.onShareExportFile,
  ]) : _current = initial;

  CatalogSnapshot? _current;
  CatalogSnapshot? lastPreImportBackup;
  String? lastExportPath;
  Future<String?> Function()? onPickImportJson;
  Future<void> Function(String path)? onShareExportFile;

  @override
  Future<CatalogSnapshot> load() async {
    return _current ?? CatalogSnapshot.empty();
  }

  @override
  Future<void> save(CatalogSnapshot snapshot) async {
    _current = snapshot;
  }

  @override
  Future<void> savePreImportBackup(CatalogSnapshot currentSnapshot) async {
    lastPreImportBackup = currentSnapshot;
  }

  @override
  Future<String> writeExportFile(CatalogSnapshot snapshot) async {
    final path = '/tmp/${snapshot.exportFileName}';
    lastExportPath = path;
    return path;
  }

  @override
  Future<void> shareExportFile(CatalogSnapshot snapshot) async {
    final path = await writeExportFile(snapshot);
    if (onShareExportFile != null) {
      await onShareExportFile!(path);
    }
  }

  @override
  Future<String?> pickImportJson() async {
    if (onPickImportJson != null) {
      return onPickImportJson!();
    }
    return null;
  }
}
