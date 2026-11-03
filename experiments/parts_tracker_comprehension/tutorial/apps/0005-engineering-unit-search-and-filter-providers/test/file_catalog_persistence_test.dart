import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';
import 'package:parts_tracker_skilled/catalog/file_catalog_persistence.dart';

void main() {
  group('FileCatalogPersistence Seam', () {
    late Directory tempDir;
    late Directory exportDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('parts_tracker_docs_');
      exportDir = await Directory.systemTemp.createTemp('parts_tracker_export_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
    });

    test('initializes empty schemaVersion 1 catalog on first launch, saves atomically with 2-space pretty JSON, writes pre-import backup, and generates timestamped export file', () async {
      final persistence = FileCatalogPersistence(
        documentsDirectoryProvider: () async => tempDir,
        temporaryDirectoryProvider: () async => exportDir,
      );

      final initial = await persistence.load();
      expect(initial.schemaVersion, 1);
      expect(initial.containers, isEmpty);
      expect(initial.parts, isEmpty);

      final snapshot = CatalogSnapshot(
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026, 11, 3, 2, 35),
        containers: const [
          Container(
            id: 'c-binder-1',
            name: 'SMD Binder #1',
            description: '0603 Passives Sample Book',
          ),
        ],
        parts: const [
          Part(
            id: 'p-c14663',
            name: '100nF 50V X7R 0603 Capacitor',
            quantity: 185,
            lcscCode: 'C14663',
            containerId: 'c-binder-1',
            slot: 'Page 4',
            specs: {
              'Capacitance': '100nF',
              'Voltage Rated': '50V',
            },
          ),
        ],
      );

      // Enqueue multiple saves concurrently to verify serialized atomic writes
      await Future.wait([
        persistence.save(snapshot.copyWith(parts: [])),
        persistence.save(snapshot),
      ]);

      final liveFile = File('${tempDir.path}/parts_catalog.json');
      final tmpFile = File('${tempDir.path}/parts_catalog.json.tmp');
      expect(await liveFile.exists(), isTrue);
      expect(await tmpFile.exists(), isFalse);

      final rawJson = await liveFile.readAsString();
      expect(rawJson, contains('  "schemaVersion": 1,'));
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], 1);

      final reloaded = await persistence.load();
      expect(reloaded.parts.single.id, 'p-c14663');
      expect(reloaded.parts.single.specs['Capacitance'], '100nF');
      expect(reloaded.containers.single.name, 'SMD Binder #1');

      // Pre-import safety backup
      await persistence.savePreImportBackup(reloaded);
      final backupFile = File('${tempDir.path}/parts_catalog.backup.json');
      expect(await backupFile.exists(), isTrue);
      final backupDecoded =
          jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
      expect((backupDecoded['parts'] as List).single['id'], 'p-c14663');

      // Timestamped export file
      final exportPath = await persistence.writeExportFile(reloaded);
      expect(exportPath, endsWith('parts-catalog-2026-11-03.json'));
      final exportedFile = File(exportPath);
      expect(await exportedFile.exists(), isTrue);
      expect(await exportedFile.readAsString(), contains('"p-c14663"'));
    });
  });
}
