# Flutter & Dart Resources

## Knowledge

- [Flutter for React Developers (Official Documentation)](https://docs.flutter.dev/get-started/flutter-for/react-devs)
  Official side-by-side guide mapping React components, props, hooks, and JSX to Flutter widgets, `BuildContext`, and declarative UI trees. Use for: translating React mental models to Flutter equivalents.
- [Dart Language Tour & Effective Dart](https://dart.dev/language)
  Authoritative language specification by the Dart team covering sound null safety, constructors, pattern matching, classes, mixins, and async `Future`/`Stream` semantics. Use for: learning Dart syntax and type system rules coming from TypeScript.
- [Riverpod Official Documentation (`flutter_riverpod` & `riverpod_annotation`)](https://riverpod.dev/docs/introduction/getting_started)
  Primary reference by Remi Rousselet covering `ProviderScope`, `Ref`, `@riverpod` code generation, `AsyncNotifier`, and provider overrides in tests. Use for: understanding reactive state management and dependency injection.
- [Freezed Package Documentation (`package:freezed`)](https://pub.dev/packages/freezed)
  Official documentation for code-generated immutable data classes, `copyWith`, deep equality, and `json_serializable` integration. Use for: authoring domain models (`Container`, `Part`, `CatalogSnapshot`, `LcscPartMetadata`).
- [Flutter Widget Testing Documentation (`package:flutter_test`)](https://docs.flutter.dev/cookbook/testing/widget/introduction)
  Official guide to `testWidgets`, `WidgetTester`, `pumpWidget`, `pumpAndSettle`, and `Finder` APIs. Use for: designing high-signal unit and widget verification labs in every lesson.
- [Workspace Flutter & Dart Skills (`~/.gemini/config/plugins/flutter/skills/`)](https://docs.flutter.dev/reference/learning-resources)
  Verified local skills covering `dart-run-static-analysis`, `dart-add-unit-test`, `flutter-add-widget-test`, `flutter-apply-architecture-best-practices`, and `dart-use-pattern-matching`. Use for: grounding idiomatic Dart 3 and Flutter patterns.

## Wisdom (Communities)

- [`rrousselGit/riverpod` GitHub Discussions](https://github.com/rrousselGit/riverpod/discussions)
  Official architecture and Q&A forum monitored by the author of Riverpod and Freezed. Use for: state modeling edge cases, provider lifecycle questions, and testing patterns.
- [Flutter Dev Discord & GitHub Discussions (`flutter/flutter`)](https://github.com/flutter/flutter/discussions)
  High-signal engineering discussions with framework contributors and production Flutter engineers. Use for: rendering pipeline questions, layout idioms, and Material 3 customization.
