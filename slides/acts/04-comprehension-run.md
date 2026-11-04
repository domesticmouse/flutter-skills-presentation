---
layout: center
class: text-center
---

<!-- S27 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 3: The Comprehension Run
  </h1>
  <p class="text-xl font-mono text-cyan-300">
    parts_tracker_comprehension &middot; /teach-code &middot; 03-comprehension.cast
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Paying down Comprehension Debt by having <code>agy</code> turn its newly built codebase into a personalised course bridged from your existing stack
  </p>
</div>

<!--
This brings us to Act 3: The Comprehension Run. Even after the Skilled Run gives us a clean, well-tested architecture, if you or a teammate used agy to build in a stack you don't know—say, our React and TypeScript developer shipping a Flutter, Riverpod, and Freezed app—you still have Comprehension Debt. How do you onboard your teammates or answer deep architectural questions from the judges? Let's install the /teach-code skill and make agy teach us the exact codebase it just built.
-->

---
layout: default
---

<!-- S27a -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">Installing <code>/teach-code</code> via <code>domesticmouse/skills</code></h2>
</div>

<div class="p-6 rounded-2xl bg-emerald-950/20 border border-emerald-500/40 space-y-3 mb-6">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono text-emerald-400 uppercase tracking-widest">One-Command Project Setup</span>
    <span class="text-xs font-mono text-gray-400">Run inside your project root</span>
  </div>
  <div class="p-4 rounded-xl bg-gray-950/90 border border-gray-800 font-mono text-xl font-bold tracking-tight">
    <span class="text-gray-500 select-none">$ </span><span class="text-emerald-300">npx skills@latest add domesticmouse/skills</span>
  </div>
</div>

<div class="grid grid-cols-2 gap-6">
  <div class="p-5 rounded-xl bg-gray-900/90 border border-cyan-500/30 flex flex-col justify-between space-y-3">
    <div class="space-y-2">
      <div class="text-xs font-mono text-cyan-400 uppercase tracking-wide">Canonical Source &amp; Documentation</div>
      <div class="text-sm font-bold font-mono whitespace-nowrap">
        <a href="https://github.com/domesticmouse/skills/" target="_blank" class="text-cyan-300 hover:underline">
          https://github.com/domesticmouse/skills/ &nearr;
        </a>
      </div>
      <p class="text-xs text-gray-300 leading-relaxed m-0">
        Open-source Agent Skills repository hosting the <code>/teach-code</code> interactive curriculum builder and the presentation tooling used to produce this deck.
      </p>
    </div>
    <div class="text-xs font-mono text-gray-400 pt-2 border-t border-gray-800">
      Focus of Act 3: <code class="text-emerald-300">/teach-code</code>
    </div>
  </div>

  <div class="p-5 rounded-xl bg-gray-900/90 border border-gray-800 space-y-2.5">
    <div class="text-xs font-mono text-emerald-400 uppercase tracking-wide">What It Configures on Disk</div>
    <ul class="text-xs text-gray-300 space-y-2 list-disc pl-4 m-0 leading-relaxed">
      <li>
        Installs <code>/teach-code</code> alongside its static HTML compiler (<code>build.py</code>), Tufte CSS templates, and verification gates into <code>.agents/skills/</code>.
      </li>
      <li>
        Turns any existing or freshly generated repository into a stateful, multi-lesson course tailored to your prior engineering background.
      </li>
      <li>
        Also bundles the reproducibility &amp; deck skills: <code>/slidev-deck</code>, <code>/asciinema</code>, <code>/agy-brain-explorer</code>, <code>/ios-simulator-screenshot</code>, and <code>/crop-image</code>.
      </li>
    </ul>
  </div>
</div>

<!--
Just like we installed Matt Pocock's skills in Act 2, installing the /teach-code skill for Act 3 is a single terminal command: npx skills@latest add domesticmouse/skills. You can browse the source and documentation at https://github.com/domesticmouse/skills/. That command drops /teach-code—along with its Python HTML compiler and Tufte CSS templates—directly into .agents/skills/ so the agent can turn our newly built Flutter codebase into an interactive course.
-->

---
layout: default
---

<!-- S28 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">Paying Down Comprehension Debt with <code>/teach-code</code></h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-5 leading-relaxed">
  <li>
    <strong class="text-white">Clone the Skilled Run &amp; Install <code>domesticmouse/skills</code></strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>We copy <code>parts_tracker_skilled</code> to <code>parts_tracker_comprehension</code> and run <code>npx skills@latest add domesticmouse/skills</code>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Interview the Learner Before Writing Curriculum</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>We invoke <code>/teach-code I know react, but I'd like to learn Flutter from this codebase.</code></li>
      <li><code>/teach-code</code> interviews us on our learning goal (rebuild from the ground up) and prior stack (React + TypeScript, brand new to Dart) and records it in <code>tutorial/learning-records/</code>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Compile Self-Contained HTML Lessons + Runnable Companion Apps</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Every lesson in <code>tutorial/lessons/</code> is paired with a runnable Flutter project in <code>tutorial/apps/</code> verified via <code>flutter analyze</code>, <code>flutter test</code>, and <code>python3 tutorial/build.py --check</code>.</li>
    </ul>
  </li>
</ol>

<!--
We start by cloning our finished Skilled Run app into parts_tracker_comprehension and installing domesticmouse/skills, which adds the /teach-code skill. When we tell /teach-code "I know React, but I'd like to learn Flutter from this codebase," it doesn't just dump a wall of chat explanations. Instead, it interviews us on our prior stack—React and TypeScript—and scaffolds a full static HTML course and runnable per-lesson exercises inside ./tutorial/. Let's watch the recording.
-->

---
layout: cast-full
cast: /casts/03-comprehension.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S29 -->
<!--
Here is the Comprehension Run terminal cast, compressed into under two minutes across 9 stop points. You can watch us install domesticmouse/skills, launch agy, run /teach-code, answer the two calibration questions about our React and TypeScript background, watch it scaffold the curriculum and Lesson 0001, and then build and verify Lessons 0001 through 0005.
-->

---
layout: skill-breakdown
way: 3
title: "Stateful Pedagogy on Disk: Mission & Learning Records"
---

<!-- S30 -->
<div class="space-y-4">
  <div class="p-4 rounded-lg bg-gray-950/90 border border-gray-800 space-y-3 text-xs text-gray-200 leading-relaxed">
    <div>
      <div class="text-sm font-bold text-white">
        Mission: Flutter &amp; Dart via the Electronics Parts Tracker <span class="text-xs font-mono font-normal text-gray-400">(tutorial/MISSION.md)</span>
      </div>
      <p class="mt-1 m-0 text-gray-300">
        Rebuild the Electronics Parts Tracker application (<code>parts_tracker_skilled</code>) from the ground up to transition from React and TypeScript to idiomatic Flutter, Dart, Riverpod, and Freezed.
      </p>
    </div>
    <div class="border-t border-gray-800 pt-2.5">
      <div class="text-sm font-bold text-white">
        Prior Knowledge <span class="text-xs font-mono font-normal text-gray-400">(tutorial/learning-records/0001-react-typescript-starting-point.md)</span>
      </div>
      <p class="mt-1 m-0 text-gray-300">
        Anchor every new Dart/Flutter concept to its closest React/TypeScript counterpart&mdash;and explicitly call out where the analogy breaks (nominal vs. structural typing, <code>const</code> canonicalization vs. <code>React.memo</code>).
      </p>
    </div>
  </div>

  <div class="grid grid-cols-2 gap-4 text-xs pt-1">
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-emerald-300 font-semibold">Durable Learner State:</span> Just like <code>/wayfinder</code> stores architectural state on disk, <code>/teach-code</code> persists pedagogical state in <code>MISSION.md</code>, <code>NOTES.md</code>, and <code>learning-records/</code>.
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-emerald-300 font-semibold">Automated Build &amp; Test Gates:</span> <code>build.py --check</code> compiles Markdown + Mermaid diagrams + interactive quizzes into dark/print-ready Tufte HTML and validates every internal link.
    </div>
  </div>
</div>

<!--
Look at how /teach-code structures ./tutorial/ on disk. Just like Wayfinder persists architectural state across /clear boundaries, /teach-code persists pedagogical state in MISSION.md, NOTES.md, and learning-records/. It records that we know TypeScript interfaces, JSX, and React Testing Library, and sets a rule that every lesson must bridge from React and explicitly point out where the analogy breaks.
-->

---
layout: skill-breakdown
way: 3
title: "Bridging Mental Models: React + TypeScript → Flutter + Dart 3"
---

<!-- S31 -->
<div class="space-y-3">
  <div class="grid grid-cols-2 gap-3 text-xs">
    <div class="p-3 rounded-lg bg-gray-900/90 border border-gray-800 space-y-1">
      <div class="text-cyan-300 font-mono font-semibold">TypeScript Interface + Spread &rarr; @freezed</div>
      <p class="text-gray-300 m-0">
        Instead of structural interfaces and <code>{ ...part, quantity: next }</code>, Dart uses nominal classes with <code>@freezed</code> to generate type-safe <code>part.copyWith(quantity: next)</code> and value equality (<code>==</code>).
      </p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/90 border border-gray-800 space-y-1">
      <div class="text-cyan-300 font-mono font-semibold">React.memo() &rarr; Compile-Time const Widgets</div>
      <p class="text-gray-300 m-0">
        Marking a constructor call <code>const MyWidget()</code> canonicalises the widget instance at compile time so Flutter skips rebuilding that subtree in <code>O(1)</code>.
      </p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/90 border border-gray-800 space-y-1">
      <div class="text-cyan-300 font-mono font-semibold">Zustand + TanStack Query &rarr; Riverpod AsyncNotifier</div>
      <p class="text-gray-300 m-0">
        <code>@riverpod class Catalog extends _$Catalog</code> lives inside <code>ProviderScope</code> and exposes <code>AsyncValue&lt;CatalogSnapshot&gt;</code> (<code>AsyncData</code>, <code>AsyncLoading</code>, <code>AsyncError</code>).
      </p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/90 border border-gray-800 space-y-1">
      <div class="text-cyan-300 font-mono font-semibold">React Testing Library &rarr; WidgetTester</div>
      <p class="text-gray-300 m-0">
        <code>tester.pumpWidget(...)</code> + <code>ProviderScope(overrides: [...])</code> runs full UI integration tests headlessly in the Dart VM in milliseconds.
      </p>
    </div>
  </div>

  <div class="p-3 rounded-lg bg-emerald-950/20 border border-emerald-500/30 flex items-center justify-between text-xs">
    <span class="text-gray-200">Open the generated printable cheat sheet directly in your browser:</span>
    <a href="./tutorial/reference/react-to-flutter-cheatsheet.html" target="_blank" class="font-mono font-semibold text-emerald-300 hover:underline">
      tutorial/reference/react-to-flutter-cheatsheet.html &nearr;
    </a>
  </div>
</div>

<!--
Before we even start Lesson 1, /teach-code generates three reference sheets—including this React & TypeScript to Flutter & Dart Cheat Sheet. It maps package.json and tsconfig to pubspec.yaml and analysis_options.yaml, explains why Dart's sound null safety survives at runtime unlike TypeScript's erased types, and maps React.memo, useContext, and TanStack Query directly to const widgets, BuildContext, and Riverpod AsyncNotifier.
-->

---
layout: skill-breakdown
way: 3
title: "Progressive Reconstruction: 5 Verified Lessons & Companion Apps"
---

<!-- S32 -->
<div class="space-y-2.5 text-xs">
  <div class="grid grid-cols-1 gap-2">
    <div class="p-2.5 rounded-lg bg-gray-900/85 border border-gray-800 flex items-center justify-between">
      <div>
        <span class="font-mono text-emerald-400 font-semibold">Lesson 0001:</span>
        <strong class="text-white ml-1">Flutter Bootstrap, ProviderScope &amp; Dark Workbench Shell</strong>
        <span class="text-gray-400 ml-2">&mdash; <code>void main()</code>, <code>StatelessWidget</code>, Material 3 theme &amp; headless <code>testWidgets</code></span>
      </div>
      <a href="./tutorial/lessons/0001-flutter-bootstrap-and-provider-scope.html" target="_blank" class="font-mono text-cyan-300 hover:underline shrink-0 ml-3">Open 0001 &nearr;</a>
    </div>
    <div class="p-2.5 rounded-lg bg-gray-900/85 border border-gray-800 flex items-center justify-between">
      <div>
        <span class="font-mono text-emerald-400 font-semibold">Lesson 0002:</span>
        <strong class="text-white ml-1">Immutable Domain Models with Freezed &amp; JSON Serialisation</strong>
        <span class="text-gray-400 ml-2">&mdash; <code>Part</code>, <code>Container</code>, <code>CatalogSnapshot</code> &amp; 1-to-1 <code>(Container, Slot)</code> lookup</span>
      </div>
      <a href="./tutorial/lessons/0002-immutable-domain-models-with-freezed.html" target="_blank" class="font-mono text-cyan-300 hover:underline shrink-0 ml-3">Open 0002 &nearr;</a>
    </div>
    <div class="p-2.5 rounded-lg bg-gray-900/85 border border-gray-800 flex items-center justify-between">
      <div>
        <span class="font-mono text-emerald-400 font-semibold">Lesson 0003:</span>
        <strong class="text-white ml-1">Persistence Seam &amp; Atomic Local File Storage</strong>
        <span class="text-gray-400 ml-2">&mdash; <code>CatalogPersistence</code> interface, <code>Completer</code> write queue &amp; atomic <code>.tmp</code> rename</span>
      </div>
      <a href="./tutorial/lessons/0003-persistence-seam-and-atomic-file-storage.html" target="_blank" class="font-mono text-cyan-300 hover:underline shrink-0 ml-3">Open 0003 &nearr;</a>
    </div>
    <div class="p-2.5 rounded-lg bg-gray-900/85 border border-gray-800 flex items-center justify-between">
      <div>
        <span class="font-mono text-emerald-400 font-semibold">Lesson 0004:</span>
        <strong class="text-white ml-1">Reactive Catalog State with Riverpod AsyncNotifier</strong>
        <span class="text-gray-400 ml-2">&mdash; <code>upsertPart</code>, slot uniqueness enforcement, cascading delete &amp; <code>ConsumerWidget</code></span>
      </div>
      <a href="./tutorial/lessons/0004-reactive-catalog-state-with-riverpod.html" target="_blank" class="font-mono text-cyan-300 hover:underline shrink-0 ml-3">Open 0004 &nearr;</a>
    </div>
    <div class="p-2.5 rounded-lg bg-gray-900/85 border border-gray-800 flex items-center justify-between">
      <div>
        <span class="font-mono text-emerald-400 font-semibold">Lesson 0005:</span>
        <strong class="text-white ml-1">Engineering Unit Search Engine &amp; Derived Filter Providers</strong>
        <span class="text-gray-400 ml-2">&mdash; Pure SI/EE-infix parser (<code>4k7</code> &harr; <code>4.7k&Omega;</code>) &amp; Dart 3 sealed class pattern matching</span>
      </div>
      <a href="./tutorial/lessons/0005-engineering-unit-search-and-filter-providers.html" target="_blank" class="font-mono text-cyan-300 hover:underline shrink-0 ml-3">Open 0005 &nearr;</a>
    </div>
  </div>
</div>

<!--
And here are the five lessons built during the Comprehension Run, each with its own runnable Flutter companion project under tutorial/apps/ that passes flutter analyze and flutter test. Every single link on this slide is live—hosted right alongside this slide deck on GitHub Pages—so you can click into Lesson 0001 through Lesson 0005, inspect the Mermaid diagrams, and try the interactive retrieval quizzes yourself.
-->

---
layout: default
---

<!-- S33 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">Explore the Hosted Tutorial Portal (<code>/tutorial/</code>)</h2>
</div>

<p class="text-sm text-gray-300 mb-4">
  The complete static HTML output from <code>experiments/parts_tracker_comprehension/tutorial/</code> is published directly under this deck&rsquo;s site:
</p>

<div class="grid grid-cols-2 gap-4">
  <a href="./tutorial/index.html" target="_blank" class="p-4 rounded-xl bg-emerald-950/20 border border-emerald-500/40 hover:border-emerald-400 transition block no-underline">
    <div class="text-xs font-mono text-emerald-400 uppercase">Course Portal Index</div>
    <div class="text-base font-bold text-white mt-1">Flutter &amp; Dart for React + TypeScript Developers &nearr;</div>
    <p class="text-xs text-gray-300 mt-1.5 m-0">
      Full 8-stage roadmap diagram, 5 interactive lessons, collapsible exercise solutions, and retrieval quizzes.
    </p>
  </a>

  <a href="./tutorial/reference/react-to-flutter-cheatsheet.html" target="_blank" class="p-4 rounded-xl bg-gray-900 border border-gray-800 hover:border-cyan-500/50 transition block no-underline">
    <div class="text-xs font-mono text-cyan-400 uppercase">Reference Sheet 1</div>
    <div class="text-base font-bold text-white mt-1">React &amp; TypeScript &rarr; Flutter &amp; Dart Cheat Sheet &nearr;</div>
    <p class="text-xs text-gray-300 mt-1.5 m-0">
      Side-by-side mental model and syntax translation table for JSX, props, hooks, and Riverpod.
    </p>
  </a>

  <a href="./tutorial/reference/glossary.html" target="_blank" class="p-4 rounded-xl bg-gray-900 border border-gray-800 hover:border-cyan-500/50 transition block no-underline">
    <div class="text-xs font-mono text-cyan-400 uppercase">Reference Sheet 2</div>
    <div class="text-base font-bold text-white mt-1">Glossary of Parts Tracker &amp; Flutter Terms &nearr;</div>
    <p class="text-xs text-gray-300 mt-1.5 m-0">
      Ubiquitous domain vocabulary (<code>Part</code>, <code>Spec</code>, <code>Container</code>, <code>Slot</code>) plus Flutter runtime terminology.
    </p>
  </a>

  <a href="./tutorial/reference/verification-and-testing.html" target="_blank" class="p-4 rounded-xl bg-gray-900 border border-gray-800 hover:border-cyan-500/50 transition block no-underline">
    <div class="text-xs font-mono text-cyan-400 uppercase">Reference Sheet 3</div>
    <div class="text-base font-bold text-white mt-1">Verification &amp; Widget Testing Reference &nearr;</div>
    <p class="text-xs text-gray-300 mt-1.5 m-0">
      CLI verification gates (<code>flutter analyze</code>, <code>flutter test</code>) and React Testing Library &rarr; <code>WidgetTester</code> patterns.
    </p>
  </a>
</div>

<!--
We've exposed the entire contents of experiments/parts_tracker_comprehension/tutorial right inside this GitHub Pages site at /tutorial/. You can open the Course Index, the React-to-Flutter Cheat Sheet, the Glossary, or the Verification & Widget Testing Reference—and if you press Cmd+P on any reference sheet, it automatically formats into a crisp, high-contrast printable handout.
-->

---
layout: default
---

<!-- S34 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">Synthesis: Getting Professional Engineering Out of <code>agy</code> &amp; Skills</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-5 leading-relaxed">
  <li>
    <strong class="text-white">Global Rules (<code>~/.gemini/config/AGENTS.md</code>) Stop Premature Code Dumps</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><em>&ldquo;When something is unclear, please ask clarifying questions, one at a time.&rdquo;</em> shifts Gemini from guessing requirements to interviewing you via <code>ask_question</code> across every project.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Workflow Skills (<code>/wayfinder</code>, <code>/prototype</code>, <code>/tdd</code>) Externalize Intent Across <code>/clear</code></strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Reference skills teach syntax, but workflow skills enforce senior engineering habits: committing domain terms (<code>GLOSSARY.md</code>), subagent research, simulator prototypes, and specs to disk so context survives <code>/clear</code>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Pedagogical Skills (<code>/teach-code</code>) Turn Generated Code into Team Mastery</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>When <code>agy</code> builds in a stack you haven&rsquo;t mastered yet, run <code>/teach-code</code> to generate a test-verified course bridged directly from the languages and frameworks you already know.</li>
    </ul>
  </li>
</ol>

<!--
Let's pull the three threads together for your hackathon projects today. The difference between an LLM acting like an impulsive vibe-coder versus a senior engineering partner isn't a secret prompt—it's how you shape the harness with Rules and Skills. First, put a simple Global Rule in ~/.gemini/config/AGENTS.md so agy asks clarifying questions one at a time instead of hallucinating assumptions. Second, install workflow skills like mattpocock/skills—whether you run the full /wayfinder pipeline or cherry-pick /grilling, /research, /prototype, and /code-review after /clear—so your architectural decisions live in git as Intent Artifacts. And third, whenever agy helps you ship in an unfamiliar stack, follow up with /teach-code so you walk onto the demo stage owning both a working app and the mental model behind it.
-->

---
layout: default
---

<!-- S35 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">Take-Home Links &amp; Further Reading</h2>
</div>

<div class="grid grid-cols-2 gap-3.5 mt-3">
  <div class="p-3.5 rounded-xl bg-gray-900 border border-gray-800">
    <div class="flex items-center justify-between">
      <div class="text-xs font-mono text-cyan-400 uppercase tracking-wide">This Deck, Traces &amp; Live Flutter Tutorial</div>
      <span class="text-xs font-mono text-gray-500">GitHub &amp; Pages</span>
    </div>
    <div class="text-sm font-bold font-mono mt-1">
      <a href="https://github.com/domesticmouse/flutter-skills-presentation" target="_blank" class="text-cyan-300 hover:underline">github.com/domesticmouse/flutter-skills-presentation</a>
    </div>
    <p class="text-xs text-gray-400 mt-1 m-0">
      Includes all 3 apps, <code>.cast</code> recordings, 16 session traces, and the live <a href="./tutorial/index.html" target="_blank" class="text-emerald-300 underline">React &rarr; Flutter Tutorial</a>.
    </p>
  </div>

  <div class="p-3.5 rounded-xl bg-gray-900 border border-gray-800">
    <div class="flex items-center justify-between">
      <div class="text-xs font-mono text-amber-400 uppercase tracking-wide">Agent Skill Repositories</div>
      <span class="text-xs font-mono text-gray-500">npx skills add</span>
    </div>
    <div class="text-sm font-bold font-mono mt-1 space-x-2">
      <a href="https://github.com/mattpocock/skills" target="_blank" class="text-amber-300 hover:underline">mattpocock/skills</a>
      <span class="text-gray-600">&middot;</span>
      <a href="https://github.com/domesticmouse/skills" target="_blank" class="text-emerald-300 hover:underline">domesticmouse/skills</a>
    </div>
    <p class="text-xs text-gray-400 mt-1 m-0">
      <code>/wayfinder</code>, <code>/grilling</code>, <code>/domain-modeling</code>, <code>/prototype</code>, <code>/tdd</code>, <code>/teach-code</code>, and <code>/slidev-deck</code>.
    </p>
  </div>

  <div class="p-3.5 rounded-xl bg-gray-900 border border-gray-800">
    <div class="flex items-center justify-between">
      <div class="text-xs font-mono text-emerald-400 uppercase tracking-wide">Prior /teach-code Example 1</div>
      <span class="text-xs font-mono text-gray-500">Rust GUI</span>
    </div>
    <div class="text-sm font-bold font-mono mt-1">
      <a href="https://domesticmouse.github.io/learn-egui/" target="_blank" class="text-emerald-300 hover:underline">domesticmouse.github.io/learn-egui/</a>
    </div>
    <p class="text-xs text-gray-400 mt-1 m-0">
      Complete multi-lesson <code>/teach-code</code> course teaching Rust immediate-mode GUI development with <code>egui</code>.
    </p>
  </div>

  <div class="p-3.5 rounded-xl bg-gray-900 border border-gray-800">
    <div class="flex items-center justify-between">
      <div class="text-xs font-mono text-purple-400 uppercase tracking-wide">Prior /teach-code Example 2</div>
      <span class="text-xs font-mono text-gray-500">Electronics CAD</span>
    </div>
    <div class="text-sm font-bold font-mono mt-1">
      <a href="https://domesticmouse.github.io/BufferedMult-SKiDL/" target="_blank" class="text-purple-300 hover:underline">domesticmouse.github.io/BufferedMult-SKiDL/</a>
    </div>
    <p class="text-xs text-gray-400 mt-1 m-0">
      Multi-lesson <code>/teach-code</code> course teaching Python-driven electronics schematic CAD and Eurorack hardware design with SKiDL.
    </p>
  </div>
</div>

<!--
Thank you all so much! All of the code, the raw and time-warped asciinema recordings, the exported Antigravity session traces, and the live React-to-Flutter tutorial are up on GitHub right now. I've also linked two other full courses generated with /teach-code—one for learning Rust GUI programming with egui, and one for designing Eurorack synth schematics in Python with SKiDL. Let's open it up for questions!
-->
