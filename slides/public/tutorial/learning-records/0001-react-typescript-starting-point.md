# Prior Knowledge: Experienced in React & TypeScript, New to Dart & Flutter

The learner is fluent in React and TypeScript (component trees, props, keys, immutable state updates, static typing, and DOM/component testing) and has never written Dart or Flutter before. Their goal is to rebuild the `parts_tracker_skilled` Electronics Parts Tracker application from scratch in `./tutorial/apps/` to gain production fluency in Flutter, Dart 3, Riverpod, and Freezed.

## Implications
- Anchor every new Dart/Flutter concept to its closest React/TypeScript counterpart—and explicitly call out where the analogy breaks (e.g., Dart's nominal typing vs TypeScript's structural typing, compile-time `const` widget canonicalization vs `React.memo`, and Riverpod's `AsyncNotifier` outside the widget tree vs React hooks bound to component instances).
- Introduce Dart syntax (`const`, named parameters `{required ...}`, `super.key`, `part` directives, mixins `with`, `Future<T>`) inline as each block of code is built, rather than assuming prior Dart exposure.
