---
layout: center
class: text-center
---

<!-- S16 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 2: The Skilled Run
  </h1>
  <p class="text-xl font-mono text-cyan-300">
    parts_tracker_skilled &middot; mattpocock/skills &middot; 02-skilled.cast
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Turning the agent into a design partner that produces durable Intent Artifacts before writing production widgets
  </p>
</div>

<!--
Welcome to Act 2: The Skilled Run. We start from the exact same empty Flutter iOS template, but before launching agy, we run one command: npx skills@latest add mattpocock/skills.
-->

---
layout: default
---

<!-- S17 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Matt Pocock Skill Chain: Designing Across <code>/clear</code> Boundaries</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-5 leading-relaxed">
  <li>
    <strong class="text-white"><code>/wayfinder</code> &mdash; Chart &amp; Work the Map Across Sessions</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Instead of 3 surface questions, <code>/wayfinder</code> creates <code>GLOSSARY.md</code>, <code>.scratch/parts-tracker-v1/map.md</code>, and 7 focused child tickets (<code>/grilling</code>, <code>/research</code>, <code>/prototype</code>).</li>
      <li>Each ticket is resolved in its own fresh conversation separated by <code>/clear</code>—because the state lives on disk in Markdown, not in the context window!</li>
    </ul>
  </li>
  <li>
    <strong class="text-white"><code>/to-spec</code> &amp; <code>/to-tickets</code> &mdash; Lock Deep Modules &amp; Vertical Slices</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Synthesises the 7 resolved tickets into <code>.scratch/parts-tracker-v1/spec.md</code> and breaks implementation into 5 tracer-bullet vertical slices.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white"><code>/implement</code> &mdash; Red-Green-Refactor TDD &amp; Parallel <code>/code-review</code></strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Builds each slice test-first and dispatches parallel subagents to audit <strong>Standards</strong> and <strong>Spec Compliance</strong>.</li>
    </ul>
  </li>
</ol>

<!--
Instead of trying to cram requirements, architecture, UI design, and coding into one giant context window, Matt Pocock's skill chain treats the filesystem as the agent's long-term memory. Wayfinder interviews us to chart a map of seven open questions—some requiring grilling, one requiring empirical API research, and one requiring a throwaway UI prototype. After resolving each ticket, we type /clear! Because the decisions are written to GLOSSARY.md and .scratch/parts-tracker-v1/map.md, the next session picks up with a clean context window and zero amnesia.
-->

---
layout: cast-full
cast: /casts/02-skilled.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S18 -->
<!--
Here is the Skilled Run recording. In raw wall-clock time, walking all seven Wayfinder sessions, building three live UI prototypes, compiling the spec, and running vertical-slice TDD took two hours—which our adaptive player compresses into six minutes across 17 chapter stop points. Notice how we can jump directly to Stop Point 4 (Charting the Map), Stop Point 7 (Running the UI Prototypes), Stop Point 11 (/to-spec), or Stop Point 13 (/implement).
-->

---
layout: skill-breakdown
way: 2
skill: experiments/parts_tracker_skilled/GLOSSARY.md
title: "Intent Artifact 1: Ubiquitous Domain Language (/domain-modeling)"
step: Intent Artifact 1 of 3
---

<!-- S19 -->
<div class="space-y-4">
  <div class="p-4 rounded-lg bg-gray-950/90 border border-gray-800 space-y-2.5 text-xs text-gray-200 leading-relaxed">
    <div>
      <strong class="text-white">Part</strong>: A distinct electronic component entry in the catalog (e.g., <code>10k&Omega; 0603 1% Resistor</code>, <code>NE555P</code>), tracking a single quantity on hand, an optional <code>(Container, Slot)</code> location, package/footprint, optional LCSC code (<code>Cxxxxxx</code>), and electrical <strong class="text-white">Specs</strong>.
    </div>
    <div>
      <strong class="text-white">Container</strong>: A top-level physical storage unit at the workbench (e.g., <code>"SMD Binder #1"</code>, <code>"IC Drawer Cabinet"</code>).
    </div>
    <div>
      <strong class="text-white">Slot</strong>: A named compartment, drawer, or strip inside a <strong class="text-white">Container</strong> (e.g., <code>"A1"</code>, <code>"Page 4"</code>). A <strong class="text-white">Slot</strong> holds at most one <strong class="text-white">Part</strong> (<code>(Container, Slot)</code> is strictly 1-to-1 when a Slot is specified).
    </div>
  </div>

  <div class="grid grid-cols-2 gap-4 text-xs pt-1">
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-amber-300 font-semibold">Precision Over Vague Strings:</span> Instead of a flat <code>location</code> string, <code>GLOSSARY.md</code> locks in a 2-level <code>(Container, Slot)</code> hierarchy with a strict 1-to-1 slot uniqueness invariant.
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-amber-300 font-semibold">Enforced Across Code &amp; Tests:</span> Every subsequent session reads <code>GLOSSARY.md</code> first, so model classes, UI labels, and unit tests use identical terminology.
    </div>
  </div>
</div>

<!--
Look at our first Intent Artifact committed to the repo: GLOSSARY.md. During the Wayfinder interview, the domain-modeling skill forced us to sharpen our vocabulary. What is a storage location on an electronics bench? It's a two-level hierarchy: a physical Container—like "SMD Binder #1" or "IC Drawer Cabinet"—and a Slot inside that container, with a strict invariant that a Slot holds at most one Part. That single invariant shapes the database schema, the UI form validation, and the unit tests.
-->

---
layout: skill-breakdown
way: 2
skill: .scratch/parts-tracker-v1/map.md · Session 02 (0b4fb5bb)
title: "Intent Artifact 2: Wayfinder Map & Empirical Subagent Research"
step: Intent Artifact 2 of 3
---

<!-- S20 -->
<div class="space-y-4">
  <div class="p-4 rounded-lg bg-gray-950/90 border border-gray-800 space-y-2 text-xs text-gray-200 leading-relaxed">
    <div class="text-sm font-bold text-white border-b border-gray-800 pb-1.5">
      Decisions so far <span class="text-xs font-mono font-normal text-gray-400">(.scratch/parts-tracker-v1/map.md)</span>
    </div>
    <ul class="list-disc pl-5 space-y-1.5 m-0">
      <li>
        <code>01-lcsc-part-metadata-lookup.md</code>: Official LCSC API requires B2B approval + IP whitelisting; verified via <code>curl</code> that <code>GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx</code> returns live JSON (MPN, manufacturer, package, <code>paramVOList</code> specs, <code>pdfUrl</code>) with a standard <code>User-Agent</code>.
      </li>
      <li>
        <code>02-part-domain-model-and-specs.md</code> &hellip; <code>07-flutter-state-management-and-architecture.md</code>
      </li>
    </ul>
  </div>

  <div class="grid grid-cols-2 gap-4 text-xs pt-1">
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-amber-300 font-semibold">Delegating to <code>/research</code> (Session 02):</span> Instead of guessing whether LCSC has a public API, Session 01 spawned a background research subagent (<code>31</code> web searches + <code>9</code> live <code>curl</code> tests).
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-amber-300 font-semibold">Empirical Engineering:</span> The subagent proved that entering an LCSC code like <code>C2878713</code> can auto-populate MPN, package, electrical specs, and PDF datasheet URL live!
    </div>
  </div>
</div>

<!--
Here is the second Intent Artifact: .scratch/parts-tracker-v1/map.md. Notice Ticket 01 on the map. When I mentioned I buy parts from LCSC and every bag has a C-code printed on it, the Baseline Run completely ignored supplier API integration. In the Skilled Run, Wayfinder created a research ticket and spawned a background subagent. We can see in Session Trace 02 that the subagent ran 31 web searches and 9 live curl commands to discover an unauthenticated JSON endpoint on wmsc.lcsc.com that returns full electrical parameters and PDF datasheet links for any C-code!
-->

---
layout: hardware-callout
title: "Throwaway UI Exploration with /prototype (Session 04)"
subtitle: "lib/prototype_workbench.dart · Variant A vs. Variant B vs. Variant C"
image: /images/skilled-OptionA.png
imageCaption: "OptionA.png — Variant A: Split Tabs & Dense Stepper Rows ('Workbench Catalog')"
---

<!-- S21 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-amber-300">Testing 3 Live Layouts Before Locking the Spec</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    Instead of committing blindly to the first UI layout the LLM thinks of, Ticket <code>04</code> invoked <code>/prototype</code> to build three switchable workbench paradigms inside a single throwaway file:
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>Variant A (Left):</strong> Light-theme dense table with bottom tabs (<code>Parts (7)</code>, <code>Storage (3)</code>) and inline <code>- / +</code> pills.</li>
    <li><strong>Variant B:</strong> Dark command-bar omnibox with collapsible inline spec accordions and a <code>Group by Container</code> toggle.</li>
    <li><strong>Variant C:</strong> Visual 2-column physical storage slot matrix grouped by bench container.</li>
  </ul>
</div>

<!--
Then we hit Ticket 04 on the Wayfinder map: what should the workbench UI actually feel like? Instead of guessing in prose, the /prototype skill built all three candidate UI layouts in a single throwaway file with a floating variant switcher at the bottom, and launched it on the iOS Simulator so we could tap around live.
-->

---
layout: hardware-callout
title: "Locking Variant B: Dark Command Bar & Inline Accordion"
subtitle: "artifacts/screenshots/parts_tracker_skilled/OptionB.png"
image: /images/skilled-OptionB.png
imageCaption: "OptionB.png — Selected prototype: Dark Command Bar & Inline Spec Accordion"
---

<!-- S22 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-emerald-300">Why Prototyping on Simulator Paid Off Immediately</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    Trying all three variants on the booted iOS Simulator revealed two things we would never have caught in text:
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>Single-Screen Flow Wins at the Bench:</strong> Toggling <code>By Container</code> on the command bar beat switching bottom tabs back and forth while sorting physical parts.</li>
    <li><strong>Caught Layout Overflows Early:</strong> In Session 04, <code>agy</code> used the Flutter MCP widget inspector (<code>get_runtime_errors</code>) to catch and fix a <code>RenderFlex</code> chip overflow before writing production UI code.</li>
  </ul>
</div>

<!--
Playing with the three prototypes on the simulator made the decision obvious within thirty seconds. Variant B—the dark command bar with inline expandable accordions and a single-tap "By Container" grouping toggle—felt like a real hardware workbench tool. Better yet, while running the prototype, Antigravity used the Dart & Flutter MCP server to inspect runtime layout errors and caught a RenderFlex overflow before we wrote a single line of production architecture.
-->

---
layout: skill-breakdown
way: 2
skill: .scratch/parts-tracker-v1/spec.md · /implement (Session 08)
title: "Intent Artifact 3: Deep Module Seams & Vertical-Slice TDD"
step: Intent Artifact 3 of 3
---

<!-- S23 -->
<div class="space-y-4">

```text
lib/
├── catalog/   Catalog (Riverpod AsyncNotifier) + CatalogPersistence seam (atomic .tmp rename + write queue)
├── lcsc/      LcscClient over injected http.Client (unauthenticated C-code metadata & paramVOList parser)
├── search/    PartSearchEngine (pure SI & EE-infix normaliser: "4k7" == "4.7kΩ" == "4700R", "0.1uF" == "100nF")
└── ui/        Dark Material 3 WorkbenchScreen + inline accordions + LCSC-first AddOrEditPartSheet
```

  <div class="grid grid-cols-2 gap-4 text-xs pt-1">
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-emerald-300 font-semibold">27 Automated Tests Across 4 Suites:</span> <code>catalog_store_test.dart</code>, <code>lcsc_client_test.dart</code>, <code>part_search_engine_test.dart</code>, and <code>widget_test.dart</code> verify every invariant headlessly.
    </div>
    <div class="p-3 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-emerald-300 font-semibold">Parallel 2-Axis <code>/code-review</code> (Sessions 09–13):</span> Separate subagents audited <strong>Coding Standards</strong> and <strong>Spec Compliance</strong> both during <code>/implement</code> and after a final <code>/clear</code>.
    </div>
  </div>
</div>

<!--
Once all seven Wayfinder tickets were closed, /to-spec and /to-tickets synthesised our third major Intent Artifact: a locked specification built around three deep modules—CatalogPersistence with atomic temp-file writes, LcscClient, and a pure PartSearchEngine that understands electronics shorthand so searching "4k7" matches "4.7kΩ" and "0.1uF" matches "100nF". Then /implement built all five vertical slices using strict red-green-refactor TDD, producing 27 automated tests and dispatching parallel subagents to review the code against both our coding standards and the spec.
-->

---
layout: hardware-callout
title: "Skilled Run iOS App: Workbench & Inline Spec Accordion"
subtitle: "parts_tracker_skilled · Final Production Build"
image: /images/skilled-01-workbench-catalog.png
imageCaption: "01-workbench-catalog.png — Variant B dark workbench with expanded 4.7kΩ 0603 inline accordion"
---

<!-- S24 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-emerald-300">Purpose-Built for an Electronics Lab</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    Compare this final production UI against the Baseline Run:
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>Unit-Aware Omnibox:</strong> Typing <code>4k7 0603</code> in the top search bar normalises engineering units (<code>4.7k&Omega;</code>) and intersects package tokens in real time.</li>
    <li><strong>Inline Accordion &amp; Spec Pills:</strong> Tapping a part reveals structured electrical <strong>Specs</strong> (<code>Resistance: 4.7k&Omega;</code>, <code>Tolerance: &plusmn;1%</code>, <code>Power: 100mW</code>) and clean, single-line <code>-10</code> / <code>-1</code> / <code>+1</code> / <code>+10</code> steppers.</li>
    <li><strong>12 Realistic Seed Parts Across 4 Containers:</strong> Pre-populated with LCSC codes, MPNs, and structured <code>(Container, Slot)</code> addresses.</li>
  </ul>
</div>

<!--
Here is the finished Skilled Run app running on the iOS Simulator. Look at the difference in domain fit. The top command bar searches across normalized engineering units—so typing "4k7" finds our 4.7kΩ 0603 resistor. Expanding a card inline reveals structured electrical specs and clean single-line stock adjustment buttons.
-->

---
layout: hardware-callout
title: "Skilled Run iOS App: Live LCSC Lookup & Container Hierarchy"
subtitle: "parts_tracker_skilled · Live API Fetch & 2-Level Storage"
image: /images/skilled-03-add-part-lcsc-lookup.png
imageCaption: "03-add-part-lcsc-lookup.png — Live LCSC fetch for C2878713 (TL074HIDR Op-Amp by TI)"
---

<!-- S25 -->
<div class="space-y-4">
  <h3 class="text-lg font-bold text-emerald-300">Features Born Directly from Wayfinder &amp; Research</h3>
  <p class="text-sm text-gray-300 leading-relaxed">
    Every workflow we explored during <code>/wayfinder</code> is wired end-to-end:
  </p>
  <ul class="text-sm text-gray-300 space-y-2 list-disc pl-5">
    <li><strong>One-Tap LCSC Metadata Fetch:</strong> Typing <code>C2878713</code> and tapping <code>Fetch LCSC</code> pulls <code>TL074HIDR</code>, <code>TI</code>, <code>SOIC-14</code>, electrical specs, and the official PDF datasheet URL live.</li>
    <li><strong>Structured <code>(Container, Slot)</code> Pickers:</strong> Enforces 1-to-1 slot uniqueness with a <code>By Container</code> workbench view and dedicated container manager sheet.</li>
    <li><strong>Native iOS Share Sheet &amp; Validated Import:</strong> Exports timestamped JSON backups via <code>share_plus</code> and validates referential integrity before import.</li>
  </ul>
</div>

<!--
And look at the Add Part sheet on the left: we typed C2878713, tapped Fetch LCSC, and it immediately populated the Texas Instruments TL074HIDR quad op-amp, its SOIC-14 footprint, its electrical parameters, and the direct link to the PDF datasheet—all because our Wayfinder research subagent tested that endpoint during planning.
-->

---
layout: default
---

<!-- S26 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">Baseline Run vs. Skilled Run &mdash; By the Numbers</h2>
</div>

<div class="grid grid-cols-2 gap-6 mt-5">
  <div class="p-5 rounded-xl bg-red-950/15 border border-red-500/30 space-y-2.5">
    <div class="text-xs font-mono text-red-400 uppercase">Run 1: Baseline Run (Global Rule Only)</div>
    <h3 class="text-lg font-bold text-white">Fast Code, Ephemeral Intent</h3>
    <ul class="text-xs text-gray-300 space-y-1.5 list-disc pl-4">
      <li><strong>Sessions:</strong> 2 CLI sessions (<code>175</code> total steps).</li>
      <li><strong>Clarifying Questions:</strong> 3 broad multiple-choice prompts.</li>
      <li><strong>Intent Artifacts on Disk:</strong> <code>0</code> (no glossary, no map, no spec).</li>
      <li><strong>UI Prototyping:</strong> <code>0</code> (first guess shipped directly to production).</li>
      <li><strong>Automated Tests:</strong> <code>1</code> basic smoke test.</li>
      <li><strong>Post-<code>/clear</code> Review:</strong> Found 8 bugs (sandbox path, race conditions, data loss on corrupt JSON).</li>
    </ul>
  </div>

  <div class="p-5 rounded-xl bg-emerald-950/15 border border-emerald-500/30 space-y-2.5">
    <div class="text-xs font-mono text-emerald-400 uppercase">Run 2: Skilled Run (mattpocock/skills)</div>
    <h3 class="text-lg font-bold text-white">Deliberate Design, Durable Architecture</h3>
    <ul class="text-xs text-gray-300 space-y-1.5 list-disc pl-4">
      <li><strong>Sessions:</strong> 8 CLI sessions + 5 subagent runs (<code>845</code> total steps).</li>
      <li><strong>Clarifying Questions:</strong> 30 targeted <code>/grilling</code> questions across 7 tickets.</li>
      <li><strong>Intent Artifacts on Disk:</strong> <code>GLOSSARY.md</code>, <code>map.md</code>, 7 decision tickets, <code>spec.md</code>, 5 vertical-slice tickets.</li>
      <li><strong>UI Prototyping:</strong> 3 live interactive variants tested on iOS Simulator.</li>
      <li><strong>Automated Tests:</strong> <code>27</code> unit &amp; widget tests across 4 suites.</li>
      <li><strong>Post-<code>/clear</code> Review:</strong> Parallel 2-axis subagents verified spec &amp; standards.</li>
    </ul>
  </div>
</div>

<!--
When we put the Session Traces side by side, the contrast is stark. Yes, the Skilled Run took more turns and more tokens—8 top-level sessions and 5 subagent runs compared to 2 sessions in the Baseline Run. But look at what we own at the end: a ubiquitous glossary, an empirical API integration, a simulator-tested UI layout, 27 automated tests across three deep module seams, and durable Intent Artifacts committed to git. Which leaves just one problem left to solve: the code is great, but *we* still don't know Flutter!
-->
