---
title: "Flutter & Dart for React + TypeScript Developers"
page_title: "Course Index — Flutter & Dart via Electronics Parts Tracker"
nav_id: "index"
nav_label: "Index"
badge: "Mission: Rebuild the Electronics Parts Tracker"
subtitle: "Learn Dart 3, Flutter Widgets, Riverpod, and Freezed by progressively reconstructing a production-grade Electronics Parts Tracker from scratch—anchored at every step to the React and TypeScript mental models you already know."
---

## Course Mission

You already know how to model state with TypeScript interfaces, compose declarative UIs with React function components, manage server/client state with Context, Zustand, or TanStack Query, and verify behavior with React Testing Library.

In this course, you will rebuild the **Electronics Parts Tracker** (`parts_tracker_skilled`) step by step inside `./tutorial/apps/`. Every lesson pairs one focused slice of the real application with an interactive code exercise, a retrieval quiz, and a runnable companion app verified via `flutter analyze` and `flutter test`.

```mermaid caption="Figure 0.1: Progressive reconstruction of the Electronics Parts Tracker across lessons."
flowchart LR
  L1["0001: Bootstrap,<br/>ProviderScope & Shell"] --> L2["0002: Freezed Domain<br/>Models & JSON"]
  L2 --> L3["0003: Persistence Seam<br/>& Atomic File I/O"]
  L3 --> L4["0004: Riverpod AsyncNotifier<br/>& Slot Uniqueness"]
  L4 --> L5["0005: Unit-Aware Search<br/>& Filter Providers"]
  L5 --> L6["0006: LCSC HTTP Client<br/>& Fake Injection"]
  L6 --> L7["0007: Workbench UI<br/>& Inline Accordion"]
  L7 --> L8["0008: Bottom Sheets,<br/>Forms & Full Suite"]
```

## Published Lessons {#lessons}

{{widget:lesson-cards}}

## Reference Sheets & Printable Guides {#reference-sheets}

Keep these reference sheets open alongside the lessons—or print them directly (`Cmd+P`), which automatically switches to a high-contrast light print stylesheet:

{{widget:reference-cards}}

:::teacher-prompt
**Ready to begin?** Start with [Lesson 0001: Flutter Bootstrap, `ProviderScope` & Dark Workbench Shell](lessons/0001-flutter-bootstrap-and-provider-scope.md), and ask me any questions whenever a Dart syntax rule or Flutter concept feels unfamiliar!
:::
