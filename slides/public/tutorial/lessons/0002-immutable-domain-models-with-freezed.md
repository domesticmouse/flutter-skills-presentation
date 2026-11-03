---
title: "Immutable Domain Models with Freezed & JSON Serialization"
page_title: "Lesson 0002 — Immutable Domain Models with Freezed & JSON Serialization"
nav_id: "lesson-0002"
badge: "Lesson 0002 • Freezed & Domain Models"
subtitle: "Replace TypeScript interfaces, object spread ({ ...part }), and JSON.parse with Dart 3 sound null safety, @freezed data classes, copyWith, and build_runner codegen."
card:
  title: "**Immutable Domain Models with Freezed & JSON Serialization**"
  summary: "Model Container, Part, and CatalogSnapshot in lib/catalog/catalog_models.dart using @freezed, json_serializable, computed getters, and the 1-to-1 (Container, Slot) lookup."
---

## Why Plain Dart Classes Aren't Like TypeScript Interfaces {#why-freezed}

In TypeScript, modeling an immutable domain entity takes zero runtime code:

```ts caption="TypeScript interface + object spread in a React codebase"
export interface Part {
  readonly id: string;
  readonly name: string;
  readonly quantity: number;
  readonly containerId?: string | null;
  readonly slot?: string | null;
}

// Cloning with an updated field uses JS object spread:
const updated: Part = { ...part, quantity: part.quantity + 10 };
```

When you move to Dart, two language differences immediately stand out:

1. **Dart is nominally typed and compiles to native machine code**: Classes are real runtime types, not erased compile-time shapes. You cannot write `{ ...part, quantity: 10 }` on a class instance, and `JSON.parse()` returns an untyped `Map<String, dynamic>`, not a `Part`.
2. **Dart `==` defaults to reference identity (like JS `===`)**: Two separate `Part(id: 'p1', name: '10k')` instances are **not** `==` unless the class overrides `operator ==` and `hashCode`.

Rather than hand-writing hundreds of lines of boilerplate `copyWith`, `operator ==`, `hashCode`, `toString()`, and `fromJson`/`toJson` methods, production Flutter apps use **`freezed`** + **`json_serializable`**.{{sidenote:Both `freezed` and `riverpod` were created by Remi Rousselet and are designed to work together: because `@freezed` generates deep structural value equality (`==`), Riverpod providers and tests can compare snapshots and parts by value out of the box.}}

In this lesson, you will build [`lib/catalog/catalog_models.dart`](../reference/GLOSSARY.md) in `./tutorial/apps/0002-immutable-domain-models-with-freezed/` with our three core domain models: **`Container`**, **`Part`**, and **`CatalogSnapshot`**.

:::callout
**Primary Sources for Lesson 0002**: Consult the [Glossary](../reference/GLOSSARY.md), the [React → Flutter Cheat Sheet](../reference/react-to-flutter-cheatsheet.md), and the [official `package:freezed` documentation](https://pub.dev/packages/freezed).
:::

---

## 1. Adding Freezed & JSON Codegen to `pubspec.yaml` {#pubspec}

```mermaid caption="Figure 2.1: How build_runner reads @freezed annotations in catalog_models.dart and emits part files."
flowchart LR
  Src["lib/catalog/catalog_models.dart<br/>(@freezed classes)"] --> Runner["dart run build_runner build"]
  Runner --> FreezedPart["catalog_models.freezed.dart<br/>(copyWith, ==, hashCode, toString)"]
  Runner --> JsonPart["catalog_models.g.dart<br/>(_$PartFromJson / _$PartToJson)"]
```

### Block 1: Updating `pubspec.yaml`

We add two lightweight annotation packages to `dependencies:` and three code generators to `dev_dependencies:`:

```yaml caption="Updated dependencies in tutorial/apps/0002-immutable-domain-models-with-freezed/pubspec.yaml"
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.4.3
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.16.2
  freezed: ^4.0.3
  json_serializable: ^6.15.2
```

- **`freezed_annotation` & `json_annotation`**: Tiny runtime packages containing the `@freezed` and `@Default(...)` annotations.
- **`build_runner`, `freezed`, & `json_serializable`**: Compile-time code generators (only in `dev_dependencies`) that inspect your AST and write `.freezed.dart` and `.g.dart` companion files.

---

## 2. Building `lib/catalog/catalog_models.dart` Block by Block {#catalog-models}

### Block 1: `part` Directives and the `Container` Model

```dart caption="Part directives and @freezed Container class in lib/catalog/catalog_models.dart"
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Container with _$Container {
  const Container._();

  const factory Container({
    required String id,
    required String name,
    String? description,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}
```

Every line in this block teaches a core Dart 3 and Freezed idiom:

- **`part 'catalog_models.freezed.dart';` and `part 'catalog_models.g.dart';`**:
  - In Dart, a **Part File (`part` / `part of`)** splits a single library across multiple physical files so generated code can share the exact same private scope (identifiers starting with `_`).
- **`abstract class Container with _$Container`**:
  - The `with` keyword applies a Dart **mixin** (`_$Container`, generated inside `catalog_models.freezed.dart`) that injects the field getters (`id`, `name`, `description`), `copyWith`, `toJson()`, `operator ==`, and `hashCode`.
- **`const Container._();`**:
  - A private, empty `const` constructor (`ClassName._()`). Whenever a Freezed class defines custom methods or getters, Freezed's generated `_Container` implementation class extends `Container`, which requires `Container` to have a generative constructor (`const Container._()`) for the subclass to call `super._()`.
- **`const factory Container({ required String id, required String name, String? description }) = _Container;`**:
  - A **redirecting factory constructor** that delegates construction to the generated `_Container` class.
  - Notice Dart's **sound null safety**: `String id` and `String name` are guaranteed non-null (`required`), while `String? description` is explicitly nullable and defaults to `null` when omitted.
- **`factory Container.fromJson(Map<String, dynamic> json) => _$ContainerFromJson(json);`**:
  - Wires `json_serializable` so calling `Container.fromJson(map)` validates and constructs a `Container`, and calling `container.toJson()` serializes it back to a `Map<String, dynamic>`.

### Block 2: The `Part` Model (`@Default` & Computed Getters)

Next, we model a workbench **Part** (`10kΩ 0603 1% Resistor`, `NE555P`, etc.) with its electrical **Specs** and computed stock/location getters:

```dart caption="@freezed Part class with @Default values and computed getters"
@freezed
abstract class Part with _$Part {
  const Part._();

  const factory Part({
    required String id,
    required String name,
    @Default(0) int quantity,
    String? lcscCode,
    String? mpn,
    String? manufacturer,
    String? category,
    String? package,
    String? datasheetUrl,
    String? containerId,
    String? slot,
    int? lowStockThreshold,
    String? notes,
    @Default(<String, String>{}) Map<String, String> specs,
  }) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  bool get isLowStock => quantity <= (lowStockThreshold ?? 0);

  bool get isUnassigned => containerId == null;
}
```

- **`@Default(0) int quantity`**: Tells both the Dart constructor and `fromJson` deserializer to default `quantity` to `0` if omitted—so `quantity` is always a non-nullable `int`!
- **`@Default(<String, String>{}) Map<String, String> specs`**: Stores the ordered key-value **Specs** (`'Capacitance': '100nF'`, `'Voltage Rated': '50V'`). Notice that a `const` map literal in Dart is written `<KeyType, ValueType>{}`.
- **`bool get isLowStock => quantity <= (lowStockThreshold ?? 0);`**:
  - In Dart, `Type get propName => ...` defines a **computed getter** (just like `get isLowStock(): boolean` in a TypeScript class).
  - If `lowStockThreshold` is `null`, `lowStockThreshold ?? 0` evaluates to `0`, meaning a part with no custom threshold is still flagged as low stock when its quantity hits `0`.
- **`copyWith` can set nullable fields back to `null`!** Unlike hand-written `copyWith({String? slot}) => Part(slot: slot ?? this.slot)` methods (which cannot distinguish an omitted argument from `slot: null`), Freezed's generated `part.copyWith(containerId: null, slot: null)` cleanly resets nullable fields to `null`.

### Block 3: `CatalogSnapshot` & 1-to-1 `(Container, Slot)` Lookup

Finally, we model `CatalogSnapshot`—the versioned root state object—and its `findOccupyingSlotPart` domain method:

```dart caption="@freezed CatalogSnapshot class with empty factory, exportFileName, and findOccupyingSlotPart"
@freezed
abstract class CatalogSnapshot with _$CatalogSnapshot {
  const CatalogSnapshot._();

  const factory CatalogSnapshot({
    @Default(1) int schemaVersion,
    required DateTime updatedAt,
    @Default(<Container>[]) List<Container> containers,
    @Default(<Part>[]) List<Part> parts,
  }) = _CatalogSnapshot;

  factory CatalogSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CatalogSnapshotFromJson(json);

  factory CatalogSnapshot.empty({DateTime? now}) => CatalogSnapshot(
        schemaVersion: 1,
        updatedAt: (now ?? DateTime.now()).toUtc(),
        containers: const [],
        parts: const [],
      );

  String get exportFileName {
    final dateStr = updatedAt.toUtc().toIso8601String().split('T').first;
    return 'parts-catalog-$dateStr.json';
  }

  Part? findOccupyingSlotPart(
    String? containerId,
    String? slot, {
    String? excludingPartId,
  }) {
    final cleanContainerId = containerId?.trim();
    final cleanSlot = slot?.trim();
    if (cleanContainerId == null ||
        cleanContainerId.isEmpty ||
        cleanSlot == null ||
        cleanSlot.isEmpty) {
      return null;
    }
    final slotLower = cleanSlot.toLowerCase();
    for (final existing in parts) {
      if (existing.id == excludingPartId) continue;
      if (existing.containerId == cleanContainerId &&
          existing.slot != null &&
          existing.slot!.toLowerCase() == slotLower) {
        return existing;
      }
    }
    return null;
  }
}
```

- **`factory CatalogSnapshot.empty({DateTime? now})`**: Creates an empty `schemaVersion: 1` catalog with a UTC timestamp (allowing tests to pass a deterministic `now` if needed).
- **`exportFileName`**: Formats `updatedAt` into `parts-catalog-YYYY-MM-DD.json` using Dart's `$variable` string interpolation (equivalent to TypeScript `` `parts-catalog-${dateStr}.json` ``).
- **`findOccupyingSlotPart(String? containerId, String? slot, {String? excludingPartId})`**:
  - Notice the mixed parameter list: `containerId` and `slot` are positional, while `{String? excludingPartId}` is an optional named parameter!
  - Enforces our [Glossary](../reference/GLOSSARY.md) domain rule: a **Slot** inside a **Container** holds at most one **Part** (compared case-insensitively after trimming), while bulk parts with `slot == null` (or unassigned parts with `containerId == null`) never collide. When editing an existing part, passing `excludingPartId: part.id` prevents the part from colliding with itself.

### Complete `lib/catalog/catalog_models.dart` Listing

```dart caption="tutorial/apps/0002-immutable-domain-models-with-freezed/lib/catalog/catalog_models.dart"
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Container with _$Container {
  const Container._();

  const factory Container({
    required String id,
    required String name,
    String? description,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}

@freezed
abstract class Part with _$Part {
  const Part._();

  const factory Part({
    required String id,
    required String name,
    @Default(0) int quantity,
    String? lcscCode,
    String? mpn,
    String? manufacturer,
    String? category,
    String? package,
    String? datasheetUrl,
    String? containerId,
    String? slot,
    int? lowStockThreshold,
    String? notes,
    @Default(<String, String>{}) Map<String, String> specs,
  }) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  bool get isLowStock => quantity <= (lowStockThreshold ?? 0);

  bool get isUnassigned => containerId == null;
}

@freezed
abstract class CatalogSnapshot with _$CatalogSnapshot {
  const CatalogSnapshot._();

  const factory CatalogSnapshot({
    @Default(1) int schemaVersion,
    required DateTime updatedAt,
    @Default(<Container>[]) List<Container> containers,
    @Default(<Part>[]) List<Part> parts,
  }) = _CatalogSnapshot;

  factory CatalogSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CatalogSnapshotFromJson(json);

  factory CatalogSnapshot.empty({DateTime? now}) => CatalogSnapshot(
        schemaVersion: 1,
        updatedAt: (now ?? DateTime.now()).toUtc(),
        containers: const [],
        parts: const [],
      );

  String get exportFileName {
    final dateStr = updatedAt.toUtc().toIso8601String().split('T').first;
    return 'parts-catalog-$dateStr.json';
  }

  Part? findOccupyingSlotPart(
    String? containerId,
    String? slot, {
    String? excludingPartId,
  }) {
    final cleanContainerId = containerId?.trim();
    final cleanSlot = slot?.trim();
    if (cleanContainerId == null ||
        cleanContainerId.isEmpty ||
        cleanSlot == null ||
        cleanSlot.isEmpty) {
      return null;
    }
    final slotLower = cleanSlot.toLowerCase();
    for (final existing in parts) {
      if (existing.id == excludingPartId) continue;
      if (existing.containerId == cleanContainerId &&
          existing.slot != null &&
          existing.slot!.toLowerCase() == slotLower) {
        return existing;
      }
    }
    return null;
  }
}
```

---

## 3. Unit Testing the Domain Models (`test/catalog_models_test.dart`) {#unit-tests}

Unlike widget tests (`testWidgets`), pure Dart domain logic is tested with `test('...', () { ... })`—identical to Vitest/Jest unit tests.

```dart caption="tutorial/apps/0002-immutable-domain-models-with-freezed/test/catalog_models_test.dart"
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/catalog/catalog_models.dart';

void main() {
  group('Catalog Freezed Domain Models', () {
    test('Part supports value equality, copyWith (including setting nullable fields to null), isLowStock, and JSON round-trip', () {
      const resistor = Part(
        id: 'p-r10k',
        name: '10kΩ 0603 1% Resistor',
        quantity: 8,
        lowStockThreshold: 10,
        containerId: 'c-binder-1',
        slot: 'Page 1',
        specs: {'Resistance': '10kΩ', 'Tolerance': '±1%'},
      );

      expect(resistor.isLowStock, isTrue);
      expect(resistor.isUnassigned, isFalse);

      final restocked = resistor.copyWith(quantity: 50);
      expect(restocked.isLowStock, isFalse);
      expect(restocked.name, '10kΩ 0603 1% Resistor');

      final unassigned = restocked.copyWith(containerId: null, slot: null);
      expect(unassigned.isUnassigned, isTrue);
      expect(unassigned.slot, isNull);

      final roundTripped = Part.fromJson(resistor.toJson());
      expect(roundTripped, equals(resistor));
    });

    test('CatalogSnapshot computes exportFileName and detects case-insensitive (Container, Slot) collisions', () {
      final snapshot = CatalogSnapshot(
        updatedAt: DateTime.utc(2026, 11, 3, 14, 30),
        containers: const [
          Container(id: 'c-1', name: 'SMD Binder #1'),
        ],
        parts: const [
          Part(
            id: 'p-1',
            name: '100nF 0603 Cap',
            containerId: 'c-1',
            slot: 'Page 4',
          ),
        ],
      );

      expect(snapshot.exportFileName, 'parts-catalog-2026-11-03.json');
      expect(
        snapshot.findOccupyingSlotPart('c-1', '  page 4 ')?.id,
        'p-1',
      );
      expect(
        snapshot.findOccupyingSlotPart('c-1', 'page 4', excludingPartId: 'p-1'),
        isNull,
      );
      expect(snapshot.findOccupyingSlotPart('c-1', null), isNull);
    });
  });
}
```

---

## 4. Interactive Practice & Verification {#practice}

:::exercise id="ex-0002" title="Interactive Lab: Authoring a @freezed Model with Null Safety" badge="Skill Practice • Tight Feedback Loop"
Complete the missing Freezed and Dart 3 tokens for `Part` below:

```dart
part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Part {{blank:with|Use the Dart keyword that applies the generated _$Part mixin.|with|6}} _$Part {
  const Part.{{blank:_|Declare the private generative constructor required for custom getters.|_|3}}();

  const factory Part({
    required String id,
    required String name,
    @{{blank:Default(0)|Provide a default integer value of 0 when quantity is omitted.|Default(0)|12}} int quantity,
    String? containerId,
    int? lowStockThreshold,
  }) = _Part;

  bool get isLowStock => quantity <= (lowStockThreshold {{blank:??|Use the null-coalescing operator to fall back to 0.|??|4}} 0);
}
```

:::prompts
hint: "Mixins use the 'with' keyword, private named constructors use '._()', Freezed default values use '@Default(0)', and null-coalescing uses '??'."
success: "Excellent! You can now read and author @freezed data classes with custom computed getters and sound null safety."
:::
:::

:::quiz id="quiz-0002" title="Retrieval Practice: Freezed, Part Files & Null Safety" badge="3 Questions • Equal-Length Options"
- question: "Why do we use `@freezed` classes in Dart instead of plain classes like TypeScript interfaces?"
  wrong_hint: "Compare how JavaScript objects support `{ ...obj }` spread and structural equality in tests versus default Dart classes."
  options:
    - letter: "A"
      text: "Dart classes lack object spread syntax and default to reference equality without codegen."
      correct: true
      explain: "Correct! `@freezed` synthesizes `copyWith` (including nullable resets), deep value `==` / `hashCode`, and `toString()`."
    - letter: "B"
      text: "Dart forbids defining final fields on classes unless the freezed package is installed."
      correct: false
      explain: "Standard Dart classes support `final` fields natively, but they do not auto-generate `copyWith` or value equality."
    - letter: "C"
      text: "Freezed automatically syncs every model instance to a remote cloud database at runtime."
      correct: false
      explain: "Freezed is purely a compile-time code generator for immutable value classes and sealed unions."
    - letter: "D"
      text: "Freezed replaces the Flutter widget tree with native platform UI views on iOS."
      correct: false
      explain: "Freezed operates on data models and has no involvement in how Flutter renders widgets."

- question: "Why must `Part` and `CatalogSnapshot` declare a private `const Part._()` constructor inside their class bodies?"
  wrong_hint: "Think about how the generated `_Part` class inherits custom getters like `isLowStock`."
  options:
    - letter: "A"
      text: "It prevents any external widget or test file from ever calling the factory constructor."
      correct: false
      explain: "External callers still construct instances normally via the public `const factory Part(...)` constructor."
    - letter: "B"
      text: "It allows the generated _Part subclass to inherit custom getters and instance methods cleanly."
      correct: true
      explain: "Correct! When a Freezed class has custom getters or methods, `_Part` extends `Part` and calls `super._()`."
    - letter: "C"
      text: "It instructs the JSON serializer to ignore all null fields when writing disk files."
      correct: false
      explain: "JSON field handling is controlled by `@JsonKey` annotations, not by the private `._()` constructor."
    - letter: "D"
      text: "It registers the model class inside the global Riverpod provider container during app startup."
      correct: false
      explain: "Freezed models are plain immutable Dart value objects and do not self-register with Riverpod."

- question: "How does `CatalogSnapshot.findOccupyingSlotPart` enforce the 1-to-1 `(Container, Slot)` workbench storage rule?"
  wrong_hint: "Check how `cleanContainerId`, `cleanSlot`, and `excludingPartId` are handled in `findOccupyingSlotPart`."
  options:
    - letter: "A"
      text: "It rejects any Part that does not specify both a containerId and slot."
      correct: false
      explain: "Parts with `containerId == null` (unassigned) or `slot == null` (bulk container storage) are valid and return `null`."
    - letter: "B"
      text: "It throws a runtime database exception whenever two parts share a container name."
      correct: false
      explain: "Multiple parts can live in the same `Container` as long as they occupy distinct slots or have `slot == null`."
    - letter: "C"
      text: "It compares containerId and trimmed lowercase slot while ignoring null slots and excludingPartId."
      correct: true
      explain: "Correct! Only non-empty `(containerId, slot)` pairs are checked case-insensitively, skipping `excludingPartId` during edits."
    - letter: "D"
      text: "It sorts all parts alphabetically by manufacturer before overwriting the older slot entry."
      correct: false
      explain: "`findOccupyingSlotPart` is a pure read-only lookup that returns the existing occupying `Part?` without mutating state."
:::

:::verify id="verify-0002" title="Verification Lab: Generate Freezed Part Files & Run Model Tests" badge="CLI Gate • Zero Warnings & 100% Green"
Run static analysis and the unit + widget test suite inside `tutorial/apps/0002-immutable-domain-models-with-freezed`:

```bash caption="Terminal verification commands for Lesson 0002"
cd tutorial/apps/0002-immutable-domain-models-with-freezed
flutter analyze
flutter test
```

Expected terminal output:

```text caption="Verified output of flutter analyze && flutter test"
Analyzing 0002-immutable-domain-models-with-freezed...
No issues found!
00:01 +3: All tests passed!
```

- [ ] Inspected `lib/catalog/catalog_models.dart` and its generated companion files (`catalog_models.freezed.dart` and `catalog_models.g.dart`).
- [ ] Verified `flutter analyze` passes with `No issues found!`.
- [ ] Verified `flutter test` passes both `test/catalog_models_test.dart` (2 unit tests) and `test/widget_test.dart` (1 widget test).
:::

:::teacher-prompt
**Up next**: In [Lesson 0003: Persistence Seam & Atomic Local File Storage](0003-persistence-seam-and-atomic-file-storage.md), we'll design `CatalogPersistence`, an in-memory test double (`InMemoryCatalogPersistence`), and `FileCatalogPersistence` with a serialized write queue and atomic `.tmp` file rename!
:::
