---
title: "Reactive Catalog State with Riverpod AsyncNotifier"
page_title: "Lesson 0004 — Reactive Catalog State with Riverpod AsyncNotifier"
nav_id: "lesson-0004"
badge: "Lesson 0004 • Riverpod AsyncNotifier"
subtitle: "Combine TanStack Query's async lifecycle and Zustand/Redux's immutable actions into a single @Riverpod AsyncNotifier (lib/catalog/catalog_provider.dart) and connect it to WorkbenchScreen via ConsumerWidget."
card:
  title: "**Reactive Catalog State with Riverpod AsyncNotifier**"
  summary: "Build the Catalog AsyncNotifier with upsertPart, (Container, Slot) uniqueness, quantity clamping, cascading container deletion, all-or-nothing JSON import validation, and ConsumerWidget UI binding."
---

## How Riverpod Unifies TanStack Query and Zustand/Redux {#why-riverpod}

In a modern React application, you typically split state management across two different mental models:

1. **Async / I/O state (`useQuery` / TanStack Query)**: Manages loading spinners, error states, and async resolution (`{ data, isLoading, error }`).
2. **Client store actions (Zustand / Redux Toolkit)**: Holds synchronous domain mutations (`upsertPart`, `adjustQuantity`, `deleteContainer`).

In Flutter with **Riverpod**, **`AsyncNotifier`** unifies both! A class annotated with `@Riverpod(keepAlive: true)` defines an `async` `build()` method that loads initial state (returning a `Future<CatalogSnapshot>`), automatically wraps the state in a sealed **`AsyncValue<CatalogSnapshot>`** (`AsyncLoading`, `AsyncData`, `AsyncError`), and exposes typed mutation methods right on the notifier (`ref.read(catalogProvider.notifier).adjustQuantity(...)`).

```mermaid caption="Figure 4.1: How Riverpod's catalogPersistenceProvider and Catalog AsyncNotifier wire persistence to ConsumerWidgets and headless tests."
flowchart LR
  Persist["catalogPersistenceProvider<br/>(FileCatalogPersistence or InMemory override)"] --> Build["Catalog.build()<br/>(Future&lt;CatalogSnapshot&gt;)"]
  Build --> State["state: AsyncValue&lt;CatalogSnapshot&gt;<br/>(AsyncLoading | AsyncData | AsyncError)"]
  Mut["Mutations: upsertPart, adjustQuantity,<br/>deleteContainer, importSnapshot"] --> Commit["_commit(next)<br/>(await persistence.save → state = AsyncData)"]
  Commit --> State
  State --> UI["ConsumerWidget / ProviderContainer<br/>(ref.watch(catalogProvider))"]
```

:::callout
**Primary Sources for Lesson 0004**: Keep the [Glossary](../reference/GLOSSARY.md), the [Verification & Testing Reference](../reference/verification-and-testing.md), and the [Riverpod Official Documentation](https://riverpod.dev/docs/introduction/getting_started) open alongside this lesson.
:::

---

## 1. Building `lib/catalog/catalog_provider.dart` Block by Block {#catalog-provider}

### Block 1: Domain Exceptions & `catalogPersistenceProvider`

First, we define typed domain exceptions for `(Container, Slot)` collisions and invalid JSON backups, plus the `catalogPersistence` provider seam:

```dart caption="Domain exceptions and @Riverpod catalogPersistenceProvider in lib/catalog/catalog_provider.dart"
import 'dart:convert';
import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'catalog_models.dart';
import 'catalog_persistence.dart';
import 'file_catalog_persistence.dart';

part 'catalog_provider.g.dart';

class SlotOccupiedException implements Exception {
  const SlotOccupiedException({
    required this.containerId,
    required this.slot,
    required this.occupyingPart,
  });

  final String containerId;
  final String slot;
  final Part occupyingPart;

  @override
  String toString() =>
      'Slot "$slot" is already occupied by "${occupyingPart.name}".';
}

class CatalogImportValidationException implements Exception {
  const CatalogImportValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
CatalogPersistence catalogPersistence(Ref ref) {
  return FileCatalogPersistence();
}
```

- **`@Riverpod(keepAlive: true)`**:
  - By default, `@riverpod` enables `autoDispose`: if no widget is currently watching a provider, Riverpod disposes its state to free memory (similar to unmounting a component in React).
  - For our application-wide catalog store and persistence service, `keepAlive: true` tells Riverpod to keep the cached catalog alive across screen and modal sheet transitions.
  - `riverpod_generator` reads `CatalogPersistence catalogPersistence(Ref ref)` and generates **`catalogPersistenceProvider`** inside `catalog_provider.g.dart`.

### Block 2: `Catalog` `AsyncNotifier`, `upsertPart`, and `(Container, Slot)` Enforcement

```dart caption="Catalog AsyncNotifier build() and upsertPart() with 1-to-1 slot conflict checking"
@Riverpod(keepAlive: true)
class Catalog extends _$Catalog {
  @override
  Future<CatalogSnapshot> build() async {
    final persistence = ref.watch(catalogPersistenceProvider);
    return persistence.load();
  }

  Future<void> upsertPart(Part part) async {
    final current = await future;
    final normalized = _normalizePart(part);
    if (normalized.containerId != null &&
        !current.containers.any((c) => c.id == normalized.containerId)) {
      throw ArgumentError(
        'Unknown containerId "${normalized.containerId}".',
      );
    }
    final occupying = current.findOccupyingSlotPart(
      normalized.containerId,
      normalized.slot,
      excludingPartId: normalized.id,
    );
    if (occupying != null) {
      throw SlotOccupiedException(
        containerId: normalized.containerId!,
        slot: normalized.slot!,
        occupyingPart: occupying,
      );
    }
    final updatedParts = [...current.parts];
    final existingIdx = updatedParts.indexWhere((p) => p.id == normalized.id);
    if (existingIdx >= 0) {
      updatedParts[existingIdx] = normalized;
    } else {
      updatedParts.add(normalized);
    }
    await _commit(current.copyWith(parts: updatedParts));
  }
```

Unpacking how `AsyncNotifier` works compared to React hooks:

- **`class Catalog extends _$Catalog`**: Because `build()` returns `Future<CatalogSnapshot>`, `riverpod_generator` makes `_$Catalog` an **`AsyncNotifier<CatalogSnapshot>`** and exports **`catalogProvider`**.
- **`final current = await future;`**: Inside an `AsyncNotifier`, the `future` getter awaits the completion of `build()` (if it is still loading) and returns the unwrapped `CatalogSnapshot`.
- **`final updatedParts = [...current.parts];`**: Just like JavaScript array spread (`[...current.parts]`), Dart supports the spread operator `...` inside list, set, and map literals to shallow-clone a collection before mutating or appending!
- **`await _commit(current.copyWith(parts: updatedParts));`**: Stamps `updatedAt` in UTC, persists atomically via `catalogPersistenceProvider`, and updates `state = AsyncData(stamped)`.

### Block 3: Container Management, Cascading Unassignment & Quantity Clamping

```dart caption="Container CRUD with cascading part unassignment and clamped stock adjustments"
  Future<void> upsertContainer(Container container) async {
    final current = await future;
    final name = container.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Container name is required.');
    }
    final normalized = container.copyWith(
      name: name,
      description: _nullIfEmpty(container.description),
    );
    final updatedContainers = [...current.containers];
    final existingIdx =
        updatedContainers.indexWhere((c) => c.id == normalized.id);
    if (existingIdx >= 0) {
      updatedContainers[existingIdx] = normalized;
    } else {
      updatedContainers.add(normalized);
    }
    await _commit(current.copyWith(containers: updatedContainers));
  }

  Future<void> deleteContainer(String containerId) async {
    final current = await future;
    final updatedContainers =
        current.containers.where((c) => c.id != containerId).toList();
    final updatedParts = current.parts.map((part) {
      if (part.containerId == containerId) {
        return part.copyWith(containerId: null, slot: null);
      }
      return part;
    }).toList();
    await _commit(
      current.copyWith(
        containers: updatedContainers,
        parts: updatedParts,
      ),
    );
  }

  Future<void> adjustQuantity(String partId, int delta) async {
    await _updatePartQuantity(partId, (currentQty) => currentQty + delta);
  }

  Future<void> setQuantity(String partId, int exactQuantity) async {
    await _updatePartQuantity(partId, (_) => exactQuantity);
  }

  Future<void> _updatePartQuantity(
    String partId,
    int Function(int currentQty) computeNext,
  ) async {
    final current = await future;
    final idx = current.parts.indexWhere((p) => p.id == partId);
    if (idx < 0) return;
    final part = current.parts[idx];
    final nextQty = math.max(0, computeNext(part.quantity));
    final updatedParts = [...current.parts];
    updatedParts[idx] = part.copyWith(quantity: nextQty);
    await _commit(current.copyWith(parts: updatedParts));
  }
```

- **Lazy `Iterable` vs. `List` (`.where(...).toList()` and `.map(...).toList()`)**:{{sidenote:In JavaScript, `array.filter(...)` and `array.map(...)` immediately allocate and return a new `Array`. In Dart, `.where(...)` and `.map(...)` return a lazy `Iterable<T>`—you call `.toList()` at the end of the pipeline to materialize a `List<T>`.}}
- **Cascading container deletion**: Deleting a **Container** never deletes your **Parts**; it atomically resets `containerId: null, slot: null` on any part stored in that container so those parts move safely back to `Unassigned (Loose / Inbox)`.
- **Clamping at zero (`math.max(0, ...)`)**: Whether you tap `-10` on a resistor with `quantity: 5` or call `setQuantity('p-1', -5)`, `_updatePartQuantity` clamps the resulting quantity to `>= 0`.

### Block 4: Normalization & All-or-Nothing JSON Import Validation

```dart caption="LCSC normalization (Cxxxxxx), part field cleanup, and _commit"
  static String? normalizeLcscCodeOrNull(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final upper = trimmed.toUpperCase();
    final withPrefix = upper.startsWith('C') ? upper : 'C$upper';
    return RegExp(r'^C\d+$').hasMatch(withPrefix) ? withPrefix : null;
  }

  Future<void> _commit(CatalogSnapshot next) async {
    final stamped = next.copyWith(updatedAt: DateTime.now().toUtc());
    final persistence = ref.read(catalogPersistenceProvider);
    await persistence.save(stamped);
    state = AsyncData(stamped);
  }
```

- **`normalizeLcscCodeOrNull`**: Accepts `'14663'`, `'c14663'`, or `' C14663 '` and normalizes it to `'C14663'` (or returns `null` if it doesn't match `^C\d+$`).
- **All-or-nothing `validateCatalogJson(String rawJson)`**: Parses and validates incoming JSON backups before touching live state—checking `schemaVersion == 1`, ISO-8601 `updatedAt`, unique container and part IDs, non-negative quantities, valid `containerId` references, and zero duplicate `(containerId, slot)` pairs. Notice how it uses a **Dart 3 anonymous Record type** `final occupiedSlots = <String, ({String slot, String partName})>{};`—equivalent to an inline TypeScript object type `{ slot: string; partName: string }` without needing to declare a class!

---

## 2. Connecting `WorkbenchScreen` via `ConsumerWidget` (`lib/main.dart`) {#consumer-widget}

In React, a component subscribes to store state by calling a hook like `const catalog = useSelector(...)` or `useQuery(...)`. In Flutter with Riverpod, you change `extends StatelessWidget` to **`extends ConsumerWidget`**, which adds `WidgetRef ref` as the second parameter to `build(BuildContext context, WidgetRef ref)`:

```dart caption="Upgrading WorkbenchScreen to ConsumerWidget in lib/main.dart"
class WorkbenchScreen extends ConsumerWidget {
  const WorkbenchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCatalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electronics Parts Tracker'),
      ),
      body: Center(
        child: switch (asyncCatalog) {
          AsyncData(:final value) => Text(
              'Workbench Ready — ${value.parts.length} parts cataloged',
            ),
          AsyncError(:final error) => Text('Error loading catalog: $error'),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}
```

- **`final asyncCatalog = ref.watch(catalogProvider);`**: Subscribes this widget's `Element` to `catalogProvider`. Whenever `Catalog` assigns a new `state = AsyncData(stamped)`, only widgets watching `catalogProvider` rebuild!
- **Dart 3 `switch` expression with pattern destructuring**:
  - `switch (asyncCatalog) { ... }` is an **expression** that returns a `Widget` directly (unlike JavaScript's statement-only `switch`).
  - `AsyncData(:final value)` destructures the `value` getter (`CatalogSnapshot`) out of `AsyncData`—equivalent to `const { value } = asyncCatalog` in TypeScript!

---

## 3. Interactive Practice & Verification {#practice}

:::exercise id="ex-0004" title="Interactive Lab: Wiring Riverpod AsyncNotifier & ConsumerWidget" badge="Skill Practice • Tight Feedback Loop"
Fill in the missing Riverpod and Dart 3 tokens below:

```dart
@Riverpod({{blank:keepAlive: true|Prevent Riverpod from auto-disposing the catalog state between screens.|keepAlive: true|17}})
class Catalog extends _$Catalog {
  @override
  Future<CatalogSnapshot> build() async {
    final persistence = ref.{{blank:watch|Subscribe to catalogPersistenceProvider inside build().|watch|8}}(catalogPersistenceProvider);
    return persistence.load();
  }

  Future<void> _commit(CatalogSnapshot next) async {
    final stamped = next.copyWith(updatedAt: DateTime.now().toUtc());
    final persistence = ref.read(catalogPersistenceProvider);
    await persistence.save(stamped);
    state = {{blank:AsyncData(stamped)||AsyncData<CatalogSnapshot>(stamped)|Wrap the persisted CatalogSnapshot in Riverpod's data state.|AsyncData(stamped)|20}};
  }
}

class WorkbenchScreen extends {{blank:ConsumerWidget|Extend Riverpod's stateless widget subclass that provides WidgetRef.|ConsumerWidget|16}} {
  const WorkbenchScreen({super.key});

  @override
  Widget build(BuildContext context, {{blank:WidgetRef|Specify the Riverpod reference parameter type for ConsumerWidget.build.|WidgetRef|11}} ref) {
    final asyncCatalog = ref.watch(catalogProvider);
    // ...
  }
}
```

:::prompts
hint: "Keep global providers alive with 'keepAlive: true', subscribe inside build() with 'ref.watch', wrap resolved state in 'AsyncData(stamped)', and use 'ConsumerWidget' with 'WidgetRef ref'."
success: "Awesome! You've connected Riverpod's AsyncNotifier lifecycle to a reactive ConsumerWidget."
:::
:::

:::quiz id="quiz-0004" title="Retrieval Practice: Riverpod AsyncNotifier, Immutability & Store Seams" badge="3 Questions • Equal-Length Options"
- question: "How does a Riverpod `AsyncNotifier` like `class Catalog extends _$Catalog` compare to React state management?"
  wrong_hint: "Think about how `AsyncNotifier` handles both initial async loading and subsequent state mutations."
  options:
    - letter: "A"
      text: "It combines async query loading with reducer actions inside an isolated, testable provider container."
      correct: true
      explain: "Correct! `AsyncNotifier` unifies async initialization (`build()`) and mutation methods inside `ProviderScope` / `ProviderContainer`."
    - letter: "B"
      text: "It stores mutable state inside a specific DOM node that unmounts during route changes."
      correct: false
      explain: "Riverpod providers live inside `ProviderScope` outside individual widget subtrees, and `@Riverpod(keepAlive: true)` persists across routes."
    - letter: "C"
      text: "It requires wrapping every individual component in a separate nested Context.Consumer render prop callback."
      correct: false
      explain: "Only a single root `ProviderScope` is needed; any descendant `ConsumerWidget` watches providers directly via `ref.watch`."
    - letter: "D"
      text: "It forces the entire application widget tree to rebuild from scratch on every mutation."
      correct: false
      explain: "Only the specific `ConsumerWidget` elements calling `ref.watch(catalogProvider)` rebuild when `state` changes."

- question: "What happens inside `Catalog.deleteContainer(String containerId)` when a user deletes a `Container` that holds parts?"
  wrong_hint: "Check how `updatedParts` is computed inside `deleteContainer`."
  options:
    - letter: "A"
      text: "It permanently deletes every Part stored inside that Container from the catalog file."
      correct: false
      explain: "Deleting a storage container never destroys part inventory records; parts are kept in the catalog."
    - letter: "B"
      text: "It throws a SlotOccupiedException and refuses to remove the Container until emptied manually."
      correct: false
      explain: "`SlotOccupiedException` is only thrown when assigning two parts to the same `(Container, Slot)`."
    - letter: "C"
      text: "It removes the Container and resets matching parts' containerId and slot to null."
      correct: true
      explain: "Correct! Any part whose `containerId` matches the deleted container has both `containerId` and `slot` reset to `null` (unassigned)."
    - letter: "D"
      text: "It moves all affected parts into the first alphabetical Container in the list."
      correct: false
      explain: "Unassigned parts are placed in the `Unassigned (Loose / Inbox)` bucket (`containerId: null`), not moved into another container."

- question: "Why does `Catalog._commit(CatalogSnapshot next)` update `state = AsyncData(stamped)` only after `await persistence.save(stamped)` completes?"
  wrong_hint: "Consider what happens if `persistence.save` fails or is awaited by a caller."
  options:
    - letter: "A"
      text: "Dart forbids assigning to state before at least one await expression has executed."
      correct: false
      explain: "Dart allows synchronous `state = ...` assignments at any point inside a notifier method."
    - letter: "B"
      text: "It guarantees UI subscribers only observe catalog changes that have been durably persisted."
      correct: true
      explain: "Correct! Awaiting `persistence.save(stamped)` first ensures memory state and disk state never diverge."
    - letter: "C"
      text: "Riverpod automatically deletes the disk file whenever AsyncData is assigned before save completes."
      correct: false
      explain: "Riverpod has no built-in knowledge of disk files; persistence is handled through our `catalogPersistenceProvider`."
    - letter: "D"
      text: "Assigning AsyncData first would convert the CatalogSnapshot back into a mutable JSON map."
      correct: false
      explain: "`AsyncData` simply wraps the immutable `CatalogSnapshot` instance without altering its type."
:::

:::verify id="verify-0004" title="Verification Lab: Run the Riverpod Catalog Store Test Suite" badge="CLI Gate • Zero Warnings & 100% Green"
Run static analysis and the test suite in `tutorial/apps/0004-reactive-catalog-state-with-riverpod`:

```bash caption="Terminal verification commands for Lesson 0004"
cd tutorial/apps/0004-reactive-catalog-state-with-riverpod
flutter analyze
flutter test
```

Expected terminal output:

```text caption="Verified output of flutter analyze && flutter test"
Analyzing 0004-reactive-catalog-state-with-riverpod...
No issues found!
00:01 +8: All tests passed!
```

- [ ] Inspected `lib/catalog/catalog_provider.dart` and traced `upsertPart`, `deleteContainer`, `adjustQuantity`, and `validateCatalogJson`.
- [ ] Verified `flutter analyze` reports `No issues found!`.
- [ ] Verified `flutter test` passes all 8 tests (`catalog_store_test.dart`, `file_catalog_persistence_test.dart`, `catalog_models_test.dart`, and `widget_test.dart`).
:::

:::teacher-prompt
**Up next**: In [Lesson 0005: Engineering Unit Search Engine & Derived Filter Providers](0005-engineering-unit-search-and-filter-providers.md), we'll build `PartSearchEngine` (`0.1uF == 100nF`, `4k7 == 4.7kΩ`, 3-tier ranking, natural slot sorting) and our derived `filteredWorkbenchViewProvider` selector using Dart 3 `@freezed sealed class` pattern matching!
:::
