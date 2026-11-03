---
title: "Persistence Seam & Atomic Local File Storage"
page_title: "Lesson 0003 — Persistence Seam & Atomic Local File Storage"
nav_id: "lesson-0003"
badge: "Lesson 0003 • Persistence Seam & Atomic I/O"
subtitle: "Design a deep persistence module (CatalogPersistence) with an in-memory test double and an atomic, serialized file writer (FileCatalogPersistence) using Dart Futures and Completers."
card:
  title: "**Persistence Seam & Atomic Local File Storage**"
  summary: "Build CatalogPersistence, InMemoryCatalogPersistence, and FileCatalogPersistence with a serialized Completer write queue, atomic .tmp rename, and backup/export support."
---

## Why Put a Seam Between State and Disk I/O? {#why-seam}

In a browser React app, you might persist small state blobs to `localStorage` or `IndexedDB`. On mobile and desktop (iOS/macOS), our Electronics Parts Tracker stores the user's catalog in a pretty-printed `parts_catalog.json` file inside the app's documents directory—and lets the user export or import timestamped JSON backups via the native OS share sheet and file picker.

If our UI or Riverpod state notifier called `File('.../parts_catalog.json').writeAsString(...)` directly, two bad things would happen:

1. **Tests would be slow and flaky**: Every unit and widget test would touch the real filesystem or fail in headless environments where native platform plugins (`path_provider`, `share_plus`, `file_picker`) aren't attached to an iOS simulator.
2. **Concurrent taps could corrupt the catalog**: When you rapidly tap `+1` five times on a resistor's stock counter, five asynchronous `save()` calls fire in quick succession. Without a serialized queue and atomic write-then-rename (`parts_catalog.json.tmp` → `parts_catalog.json`), two overlapping writes can interleave or leave a truncated JSON file on crash.

In this lesson, we introduce the **`CatalogPersistence`** seam (`lib/catalog/catalog_persistence.dart`) and its production implementation **`FileCatalogPersistence`** (`lib/catalog/file_catalog_persistence.dart`).

```mermaid caption="Figure 3.1: The CatalogPersistence seam isolates Riverpod state and widget tests from platform file/share plugins."
flowchart TD
  Caller["Catalog AsyncNotifier / Widget Tests"] --> Seam["abstract class CatalogPersistence<br/>(load, save, savePreImportBackup, writeExportFile, shareExportFile, pickImportJson)"]
  Seam --> InMem["InMemoryCatalogPersistence<br/>(Instant, zero-I/O test double)"]
  Seam --> FileImpl["FileCatalogPersistence<br/>(Serialized _enqueue queue + atomic .tmp rename)"]
```

:::callout
**Primary Sources for Lesson 0003**: Review the [React → Flutter Cheat Sheet](../reference/react-to-flutter-cheatsheet.md), the [Verification & Testing Reference](../reference/verification-and-testing.md), and the [Dart Asynchronous Programming (`Future` & `Completer`) guide](https://dart.dev/libraries/async/async-await).
:::

---

## 1. Defining the `CatalogPersistence` Seam (`lib/catalog/catalog_persistence.dart`) {#persistence-seam}

### Block 1: The Abstract Interface Contract

In TypeScript, you define a contract with `export interface CatalogPersistence { ... }`. In Dart, every `class` implicitly defines an interface! Marked `abstract class`, it cannot be instantiated directly:

```dart caption="Abstract CatalogPersistence contract in lib/catalog/catalog_persistence.dart"
import 'catalog_models.dart';

abstract class CatalogPersistence {
  Future<CatalogSnapshot> load();
  Future<void> save(CatalogSnapshot snapshot);
  Future<void> savePreImportBackup(CatalogSnapshot currentSnapshot);
  Future<String> writeExportFile(CatalogSnapshot snapshot);
  Future<void> shareExportFile(CatalogSnapshot snapshot);
  Future<String?> pickImportJson();
}
```

- **`Future<CatalogSnapshot>`**: Dart's equivalent of TypeScript's `Promise<CatalogSnapshot>`.
- **`Future<void>`**: Equivalent to `Promise<void>` for async operations that complete without a return value.
- **`Future<String?> pickImportJson()`**: Returns a `Future` that resolves to the selected JSON file's contents, or `null` if the user cancels the native file picker dialog.

### Block 2: `InMemoryCatalogPersistence` (Zero-I/O Test Double)

```dart caption="InMemoryCatalogPersistence implementation for fast unit and widget tests"
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
```

Unpacking the new Dart syntax in `InMemoryCatalogPersistence`:

- **`implements CatalogPersistence`**: In Dart, `extends` inherits implementation from a single superclass, whereas **`implements`** treats `CatalogPersistence` purely as an interface (just like TypeScript's `implements`), requiring `InMemoryCatalogPersistence` to implement all six methods.
- **`InMemoryCatalogPersistence([CatalogSnapshot? initial, ...]) : _current = initial;`**:
  - Square brackets `[ ... ]` in a parameter list declare **optional positional parameters** (as opposed to `{ ... }` named parameters).
  - `: _current = initial` after the parameter list is a **constructor initializer list**—it initializes private fields (like `_current`) *before* the constructor body runs.
- **`Future<String?> Function()? onPickImportJson`**: Dart's function type syntax puts the return type *before* the `Function(...)` keyword (equivalent to TypeScript's `onPickImportJson?: () => Promise<string | null>`).
- **`await onShareExportFile!(path)`**: Because `onShareExportFile` is a nullable field, checking `if (onShareExportFile != null)` and using the non-null assertion `!` invokes the callback safely.

---

## 2. Building `FileCatalogPersistence` (`lib/catalog/file_catalog_persistence.dart`) {#file-persistence}

Now let's build the real disk persistence adapter in `lib/catalog/file_catalog_persistence.dart`.

### Block 1: Injectable Directory Providers & the Serialized `_enqueue` Write Queue

```dart caption="Constructor injection and serialized Future write queue in FileCatalogPersistence"
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
```

- **Injectable directory providers**: In production on iOS, `_documentsDirectoryProvider` defaults to `getApplicationDocumentsDirectory` from `package:path_provider`. In our filesystem unit test (`test/file_catalog_persistence_test.dart`), we pass `() async => tempDir` so we can test real atomic file I/O in an isolated temporary directory without needing an iOS simulator!
- **`Completer<T>` & `_enqueue<T>`**:
  - In TypeScript, creating a deferred promise requires `Promise.withResolvers<T>()` (or `new Promise((resolve, reject) => ...)`). In `dart:async`, that pattern is a **`Completer<T>`**: you return `completer.future` to the caller and call `completer.complete(result)` or `completer.completeError(e, st)` when ready.{{sidenote:By chaining every `load()`, `save()`, `savePreImportBackup()`, and `writeExportFile()` call onto `_writeQueue = _writeQueue.then(...)`, concurrent operations execute strictly one after another in FIFO order—even if an earlier operation throws an error.}}

### Block 2: Atomic Write-Then-Rename (`_writeAtomically`)

```dart caption="Atomic .tmp write with flush: true followed by POSIX rename"
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
```

- **`await tempFile.writeAsString(formatted, flush: true)`**: Writes 2-space indented JSON (`JsonEncoder.withIndent('  ')`) to `parts_catalog.json.tmp` and flushes OS buffers to disk before renaming.
- **`await tempFile.rename(targetFile.path)`**: On POSIX filesystems (iOS/macOS/Linux), renaming a file within the same directory is an **atomic directory-entry swap**. Readers never observe an empty or half-written `parts_catalog.json`!

### Complete `lib/catalog/file_catalog_persistence.dart` Listing

```dart caption="tutorial/apps/0003-persistence-seam-and-atomic-file-storage/lib/catalog/file_catalog_persistence.dart"
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
```

---

## 3. Verifying Concurrent Atomic Writes (`test/file_catalog_persistence_test.dart`) {#persistence-test}

Just like `Promise.all([...])` in TypeScript, Dart's **`Future.wait([...])`** fires multiple futures concurrently. Look at how `test/file_catalog_persistence_test.dart` verifies that firing two concurrent `persistence.save(...)` calls never leaves a `.tmp` file behind and always commits the second snapshot cleanly:

```dart caption="Concurrent Future.wait atomic save test in test/file_catalog_persistence_test.dart"
      // Enqueue multiple saves concurrently to verify serialized atomic writes
      await Future.wait([
        persistence.save(snapshot.copyWith(parts: [])),
        persistence.save(snapshot),
      ]);

      final liveFile = File('${tempDir.path}/parts_catalog.json');
      final tmpFile = File('${tempDir.path}/parts_catalog.json.tmp');
      expect(await liveFile.exists(), isTrue);
      expect(await tmpFile.exists(), isFalse);
```

---

## 4. Interactive Practice & Verification {#practice}

:::exercise id="ex-0003" title="Interactive Lab: Implementing the Atomic Persistence Queue" badge="Skill Practice • Tight Feedback Loop"
Complete the missing Dart persistence and async tokens below:

```dart
class InMemoryCatalogPersistence {{blank:implements|Use the keyword that fulfills the CatalogPersistence interface without inheriting implementation.|implements|12}} CatalogPersistence {
  // ...
}

// Inside FileCatalogPersistence._enqueue<T>:
Future<T> _enqueue<T>(Future<T> Function() action) {
  final completer = {{blank:Completer<T>()||Completer()|Create the dart:async deferred future controller.|Completer<T>()|15}};
  _writeQueue = _writeQueue.then((_) async {
    try {
      final result = await action();
      completer.{{blank:complete|Resolve the completer with the action's result.|complete|10}}(result);
    } on Object catch (e, st) {
      completer.completeError(e, st);
    }
  });
  return completer.future;
}

// Inside _writeAtomically:
await tempFile.writeAsString(formatted, {{blank:flush: true|Force OS buffers to flush to disk before renaming the temporary file.|flush: true|13}});
await tempFile.rename(targetFile.path);
```

:::prompts
hint: "Classes fulfill interface contracts with 'implements', deferred futures use 'Completer<T>()' and 'completer.complete(result)', and atomic writes flush buffers via 'flush: true'."
success: "Great work! You've mastered Dart interface implementation, Completer queues, and atomic file persistence."
:::
:::

:::quiz id="quiz-0003" title="Retrieval Practice: Interfaces, Completers & Atomic Persistence" badge="3 Questions • Equal-Length Options"
- question: "In Dart, what is the difference between `class B implements A` and `class B extends A`?"
  wrong_hint: "Recall that every Dart class implicitly defines an interface."
  options:
    - letter: "A"
      text: "implements copies all private fields from A whereas extends only copies public static methods."
      correct: false
      explain: "`implements` does not inherit any fields or method bodies from `A`; it treats `A` strictly as an interface contract."
    - letter: "B"
      text: "implements requires B to provide every member of A without inheriting A's method bodies."
      correct: true
      explain: "Correct! `implements` treats `A` as a pure interface (like TypeScript's `implements`), making it ideal for test doubles."
    - letter: "C"
      text: "implements is only allowed on widget classes whereas extends is restricted to data models."
      correct: false
      explain: "Any Dart class can use `extends` or `implements` regardless of whether it is a widget, service, or model."
    - letter: "D"
      text: "implements runs only at runtime in debug mode whereas extends is checked during compilation."
      correct: false
      explain: "Both `implements` and `extends` are statically verified at compile time by the Dart analyzer and compiler."

- question: "Why does `FileCatalogPersistence` write JSON to `parts_catalog.json.tmp` and rename it instead of overwriting `parts_catalog.json` directly?"
  wrong_hint: "Consider what happens if the app is killed mid-write."
  options:
    - letter: "A"
      text: "Dart forbids calling writeAsString directly on any file whose path ends with .json."
      correct: false
      explain: "`File.writeAsString` works on any file path, but overwriting in place risks truncating existing data on crash."
    - letter: "B"
      text: "Writing to a temporary file compresses the JSON payload into binary gzip format."
      correct: false
      explain: "The file is still plain UTF-8 2-space-indented JSON; the `.tmp` suffix is used for atomic replacement."
    - letter: "C"
      text: "Flushing a temporary file then renaming prevents half-written corrupted JSON on sudden crashes."
      correct: true
      explain: "Correct! Writing with `flush: true` to `.tmp` and calling `rename` performs an atomic POSIX directory entry swap."
    - letter: "D"
      text: "Mobile operating systems automatically back up .tmp files to cloud storage every minute."
      correct: false
      explain: "OS cloud backups ignore temporary files; we use `.tmp` strictly as a staging file before renaming."

- question: "What problem does the `_enqueue<T>` `Future` chain in `FileCatalogPersistence` solve during rapid stock adjustments?"
  wrong_hint: "Think about what happens when five `save()` calls are triggered within 200ms."
  options:
    - letter: "A"
      text: "It serializes concurrent file operations sequentially so overlapping saves never race on disk."
      correct: true
      explain: "Correct! Chaining onto `_writeQueue` guarantees every `load` and `save` finishes before the next one touches `.tmp`."
    - letter: "B"
      text: "It spawns a separate background OS thread for every single button tap event."
      correct: false
      explain: "`_enqueue` runs on the same Dart isolate event loop using asynchronous `Future` chaining, not OS threads."
    - letter: "C"
      text: "It throttles user interface frame rendering to thirty frames per second on iOS."
      correct: false
      explain: "Async disk I/O is non-blocking and has no effect on the UI frame rate."
    - letter: "D"
      text: "It caches HTTP responses from the LCSC server inside local browser session storage."
      correct: false
      explain: "`FileCatalogPersistence` manages local catalog JSON files on disk, not HTTP responses."
:::

:::verify id="verify-0003" title="Verification Lab: Run Atomic File Persistence Tests" badge="CLI Gate • Zero Warnings & 100% Green"
Run static analysis and the persistence test suite in `tutorial/apps/0003-persistence-seam-and-atomic-file-storage`:

```bash caption="Terminal verification commands for Lesson 0003"
cd tutorial/apps/0003-persistence-seam-and-atomic-file-storage
flutter analyze
flutter test
```

Expected terminal output:

```text caption="Verified output of flutter analyze && flutter test"
Analyzing 0003-persistence-seam-and-atomic-file-storage...
No issues found!
00:01 +4: All tests passed!
```

- [ ] Reviewed `lib/catalog/catalog_persistence.dart` and `lib/catalog/file_catalog_persistence.dart`.
- [ ] Verified `flutter analyze` reports `No issues found!`.
- [ ] Verified `flutter test` passes `test/file_catalog_persistence_test.dart`, `test/catalog_models_test.dart`, and `test/widget_test.dart` (4 tests total).
:::

:::teacher-prompt
**Up next**: Now that we have immutable Freezed models and an atomic persistence seam, [Lesson 0004: Reactive Catalog State with Riverpod `AsyncNotifier`](0004-reactive-catalog-state-with-riverpod.md) wires them into our reactive `Catalog` store with part normalization, `(Container, Slot)` collision protection, quantity clamping, and all-or-nothing JSON import validation!
:::
