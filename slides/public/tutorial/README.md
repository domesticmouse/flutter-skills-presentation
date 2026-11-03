# Electronics Parts Tracker — Flutter & Dart Course for React + TypeScript Developers

An interactive, test-verified course teaching **Flutter**, **Dart 3**, **Riverpod**, and **Freezed** by progressively rebuilding the `parts_tracker_skilled` Electronics Parts Tracker application from the ground up.

## Course Pages

- [Course Landing Page (`index.html`)](./index.html)
- **Lessons**:
  - [Lesson 0001: Flutter Bootstrap, `ProviderScope` & Dark Workbench Shell](./lessons/0001-flutter-bootstrap-and-provider-scope.html) ([companion app](./apps/0001-flutter-bootstrap-and-provider-scope/))
  - [Lesson 0002: Immutable Domain Models with Freezed & JSON Serialization](./lessons/0002-immutable-domain-models-with-freezed.html) ([companion app](./apps/0002-immutable-domain-models-with-freezed/))
  - [Lesson 0003: Persistence Seam & Atomic Local File Storage](./lessons/0003-persistence-seam-and-atomic-file-storage.html) ([companion app](./apps/0003-persistence-seam-and-atomic-file-storage/))
  - [Lesson 0004: Reactive Catalog State with Riverpod `AsyncNotifier`](./lessons/0004-reactive-catalog-state-with-riverpod.html) ([companion app](./apps/0004-reactive-catalog-state-with-riverpod/))
  - [Lesson 0005: Engineering Unit Search Engine & Derived Filter Providers](./lessons/0005-engineering-unit-search-and-filter-providers.html) ([companion app](./apps/0005-engineering-unit-search-and-filter-providers/))
- **Reference Sheets**:
  - [Glossary of Parts Tracker & Flutter Terms](./reference/glossary.html)
  - [React & TypeScript → Flutter & Dart Cheat Sheet](./reference/react-to-flutter-cheatsheet.html)
  - [Verification & Widget Testing Reference](./reference/verification-and-testing.html)

## Building the Course HTML Locally

```bash
cd tutorial
uv venv
uv pip install markdown-it-py pyyaml
.venv/bin/python build.py --check
```
