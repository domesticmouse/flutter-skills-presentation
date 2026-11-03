---
title: "Verification & Widget Testing Reference"
page_title: "Verification & Testing — Flutter & Riverpod"
nav_id: "verification-and-testing"
nav_label: "Verification & Testing"
badge: "Mission: Parts Tracker in Flutter"
subtitle: "Command-line verification gates, WidgetTester vs. React Testing Library idioms, and ProviderScope dependency overrides."
card:
  title: "**Verification & Widget Testing Reference**"
  summary: "CLI verification commands (`flutter analyze`, `flutter test`) and side-by-side translations from React Testing Library to `WidgetTester` and `ProviderContainer`."
---

## 1. Mandatory Verification Gates

Every companion app in `./tutorial/apps/<NNNN-slug>/` must pass two automated gates with zero warnings and 100% passing tests before a lesson is complete:

```bash caption="Run static analysis and headless unit/widget tests inside any lesson app directory"
flutter analyze
flutter test
```

{{sidenote:Unlike browser-based E2E runners (Playwright/Cypress) or JSDOM shims, `flutter test` executes the real Flutter layout and rendering pipeline against a deterministic fake clock inside the Dart VM—typically completing in under two seconds.}}

When a lesson introduces or modifies `@freezed`, `@JsonSerializable`, or `@riverpod` annotations (starting in Lesson 0002), regenerate the companion `*.freezed.dart` and `*.g.dart` part files via:

```bash caption="Run code generation for Freezed and Riverpod annotations"
dart run build_runner build --delete-conflicting-outputs
```

## 2. React Testing Library vs. `flutter_test`

Table: Translating React Testing Library + Vitest to `package:flutter_test`

| Testing Action | React Testing Library (`@testing-library/react`) | Flutter Widget Test (`package:flutter_test`) |
| :--- | :--- | :--- |
| Define a UI test | `test('renders workbench', async () => { ... })` | `testWidgets('renders workbench', (WidgetTester tester) async { ... })` |
| Mount component tree | `render(<Provider><PartsTrackerApp /></Provider>)` | `await tester.pumpWidget(const ProviderScope(child: PartsTrackerApp()))` |
| Wait for async state / animations | `await waitFor(() => ...)` | `await tester.pumpAndSettle()` |
| Find by visible text | `screen.getByText('Electronics Parts Tracker')` | `find.text('Electronics Parts Tracker')` |
| Find by substring | `screen.getByText(/RC0603/i)` | `find.textContaining('RC0603')` |
| Find by `data-testid` | `screen.getByTestId('part_lcsc_input')` | `find.byKey(const Key('part_lcsc_input'))` |
| Assert element is present once | `expect(el).toBeInTheDocument()` | `expect(finder, findsOneWidget)` |
| Assert element is absent | `expect(screen.queryByText('...')).toBeNull()` | `expect(finder, findsNothing)` |
| Click / tap an element | `await userEvent.click(el)` | `await tester.tap(finder); await tester.pumpAndSettle();` |
| Type into a text input | `await userEvent.type(input, '0.1uF')` | `await tester.enterText(finder, '0.1uF'); await tester.pumpAndSettle();` |

## 3. Dependency Injection with `ProviderScope` Overrides

In React, testing components with mock stores or fake API clients requires wrapping the tree in custom `<Context.Provider value={mock}>` layers or module-mocking (`vi.mock(...)`). In Riverpod, every dependency is a provider that can be cleanly overridden per test without global module mocks:

```dart caption="Overriding persistence and HTTP providers inside a headless testWidgets test"
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      catalogPersistenceProvider.overrideWithValue(persistence),
      lcscClientProvider.overrideWithValue(fakeLcsc),
    ],
    child: const PartsTrackerApp(),
  ),
);
await tester.pumpAndSettle();
```
