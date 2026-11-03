---
title: "React & TypeScript to Flutter & Dart Cheat Sheet"
page_title: "React → Flutter Cheat Sheet"
nav_id: "react-to-flutter"
nav_label: "React → Flutter"
badge: "Mission: Parts Tracker in Flutter"
subtitle: "Side-by-side mental model and syntax translation from React + TypeScript to Flutter + Dart 3 + Riverpod + Freezed."
card:
  title: "**React & TypeScript → Flutter & Dart Cheat Sheet**"
  summary: "Side-by-side mapping of TypeScript types, JSX components, hooks, Context/Zustand, and React Testing Library to Dart 3, Widgets, Riverpod, and Freezed."
---

## 1. Project & Tooling Anatomy

Table: Project Manifest, Compiler, Linter, and Codegen Equivalents

| React + TypeScript (`npm` / `pnpm`) | Flutter + Dart (`flutter` / `dart`) | Purpose in `parts_tracker_skilled` |
| :--- | :--- | :--- |
| `package.json` + `pnpm-lock.yaml` | `pubspec.yaml` + `pubspec.lock` | Declares SDK constraints, dependencies (`flutter_riverpod`, `freezed_annotation`), and dev tools (`flutter_test`, `build_runner`). |
| `tsconfig.json` + `eslint.config.js` | `analysis_options.yaml` | Configures the Dart static analyzer and linter rules (`package:flutter_lints/flutter.yaml`). |
| `tsc --noEmit && eslint .` | `flutter analyze` | Verifies zero type errors, null-safety violations, or lint warnings across `lib/` and `test/`. |
| `vitest run` / `jest` | `flutter test` | Runs unit tests and headless `testWidgets` UI tests in the Dart VM without needing a browser or simulator. |
| GraphQL / OpenAPI / Prisma codegen | `dart run build_runner build` | Generates `*.freezed.dart` (`copyWith`, `==`, `toString`) and `*.g.dart` (`fromJson`/`toJson`, Riverpod providers). |

## 2. TypeScript vs. Dart 3 Language Essentials

{{sidenote:Unlike TypeScript—where types are erased at compile time and `any` or unsound casts can let `undefined` slip through at runtime—Dart has **sound null safety** enforced both at compile time and in the runtime VM.}}

Table: TypeScript vs. Dart 3 Type System and Syntax

| Concept | TypeScript | Dart 3 |
| :--- | :--- | :--- |
| Non-nullable vs. nullable type | `name: string` / `slot?: string \| null` | `String name` / `String? slot` |
| Nullish coalescing & optional chaining | `val ?? 0` / `slot?.trim()` | `val ?? 0` / `slot?.trim()` (identical!) |
| Non-null assertion | `slot!.toLowerCase()` | `slot!.toLowerCase()` (identical!) |
| Type system discipline | **Structural** (duck typing by shape) | **Nominal** (explicit `class`, `implements`, or `with` mixin) |
| Immutable compile-time constant | `Object.freeze({...})` (runtime only) | `const Part(id: 'p1', name: '10k')` (canonicalized at compile time) |
| Named parameters (props object) | `function Card({ title, count = 0 }: Props)` | `const Card({super.key, required this.title, this.count = 0});` |
| Async return type | `Promise<CatalogSnapshot>` | `Future<CatalogSnapshot>` |
| Array / Dictionary literals | `const items: Part[] = []`, `Record<string, string>` | `const <Part>[]`, `<String, String>{}` |
| Private module visibility | `private` keyword or non-exported symbol | Leading underscore (`_PartsTrackerApp`, `_commit()`) is library-private |

## 3. React Components vs. Flutter Widgets

```mermaid caption="Figure R.1: How React's Component + Virtual DOM tree maps to Flutter's Widget + Element (BuildContext) + RenderObject trees."
flowchart LR
  subgraph React["React Runtime"]
    R1["JSX Element<br/>(Immutable Blueprint)"] --> R2["Fiber Node<br/>(State & Context)"]
    R2 --> R3["Browser DOM Node<br/>(Layout & Paint)"]
  end
  subgraph Flutter["Flutter Runtime"]
    F1["Widget<br/>(Immutable Config)"] --> F2["Element / BuildContext<br/>(Lifecycle & Tree Lookup)"]
    F2 --> F3["RenderObject<br/>(Layout & Skia/Impeller Paint)"]
  end
```

Table: UI Tree, Props, Local State, and Riverpod Equivalents

| React Pattern | Flutter + Riverpod Pattern | Key Difference to Remember |
| :--- | :--- | :--- |
| `createRoot(el).render(<App />)` | `runApp(const ProviderScope(child: PartsTrackerApp()))` | `runApp` inflates the root `Widget` to fill the screen; `ProviderScope` holds all Riverpod state. |
| `function App({ key }: Props)` | `class PartsTrackerApp extends StatelessWidget` | Every widget class has a `const` constructor accepting `{super.key}` and overrides `Widget build(BuildContext context)`. |
| `React.memo(MyComponent)` | `const MyWidget()` | Marking a widget constructor call `const` tells Flutter to reuse the exact same instance and skip rebuilding its subtree. |
| `useContext(ThemeContext)` | `Theme.of(context)` | Instead of hooks that rely on call-order index, Flutter walks up the `BuildContext` (`Element`) tree in $O(1)$ via `InheritedWidget`. |
| `useState(false)` | `StatefulWidget` + `State<T>` (`setState(() { ... })`) | Local ephemeral UI state (like whether a card's inline accordion is expanded or a `TextEditingController`) lives in a `State` object. |
| Zustand / Redux + TanStack Query | `@Riverpod` `AsyncNotifier` + `ref.watch(...)` | Providers live outside the widget tree inside `ProviderScope`, automatically caching async `Future` states as `AsyncValue<T>` (`AsyncData`, `AsyncLoading`, `AsyncError`). |
| `{ ...part, quantity: nextQty }` | `part.copyWith(quantity: nextQty)` | Dart classes do not have object-spread syntax; `@freezed` generates type-safe `copyWith(...)` methods and deep value equality (`==`). |
