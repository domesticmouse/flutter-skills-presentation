---
title: "Glossary of Parts Tracker & Flutter Terms"
page_title: "Glossary — Flutter & Parts Tracker"
nav_id: "glossary"
nav_label: "Glossary"
badge: "Mission: Parts Tracker in Flutter"
subtitle: "Canonical domain and framework definitions used across all lessons and reference sheets. Designed for quick screen lookup and clean printing."
card:
  title: "**Glossary of Parts Tracker & Flutter Terms**"
  summary: "Canonical definitions for the Electronics Parts Tracker domain (`Part`, `Spec`, `Container`, `Slot`) and core Flutter/Riverpod architecture."
---

## 1. Electronics Parts Tracker Domain

**Part**:
A distinct electronic component entry in the catalog (e.g., `10kΩ 0603 1% Resistor`, `NE555P`, `ESP32-WROOM-32E`), tracking a single quantity on hand, an optional `(Container, Slot)` location, package/footprint, optional LCSC code (`Cxxxxxx`), and electrical **Specs**.
_Avoid_: Item, product, SKU, device

**Spec**:
A named electrical or physical attribute of a **Part** (e.g., `Capacitance: 100nF`, `Voltage Rated: 50V`, `Tolerance: ±10%`), represented as an ordered key-value pair on the **Part**.
_Avoid_: Parameter, property, custom field, tag

**Container**:
A top-level physical storage unit at the workbench (e.g., `"SMD Binder #1"`, `"IC Drawer Cabinet"`, `"Passives Grid Box A"`), tracked as a first-class entity with a name and optional description.{{sidenote:Because Flutter's Material library also exports a layout widget named `Container`, files that import both `package:flutter/material.dart` and our domain model use `hide Container` or qualify the import.}}
_Avoid_: Warehouse, building, parent location

**Slot**:
A named compartment, drawer, cell, or strip inside a **Container** (e.g., `"A1"`, `"Drawer 12"`, `"Page 4"`), represented as a string label created on the fly. A **Slot** holds at most one **Part** (`(Container, Slot)` is strictly 1-to-1 when a **Slot** is specified).
_Avoid_: Sub-location, child location, bin (when referring to the top-level container)

**CatalogSnapshot**:
An immutable, versioned value object (`schemaVersion: 1`) holding the complete list of **Containers**, the complete list of **Parts**, and the UTC `updatedAt` timestamp serialized to disk or exported as a JSON backup.
_Avoid_: Store state blob, database dump

## 2. Flutter & Riverpod Architecture (Lesson 0001)

**Widget**:
An immutable description of part of a user interface (`StatelessWidget`, `StatefulWidget`, or `ConsumerWidget`), analogous to a React element blueprint (`JSX.Element`) rather than a mutable DOM node.
_Avoid_: Component instance, DOM element, view controller

**Element (`BuildContext`)**:
The live, mutable node in Flutter's mounted tree that manages a **Widget**'s lifecycle and position in the hierarchy; passed to `build(BuildContext context)` as the handle for looking up inherited theme, media query, or navigation state.
_Avoid_: Virtual DOM fiber node, `this` context

**ProviderScope**:
The root Riverpod **Widget** placed at the top of the application (`runApp(const ProviderScope(child: ...))`) or inside a `testWidgets` harness that stores the state of all providers and accepts dependency overrides for testing.
_Avoid_: Redux store provider, global singleton container

**WidgetTester**:
The programmatic test driver supplied to `testWidgets` callbacks that mounts a **Widget** tree (`pumpWidget`), advances the frame clock (`pump` / `pumpAndSettle`), and simulates user interactions (`tap`, `enterText`).
_Avoid_: Headless browser, Enzyme wrapper

## 3. Data Modeling, Persistence & Reactive State (Lessons 0002–0005)

**Freezed Data Class**:
An immutable Dart class annotated with `@freezed` whose generated mixin (`_$ClassName` in `*.freezed.dart`) synthesizes value equality (`==`, `hashCode`), `toString()`, and `copyWith(...)` cloning—replacing TypeScript interfaces paired with `{ ...obj }` object spread.
_Avoid_: Mutable POJO, ORM entity

**Part File (`part` / `part of`)**:
A Dart compilation-unit directive that splits a single library across multiple source files (such as `catalog_models.dart`, `catalog_models.freezed.dart`, and `catalog_models.g.dart`) so generated code can access private constructors (`_Container`, `_Part`) and implement mixins in the same namespace.
_Avoid_: C `#include` macro, separate module import

**AsyncNotifier**:
A Riverpod state controller (`class Catalog extends _$Catalog`) whose `build()` method returns a `Future<T>`, automatically exposing `AsyncValue<T>` (`AsyncLoading`, `AsyncData`, `AsyncError`) to watching **Widgets** and serializing state mutations.
_Avoid_: Redux thunk reducer, unhandled Promise hook

**ProviderContainer**:
The standalone Dart object backing a **ProviderScope** that stores provider state and dependency overrides, allowing unit tests (`test(...)`) to read, watch, and mutate Riverpod providers headlessly without mounting any **Widgets**.
_Avoid_: Mock store wrapper

**Sealed Class (`sealed class`)**:
A closed Dart 3 class hierarchy (such as `@freezed sealed class WorkbenchFacet`) whose subclasses are all known to the compiler, enabling exhaustive `switch` expressions with destructuring pattern matching—analogous to a TypeScript discriminated union (`type Facet = { kind: 'all' } | { kind: 'category'; category: string }`).
_Avoid_: String enum tag, untyped union

**EngineeringValue**:
A canonical `(EngineeringDimension, double baseValue)` pair produced by `PartSearchEngine.parseEngineeringToken` that normalizes SI prefixes (`100nF`, `0.1uF`, `100000pF`) and EE-infix notation (`4k7`, `3v3`, `2n2`) into base units (`Farads`, `Ohms`, `Volts`) for tolerance-aware comparison.
_Avoid_: Regex string replacement, raw float

