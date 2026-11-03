---
layout: center
class: text-center
---

<!-- S08 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 1: The Baseline Run
  </h1>
  <p class="text-xl font-mono text-cyan-300">
    parts_tracker_baseline &middot; 01-baseline.cast
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Building the electronics parts tracker with the Global Rule active and zero project-level skills installed
  </p>
</div>

<!--
Let's step into Act 1: The Baseline Run. Here we create a clean Flutter iOS project, parts_tracker_baseline, outside our presentation repo so no project-level skills leak in, and we launch agy.
-->

---
layout: default
---

<!-- S09 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">Baseline Run: Three One-at-a-Time Clarifying Questions</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-5 leading-relaxed">
  <li>
    <strong class="text-white">Question 1 (Step 5): Core Features &amp; Capabilities</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><code>agy</code> presents a multi-select checklist of features.</li>
      <li>We select all 4: <strong>Part Catalog &amp; Specs</strong>, <strong>Storage Locations</strong>, <strong>Stock &amp; Low-Stock Alerts</strong>, and <strong>Search &amp; Category Filtering</strong>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Question 2 (Step 7): Data Storage &amp; Backup</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><code>agy</code> asks whether we want local on-device storage, local + JSON/CSV import-export, or cloud sync.</li>
      <li>We select: <strong>Local storage + JSON/CSV import &amp; export</strong>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Question 3 (Step 9): Visual Style &amp; Theme</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>We select: <strong>Modern Material 3 (Dark &amp; Light mode)</strong> with category colour badges and dashboard cards.</li>
    </ul>
  </li>
</ol>

<!--
Because of our Global Rule, agy doesn't write a single line of Dart until it asks three concise multiple-choice questions via ask_question. First, which core features do we want? Second, how should data be stored and backed up on the device? Third, what visual style should it use? Once we answer those three questions, agy goes to work for fourteen minutes. Let's watch the recording.
-->

---
layout: cast-full
cast: /casts/01-baseline.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S10 -->
<!--
Here is the complete 33-minute Baseline Run terminal recording compressed into two and a half minutes across 15 adaptive-speed segments. We can use the bracket keys to step between chapter stop points—creating the Flutter project, launching agy, answering the three clarifying questions, watching the 29x time-warped build, running the app on the iOS Simulator, and then issuing /clear to run a fresh codebase review.
-->

---
layout: hardware-callout
title: "Baseline Run iOS App: Inventory & Part Detail"
image: /images/baseline-01-parts-inventory.png
imageCaption: "01-parts-inventory.png — 8 sample parts, dashboard summary cards & category filter chips"
---

<!-- S11 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-cyan-300">Impressive First-Pass UI Generation</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    In a single session (<code>19m 36s</code>, <code>94</code> steps, <code>21</code> files written), <code>agy</code> produces a clean Material 3 app pre-populated with 8 realistic maker parts (<code>ESP32-WROOM-32E</code>, <code>0.96" I2C OLED</code>, <code>10k&Omega; SMD Resistor</code>).
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>Top Dashboard Metrics:</strong> Total parts, unit count (<code>434</code>), restock count (<code>3</code>), and estimated inventory value (<code>$42</code>).</li>
    <li><strong>Quick Stock Adjustments:</strong> Inline <code>-</code> / <code>+</code> buttons on every card plus a detail view with <code>-10</code>, <code>-1</code>, <code>+1</code>, and <code>+10</code> buttons.</li>
    <li><strong>Paper-Cut UI Polish Bug:</strong> Because no visual prototype was inspected during planning, the <code>+10</code> button on the Part Detail screen wraps awkwardly across two lines (<code>+1</code> / <code>0</code>).</li>
  </ul>
</div>

<!--
Look at what came out of that single nineteen-minute session. Honestly, if you stopped right here for a demo, you'd be thrilled. We have a summary dashboard at the top, category chips, search, and eight realistic maker components pre-populated. Though if you look closely at the Part Detail screen, the +10 stock button is slightly too narrow and wraps the zero onto a second line.
-->

---
layout: hardware-callout
title: "Baseline Run iOS App: Locations, Restock & Backup"
image: /images/baseline-04-storage-locations.png
imageCaption: "04-storage-locations.png — Flat string locations ('Cabinet A - Drawer 2')"
---

<!-- S12 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-cyan-300">Where Untested Domain Assumptions Hide</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    Because <code>agy</code> never modelled the physical workbench domain with us, it made silent structural trade-offs inside <code>lib/models/part_item.dart</code>:
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>Flat String Storage Location:</strong> A part&rsquo;s location is just a single freeform string (<code>"Cabinet A - Drawer 2"</code>) rather than a structured <code>(Container, Slot)</code> hierarchy.</li>
    <li><strong>No Slot Collision Prevention:</strong> Two completely different parts can be assigned to the exact same SMD binder strip without warning.</li>
    <li><strong>Clipboard-Only Backup Sheet:</strong> Export &amp; Import copies raw JSON or CSV text to the clipboard rather than integrating with the native iOS Share Sheet or Files app.</li>
  </ul>
</div>

<!--
When we switch to the Locations tab, we start to see the architectural shortcuts that happen when an agent jumps straight from three high-level multiple-choice questions into writing widgets. Storage location is modelled as a single flat string—"Cabinet A - Drawer 2". There is no concept of a Container versus a Slot, and nothing stops you from putting three different resistor values into the exact same slot.
-->

---
layout: skill-breakdown
way: 1
title: "Session Trace 01: What the Agent Did Under the Hood"
---

<!-- S13 -->
<div class="space-y-4">

```text
Session 01 (06523dd6) · Duration: 19m 36s · Steps: 94 · Tool Calls: 48
├── ask_question: 3   (Steps 5, 7, 9 — triggered by Global Rule)
├── read_file:    9   (Read 5 global Flutter plugin skills in ~/.gemini/config/plugins/flutter/)
├── write_file:  21   (Created lib/models/, lib/repositories/, lib/view_models/, lib/ui/)
├── edit_file:    7   (Fixed widget_test.dart and lints)
└── run_command:  8   (flutter pub add, flutter analyze, flutter test, flutter run)
```

  <div class="grid grid-cols-2 gap-4 text-xs pt-2">
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-cyan-300 font-semibold">Auto-Loaded Flutter Plugin Skills</div>
      <p class="text-gray-300 leading-relaxed m-0">
        Even without project skills, <code>agy</code> read <code>flutter-apply-architecture-best-practices</code> and <code>flutter-implement-json-serialization</code> from the global Flutter plugin, giving it a clean MVVM folder layout.
      </p>
    </div>
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-amber-300 font-semibold">Zero Repo-Committed Intent Artifacts</div>
      <p class="text-gray-300 leading-relaxed m-0">
        No <code>GLOSSARY.md</code>, no specification, no architecture decision records, and only a single smoke test in <code>test/widget_test.dart</code>.
      </p>
    </div>
  </div>
</div>

<!--
Using our agy-brain-explorer skill, we extracted the full Session Trace from ~/.gemini/antigravity/brain/. In Session 01, agy executed 94 steps and 48 tool calls. Notice something fascinating in the read_file calls: Antigravity automatically consulted five skills from the global Flutter plugin—which is why it organised the code into models, repositories, and view_models. Yet it wrote zero documentation or Intent Artifacts to the repository.
-->

---
layout: skill-breakdown
way: 2
title: "Session Trace 02: What Happens After /clear + 'Please review the codebase'"
---

<!-- S14 -->
<div class="space-y-3">
  <p class="text-xs text-gray-300 m-0">
    Immediately after running the app, we typed <code>/clear</code> to wipe short-term memory and asked <code>Please review the codebase</code>. In <code>81</code> steps (<code>26</code> <code>edit_file</code> calls), <code>agy</code> found and fixed <strong>8 bugs in its own freshly generated code</strong>:
  </p>

  <div class="grid grid-cols-2 gap-3 text-xs">
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-amber-300 font-semibold">1. Domain &harr; UI Layer Violation</div>
      <p class="text-gray-300 m-0"><code>part_item.dart</code> imported <code>package:flutter/material.dart</code> to embed <code>IconData</code> and <code>Color</code> directly inside the domain model.</p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-amber-300 font-semibold">2. Broken iOS Sandbox Path Resolution</div>
      <p class="text-gray-300 m-0"><code>local_storage_service.dart</code> used <code>Platform.environment['HOME']</code> instead of <code>path_provider</code>, which fails on physical iOS devices.</p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-amber-300 font-semibold">3. Silent Data Loss on Corrupt JSON</div>
      <p class="text-gray-300 m-0">A malformed JSON file silently fell back to <code>SampleParts.initialParts</code> and overwrote the user&rsquo;s inventory on the next save.</p>
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1">
      <div class="text-amber-300 font-semibold">4. Unserialized Concurrent File Writes</div>
      <p class="text-gray-300 m-0">Rapidly tapping <code>+1</code> / <code>-1</code> triggered unawaited overlapping <code>File.writeAsString</code> calls with no write queue or atomic temp rename.</p>
    </div>
  </div>
</div>

<!--
And here is the kicker. Right after the app launched on the simulator, we typed /clear to start a fresh session and simply prompted: "Please review the codebase." Without any context bias from having just written the code, agy audited its own work and found eight genuine bugs—including a broken iOS sandbox file path using Platform.environment['HOME'], silent data wipe if the JSON file was ever corrupted, and concurrent file-write race conditions when tapping the stock stepper buttons rapidly!
-->

---
layout: default
---

<!-- S15 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">The Baseline Run Verdict: Working Code, Total Amnesia</h2>
</div>

<div class="grid grid-cols-2 gap-6 mt-6">
  <div class="p-5 rounded-xl bg-emerald-950/15 border border-emerald-500/30 space-y-3">
    <div class="text-xs font-mono text-emerald-400 uppercase">What Was Generated on Disk</div>
    <h3 class="text-lg font-bold text-white">21 Dart Files That Compile &amp; Run</h3>
    <ul class="text-xs text-gray-300 space-y-2 list-disc pl-4">
      <li>Functional Material 3 UI with search, category filters, and stock steppers.</li>
      <li>Clean directory layout courtesy of global Flutter plugin skills.</li>
      <li><strong>Result:</strong> Looks great in a screenshot or a 5-minute demo.</li>
    </ul>
  </div>

  <div class="p-5 rounded-xl bg-red-950/15 border border-red-500/30 space-y-3">
    <div class="text-xs font-mono text-red-400 uppercase">What Evaporated at /clear</div>
    <h3 class="text-lg font-bold text-white">Zero Durable Intent Artifacts</h3>
    <ul class="text-xs text-gray-300 space-y-2 list-disc pl-4">
      <li><strong>No Ubiquitous Language:</strong> Is a storage spot a <code>location</code>, a <code>bin</code>, a <code>Container</code>, or a <code>Slot</code>?</li>
      <li><strong>No Spec or Decision Map:</strong> Every product trade-off vanished into the closed chat transcript.</li>
      <li><strong>Result:</strong> High <strong>Comprehension Debt</strong> for the human—and zero architectural memory for the next agent session.</li>
    </ul>
  </div>
</div>

<!--
So that's the Baseline Run verdict. We got twenty-one Dart files that compile and run on iOS. But the moment we typed /clear, every product decision, domain term, and edge-case constraint evaporated. Both the next AI session and the human developer are left reverse-engineering intent from raw widget code. How do we fix that? Let's look at Act 2.
-->
