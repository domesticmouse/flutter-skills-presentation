# Mission: Flutter & Dart via the Electronics Parts Tracker

## Why
Rebuild the Electronics Parts Tracker application (`parts_tracker_skilled`) from the ground up to transition from React and TypeScript to idiomatic Flutter, Dart, Riverpod, and Freezed—gaining the practical ability to architect, test, and ship new Flutter applications with this stack.

## Success looks like
- Reconstruct the complete Electronics Parts Tracker progressively in `./tutorial/apps/` from an empty entry point to the full dark-mode workbench UI, passing `flutter analyze` and `flutter test` at every step.
- Author immutable Dart domain models (`Container`, `Part`, `CatalogSnapshot`) with Freezed and JSON serialization, understanding how they replace TypeScript interfaces and object spread patterns.
- Build async, testable state management with Riverpod (`@Riverpod`, `AsyncNotifier`, `ProviderScope` overrides) and pure search/unit-equivalence engines.
- Implement responsive Material 3 workbench screens, inline accordions, bottom sheets, LCSC HTTP client integration, and `WidgetTester` integration tests.

## Constraints
- Starting from strong React + TypeScript experience, with zero prior Dart or Flutter experience.
- Every lesson must bridge from familiar React/TypeScript mental models to Dart/Flutter idioms and verify behavior via automated CLI gates (`flutter analyze` and `flutter test`).
- All course artifacts live inside `./tutorial/` so the root repository remains untouched.

## Out of scope
- Native iOS/Android platform plugin authoring in Swift/Kotlin.
- Backend server development (the app uses local atomic JSON persistence and a public read-only LCSC API).
- Legacy Flutter state libraries (`setState`-only architecture, `Provider` v5, BLoC, Redux).
