---
title: "Engineering Unit Search Engine & Derived Filter Providers"
page_title: "Lesson 0005 — Engineering Unit Search Engine & Derived Filter Providers"
nav_id: "lesson-0005"
badge: "Lesson 0005 • Unit Search & Derived Providers"
subtitle: "Build PartSearchEngine (0.1uF == 100nF, 4k7 == 4.7kΩ, 3-tier ranking, natural slot sorting) and compose derived Riverpod selectors with Dart 3 @freezed sealed classes and pattern matching."
card:
  title: "**Engineering Unit Search Engine & Derived Filter Providers**"
  summary: "Implement PartSearchEngine (lib/search/part_search_engine.dart) and reactive workbench filter providers (lib/search/workbench_filter_provider.dart) with @freezed sealed class pattern matching."
---

## Why Electronics Search Needs More Than `.includes()` {#why-unit-search}

When you're at a soldering workbench looking for a decoupling capacitor or pull-up resistor, your schematic might say **`0.1uF`** or **`4k7`**, while your catalog entry from LCSC is named **`100nF 50V X7R 0603 Capacitor`** (`C14663`) or **`4.7kΩ ±1% 0603 Resistor`** (`C23162`), or uses Greek Unicode characters like **`10µF`** (`U+00B5`) or **`10μF`** (`U+03BC`).

A naive `part.name.toLowerCase().includes(query)` check in JavaScript fails on all of these! Conversely, an overly aggressive parser that expands bare 3-digit EIA codes like `"104"` into `100nF` and `100kΩ` will produce noisy false positives whenever a user searches for an MPN substring or drawer number.

In this lesson, we build two tightly focused modules in `./tutorial/apps/0005-engineering-unit-search-and-filter-providers/`:

1. **`PartSearchEngine` (`lib/search/part_search_engine.dart`)**: Pure Dart unit normalization (`EngineeringDimension`, `EngineeringValue`), EE-infix parsing (`4k7`, `3v3`, `2n2`), Unicode folding (`µ`/`μ` → `u`, `Ω`/`ohm` → `r`), 3-tier relevance ranking, and natural alphanumeric slot sorting (`Page 2` before `Page 10`).
2. **`workbench_filter_provider.dart` (`lib/search/workbench_filter_provider.dart`)**: A Dart 3 `@freezed sealed class WorkbenchFacet` (our discriminated union for filter chips) and the derived `@riverpod FilteredWorkbenchView filteredWorkbenchView(Ref ref)` provider (Riverpod's dependency-tracked equivalent of `useMemo` / Reselect).

:::callout
**Primary Sources for Lesson 0005**: Refer to the [Glossary](../reference/GLOSSARY.md), the [React → Flutter Cheat Sheet](../reference/react-to-flutter-cheatsheet.md), and the [Dart 3 Patterns & Switch Expressions documentation](https://dart.dev/language/patterns).
:::

---

## 1. Building `PartSearchEngine` (`lib/search/part_search_engine.dart`) {#search-engine}

```mermaid caption="Figure 5.1: Multi-token AND evaluation and 3-tier ranking in PartSearchEngine."
flowchart TD
  Query["Search Query: e.g. '0.1uF 50V' or '4700R'"] --> Split["Split into whitespace tokens<br/>(All tokens must match — AND semantics)"]
  Split --> T1["Tier 1: Exact prefix match on<br/>lcscCode (with or without 'C') or mpn"]
  T1 -->|No match| T2["Tier 2: Folded substring OR EngineeringValue<br/>equivalence in Part.name or Specs"]
  T2 -->|No match| T3["Tier 3: Folded substring in containerName,<br/>slot, package, category, manufacturer, or notes"]
  T3 -->|No match| Reject["Token unmatched → Part excluded"]
```

### Block 1: `EngineeringDimension` & `EngineeringValue`

```dart caption="EngineeringDimension enum and tolerance-aware EngineeringValue in lib/search/part_search_engine.dart"
enum EngineeringDimension {
  resistance,
  capacitance,
  inductance,
  voltage,
  current,
  power,
  frequency,
  dimensionlessSi,
}

class EngineeringValue {
  const EngineeringValue(this.dimension, this.baseValue);

  final EngineeringDimension dimension;
  final double baseValue;

  bool matches(EngineeringValue other) {
    final dimCompatible = _dimensionsCompatible(dimension, other.dimension);
    if (!dimCompatible) return false;

    final maxAbs = math.max(baseValue.abs(), other.baseValue.abs());
    if (maxAbs == 0) return baseValue == other.baseValue;
    return (baseValue - other.baseValue).abs() <= 1e-6 * maxAbs;
  }
```

- **Why `1e-6 * maxAbs` relative tolerance?** In IEEE-754 floating-point arithmetic, `0.1 * 1e-6` (`0.1uF`) and `100 * 1e-9` (`100nF`) can differ by `1e-23` due to binary representation. Comparing within `1e-6` relative tolerance matches `0.1uF`, `100nF`, and `100000pF` reliably (`baseValue == 1.0e-7` Farads).
- **Why `dimensionlessSi`?** When an engineer types a prefix-only shorthand like `"100n"`, `"4.7k"`, or `"4u7"` without a trailing `F`, `Ω`, or `H`, `_dimensionsCompatible` allows `dimensionlessSi` to match passive RLC dimensions (`resistance`, `capacitance`, `inductance`) of the same base magnitude without falsely matching `voltage`, `current`, or `power`.

### Block 2: Parsing EE-Infix (`4k7`, `3v3`) vs. Standard SI (`0.1uF`, `100nF`)

```dart caption="parseEngineeringToken handling EE-infix notation and rejecting bare integers like '104'"
    // 1. Check EE-infix notation: e.g. 4k7, 4K7, 4r7, 3v3, 2n2, 4u7, 1M5, 4k7R, 2n2F
    final infixMatch = RegExp(
      r'^(\d+)([pPnNuUmMkKgGrRvVfFhH])(\d+)([rRfFhHvVaAwW]|[hH][zZ])?$',
    ).firstMatch(normalizedRaw);
    if (infixMatch != null) {
      final intPart = infixMatch.group(1)!;
      final marker = infixMatch.group(2)!;
      final fracPart = infixMatch.group(3)!;
      final trailingUnit = infixMatch.group(4)?.toLowerCase();

      final mantissa = double.tryParse('$intPart.$fracPart');
      if (mantissa == null) return null;
      // ... resolves marker ('r' -> resistance, 'v' -> voltage, 'k' -> 1e3, etc.)
    }

    // 2. Check standard numeric + optional SI prefix + optional unit suffix:
    // Must have AT LEAST a prefix OR a unit suffix (bare numbers like "104" are rejected!).
    final stdMatch = RegExp(
      r'^(\d+(?:\.\d+)?)([pPnNuUmMkKgG])?([hH][zZ]|[rRfFhHvVaAwW])?$',
    ).firstMatch(normalizedRaw);
    if (stdMatch != null) {
      final numStr = stdMatch.group(1)!;
      final prefix = stdMatch.group(2);
      final unit = stdMatch.group(3);
      if (prefix == null && unit == null) {
        return null;
      }
      // ...
    }
```

- **Raw strings (`r'...'`)**: Prefixing a Dart string literal with `r` creates a **raw string** where backslashes `\d`, `\s`, `\b` are not interpreted as string escapes—so regular expressions look just like JS `/^(\d+).../` literals without double-escaping `\\d`!
- **Case-sensitive `'M'` (`1e6` Mega) vs. `'m'` (`1e-3` milli)**: Notice that SI prefixes are case-insensitive (`k`/`K`, `u`/`U`, `n`/`N`) *except* `'M'` vs. `'m'` (`1MΩ` = $10^6\,\Omega$, `10mΩ` = $10^{-2}\,\Omega$, while `mhz` is treated as $10^6\,\text{Hz}$).
- **Rejecting bare integers (`if (prefix == null && unit == null) return null;`)**: Ensures `"104"` only matches literal substrings (like MPN `CL10B104KB8NNNC`) and never hallucinates `100nF` or `100kΩ`.

{{widget:unit-search-simulator}}

### Block 3: Natural Alphanumeric Slot Sorting (`compareNaturalSlot`)

In `By Container` mode, slots like `"Page 2"` and `"Page 10"` (or `"A2"` and `"A10"`) should sort in human numerical order (`Page 2` before `Page 10`), with `null`/empty bulk slots placed at the bottom of the container:

```dart caption="Natural alphanumeric slot comparator in PartSearchEngine"
  static int compareNaturalSlot(String? a, String? b) {
    final aClean = a?.trim() ?? '';
    final bClean = b?.trim() ?? '';
    if (aClean.isEmpty && bClean.isEmpty) return 0;
    if (aClean.isEmpty) return 1;
    if (bClean.isEmpty) return -1;

    final aChunks = _splitAlphaNumericChunks(aClean.toLowerCase());
    final bChunks = _splitAlphaNumericChunks(bClean.toLowerCase());
    final len = math.min(aChunks.length, bChunks.length);
    for (var i = 0; i < len; i++) {
      final ca = aChunks[i];
      final cb = bChunks[i];
      final aNum = int.tryParse(ca);
      final bNum = int.tryParse(cb);
      final int cmp;
      if (aNum != null && bNum != null) {
        cmp = aNum.compareTo(bNum);
      } else {
        cmp = ca.compareTo(cb);
      }
      if (cmp != 0) return cmp;
    }
    return aChunks.length.compareTo(bChunks.length);
  }
```

---

## 2. Derived Filter Providers & Sealed Classes (`lib/search/workbench_filter_provider.dart`) {#filter-provider}

### Block 1: Discriminated Unions in Dart 3 (`@freezed sealed class WorkbenchFacet`)

In TypeScript, you model filter chip state as a discriminated union:

```ts caption="TypeScript discriminated union for filter chips"
type WorkbenchFacet =
  | { readonly kind: 'all' }
  | { readonly kind: 'lowStock' }
  | { readonly kind: 'unassigned' }
  | { readonly kind: 'category'; readonly category: string };
```

In Dart 3 + Freezed, you write a **`@freezed sealed class`**:

```dart caption="@freezed sealed class WorkbenchFacet in lib/search/workbench_filter_provider.dart"
@freezed
sealed class WorkbenchFacet with _$WorkbenchFacet {
  const factory WorkbenchFacet.all() = WorkbenchFacetAll;
  const factory WorkbenchFacet.lowStock() = WorkbenchFacetLowStock;
  const factory WorkbenchFacet.unassigned() = WorkbenchFacetUnassigned;
  const factory WorkbenchFacet.category(String category) =
      WorkbenchFacetCategory;
}
```

And look at how you pattern-match on `WorkbenchFacet` inside `filteredWorkbenchView`:

```dart caption="Exhaustive Dart 3 switch expression with pattern destructuring and 'when' guard"
  // If the selected category facet no longer exists in the catalog, treat as All
  final effectiveFacet = switch (selectedFacet) {
    WorkbenchFacetCategory(:final category)
        when !availableCategoriesSet.any(
          (c) => c.toLowerCase() == category.toLowerCase(),
        ) =>
      const WorkbenchFacet.all(),
    _ => selectedFacet,
  };

  // Inside the parts loop:
  final matchesFacet = switch (effectiveFacet) {
    WorkbenchFacetAll() => true,
    WorkbenchFacetLowStock() => part.isLowStock,
    WorkbenchFacetUnassigned() => part.isUnassigned,
    WorkbenchFacetCategory(:final category) =>
      part.category != null &&
          part.category!.toLowerCase() == category.toLowerCase(),
  };
```

- **Exhaustiveness checking**: Because `WorkbenchFacet` is marked **`sealed`**, the Dart compiler knows every possible subtype (`WorkbenchFacetAll`, `WorkbenchFacetLowStock`, `WorkbenchFacetUnassigned`, `WorkbenchFacetCategory`). If you ever add a 5th facet constructor and forget to handle it in `switch (effectiveFacet)`, `flutter analyze` fails at compile time!
- **`WorkbenchFacetCategory(:final category) when ...`**: Extracts the `category` property and applies a boolean `when` guard clause in a single declarative pattern.

### Block 2: Derived Provider (`filteredWorkbenchView` vs. React's `useMemo`)

```dart caption="Derived filteredWorkbenchView provider combining catalogProvider, searchQueryProvider, and selectedFacetProvider"
@riverpod
FilteredWorkbenchView filteredWorkbenchView(Ref ref) {
  final asyncCatalog = ref.watch(catalogProvider);
  final snapshot = asyncCatalog.value ?? CatalogSnapshot.empty();
  final query = ref.watch(searchQueryProvider);
  final selectedFacet = ref.watch(selectedFacetProvider);
  // ... computes flatParts, containerGroups, availableCategories, and counts
```

- **No manual dependency arrays!**{{sidenote:In React, `useMemo(() => filterParts(parts, query, facet), [parts, query, facet])` is prone to stale-closure bugs if a dependency is omitted. In Riverpod, `ref.watch(...)` dynamically tracks every upstream provider read during execution and caches the `FilteredWorkbenchView` until one of those watched providers changes.}}
- **Dart's Cascade Operator (`..sort(...)`)**:
  - Look at lines 114–115 of `workbench_filter_provider.dart`:
    ```dart
    final availableCategories = availableCategoriesSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    ```
  - In JavaScript, `Array.prototype.sort()` returns the sorted array, whereas in Dart, `List.sort()` returns `void` (because it sorts in place). The **cascade operator `..`** invokes `.sort(...)` on the newly created `List` and returns the `List` itself!

---

## 3. Interactive Practice & Verification {#practice}

:::exercise id="ex-0005" title="Interactive Lab: Dart 3 Sealed Classes, Cascades & Derived Providers" badge="Skill Practice • Tight Feedback Loop"
Complete the missing Dart 3 pattern matching, cascade, and Riverpod tokens below:

```dart
@freezed
{{blank:sealed|Mark WorkbenchFacet so the compiler enforces exhaustive switch expressions.|sealed|8}} class WorkbenchFacet with _$WorkbenchFacet {
  const factory WorkbenchFacet.all() = WorkbenchFacetAll;
  const factory WorkbenchFacet.lowStock() = WorkbenchFacetLowStock;
  const factory WorkbenchFacet.unassigned() = WorkbenchFacetUnassigned;
  const factory WorkbenchFacet.category(String category) = WorkbenchFacetCategory;
}

// Exhaustive switch expression with pattern destructuring:
final matchesFacet = switch (effectiveFacet) {
  WorkbenchFacetAll() => true,
  WorkbenchFacetLowStock() => part.isLowStock,
  WorkbenchFacetUnassigned() => part.isUnassigned,
  WorkbenchFacetCategory({{blank::final category|Destructure the category getter from WorkbenchFacetCategory.|final category|17}}) =>
    part.category != null && part.category!.toLowerCase() == category.toLowerCase(),
};

// Sort a newly created list in-place and return the list using Dart's cascade operator:
final sortedContainers = [...snapshot.containers]
  {{blank:..sort|Use the cascade operator to call sort() in place and return the list.|..sort|8}}((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
```

:::prompts
hint: "Closed union hierarchies use 'sealed class', property destructuring in patterns uses ':final category', and chaining a void method while returning the receiver uses the '..sort' cascade operator."
success: "Nailed it! You can now combine @freezed sealed classes, Dart 3 pattern matching, cascade operators, and derived Riverpod providers."
:::
:::

:::quiz id="quiz-0005" title="Retrieval Practice: Engineering Unit Search, Sealed Classes & Derived State" badge="3 Questions • Equal-Length Options"
- question: "How does `@freezed sealed class WorkbenchFacet` compare to TypeScript discriminated unions?"
  wrong_hint: "Think about what the `sealed` modifier enables inside a Dart 3 `switch` expression."
  options:
    - letter: "A"
      text: "It allows any external file to add new subclasses at runtime without recompiling."
      correct: false
      explain: "A `sealed` class restricts all direct subtypes to the same library so the compiler knows the complete set of variants."
    - letter: "B"
      text: "It enables compile-time exhaustive switch expressions with typed field destructuring across every variant."
      correct: true
      explain: "Correct! Marking the union `sealed` lets Dart verify that every case (`All`, `LowStock`, `Unassigned`, `Category`) is handled."
    - letter: "C"
      text: "It serializes every filter state change directly into the operating system keychain store."
      correct: false
      explain: "`WorkbenchFacet` is an in-memory UI filter union managed by `SelectedFacet`, not persisted to the OS keychain."
    - letter: "D"
      text: "It replaces Riverpod providers by storing filter state inside a global static variable."
      correct: false
      explain: "`WorkbenchFacet` is the immutable value type held by Riverpod's `selectedFacetProvider`."

- question: "Why does `PartSearchEngine.parseEngineeringToken('104')` return `null` instead of expanding to `100nF`?"
  wrong_hint: "Check the requirement in `parseEngineeringToken` that a standard token must have a prefix or unit suffix."
  options:
    - letter: "A"
      text: "Dart regular expressions cannot match strings that contain only three consecutive ASCII digit characters."
      correct: false
      explain: "Dart regexes match digits easily, but `parseEngineeringToken` explicitly rejects tokens where both `prefix` and `unit` are `null`."
    - letter: "B"
      text: "Capacitor values in the catalog are always stored in Farads without any SI prefixes."
      correct: false
      explain: "Catalog parts use human-readable SI strings like `'100nF'` and `'10µF'`, which `parseEngineeringToken` normalizes to Farads."
    - letter: "C"
      text: "Bare integers lack an SI prefix or unit suffix and would cause false positives."
      correct: true
      explain: "Correct! Rejecting bare numbers ensures `'104'` only matches literal substrings (like MPN `CL10B104KB8NNNC`) without false unit matches."
    - letter: "D"
      text: "The search engine only supports resistor values and ignores all capacitor and inductor queries."
      correct: false
      explain: "`PartSearchEngine` supports resistance, capacitance, inductance, voltage, current, power, and frequency."

- question: "How does the derived `@riverpod FilteredWorkbenchView filteredWorkbenchView(Ref ref)` provider behave when `searchQueryProvider` changes?"
  wrong_hint: "Compare Riverpod's `ref.watch(...)` dependency tracking to React's `useMemo`."
  options:
    - letter: "A"
      text: "It automatically recomputes the cached FilteredWorkbenchView whenever any watched upstream provider state changes."
      correct: true
      explain: "Correct! `ref.watch` subscribes `filteredWorkbenchViewProvider` to `catalogProvider`, `searchQueryProvider`, and `selectedFacetProvider`."
    - letter: "B"
      text: "It reloads the entire JSON catalog file from disk on every keystroke event."
      correct: false
      explain: "`catalogProvider` keeps the loaded `CatalogSnapshot` in memory; changing `searchQueryProvider` only re-runs the in-memory filter."
    - letter: "C"
      text: "It mutates the original CatalogSnapshot.parts list in place and overwrites the backup file."
      correct: false
      explain: "`CatalogSnapshot.parts` is an unmodifiable list; `filteredWorkbenchView` creates new sorted lists without mutating the catalog."
    - letter: "D"
      text: "It requires components to manually pass a dependency array like React's useMemo hook."
      correct: false
      explain: "Riverpod tracks dependencies automatically via `ref.watch(...)` calls—no manual dependency arrays exist."
:::

:::verify id="verify-0005" title="Verification Lab: Run Engineering Search & Filter Provider Suite" badge="CLI Gate • Zero Warnings & 100% Green"
Run static analysis and the complete 9-test suite inside `tutorial/apps/0005-engineering-unit-search-and-filter-providers`:

```bash caption="Terminal verification commands for Lesson 0005"
cd tutorial/apps/0005-engineering-unit-search-and-filter-providers
flutter analyze
flutter test
```

Expected terminal output:

```text caption="Verified output of flutter analyze && flutter test"
Analyzing 0005-engineering-unit-search-and-filter-providers...
No issues found!
00:01 +9: All tests passed!
```

- [ ] Inspected `lib/search/part_search_engine.dart` and `lib/search/workbench_filter_provider.dart`.
- [ ] Verified `flutter analyze` reports `No issues found!`.
- [ ] Verified `flutter test` passes all 9 tests—including `0.1uF == 100nF == 100000pF`, `4k7 == 4.7kΩ`, 3-tier ranking for `4700R`, non-expansion of `104`, filter chips, and natural `By Container` slot ordering (`Page 2` before `Page 10`).
:::

:::teacher-prompt
**Milestone reached!** With Lessons 0001–0005 complete, you have rebuilt and verified the entire data, persistence, state, and engineering search core of the Electronics Parts Tracker! Ask me any questions about Lessons 0001–0005, or let me know when you're ready for Lessons 0006–0008 (the LCSC HTTP client, the dark Workbench UI & inline accordion, and the Add/Edit/Detail bottom sheets).
:::
