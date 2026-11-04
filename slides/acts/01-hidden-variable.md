---
class: text-center
---

<!-- S01 -->
<div class="h-full flex flex-col items-center justify-center">
  <h1 class="text-5xl font-extrabold tracking-tight text-white mb-3">
    Shaping AI Coding Agents with Skills
  </h1>
  <p class="text-2xl text-gray-300 font-light max-w-3xl">
    From <strong class="text-cyan-300 font-semibold">Comprehension Debt</strong> to Design Partner (<code class="text-amber-300">/wayfinder</code>) and Personal Tutor (<code class="text-emerald-300">/teach-code</code>) in Flutter
  </p>
  <div class="mt-7 flex items-center justify-center gap-8">
    <div class="flex flex-col items-center sm:items-start text-left">
      <div class="text-gray-400 text-base">
        <span class="font-semibold text-gray-200">Brett Morgan</span> &middot; Developer Relations, Google Cloud
      </div>
      <div class="mt-4 flex flex-col gap-2.5 text-xs font-mono">
        <a href="https://domesticmouse.github.io/flutter-skills-presentation/" target="_blank" class="px-3 py-1.5 rounded-lg bg-cyan-950/40 border border-cyan-500/40 text-cyan-300 hover:underline">
          domesticmouse.github.io/flutter-skills-presentation &nearr;
        </a>
        <a href="https://github.com/domesticmouse/flutter-skills-presentation" target="_blank" class="px-3 py-1.5 rounded-lg bg-gray-900 border border-gray-700 text-gray-300 hover:underline">
          github.com/domesticmouse/flutter-skills-presentation
        </a>
        <a href="./tutorial/index.html" target="_blank" class="px-3 py-1.5 rounded-lg bg-emerald-950/40 border border-emerald-500/40 text-emerald-300 hover:underline">
          Interactive React &rarr; Flutter Tutorial &nearr;
        </a>
      </div>
      <div class="mt-4 text-xs text-gray-500">
        Press <kbd>Space</kbd> or <kbd>&rarr;</kbd> to advance
      </div>
    </div>
    <a href="https://domesticmouse.github.io/flutter-skills-presentation/" target="_blank" class="flex flex-col items-center gap-1.5 p-2.5 rounded-xl bg-gray-900/80 border border-gray-700/80 shadow-lg hover:border-cyan-500/50 transition no-underline">
      <img src="/images/qrcode_domesticmouse.github.io.png" alt="QR Code for Live Presentation Deck" class="w-36 h-36 rounded-lg bg-white p-1 object-contain" />
      <span class="text-[11px] font-mono text-cyan-300 tracking-wide">Scan for Live Deck</span>
    </a>
  </div>
</div>

<!--
G'day everyone! Today we are going to look at what actually happens when you hand an AI coding agent a terse prompt for an app in a framework you haven't mastered yet. More importantly, we're going to explore how small, composable markdown files—Rules and Agent Skills—completely reshape how that agent collaborates with you.
-->

---
layout: default
---

<!-- S02a -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Core Thesis &mdash; Part 1: The Trap</h2>
</div>

<div class="flex flex-col justify-between gap-6 p-7 rounded-2xl bg-red-950/15 border border-red-500/30">
  <div class="text-xs font-mono text-red-400 uppercase tracking-widest">
    Out-of-the-Box Coding Agent
  </div>

  <div class="text-3xl font-extrabold text-white tracking-tight leading-snug max-w-4xl">
    An unshaped agent will happily generate a working app in a framework you don&rsquo;t know&mdash;and hand you a pile of <span class="text-red-400">Comprehension Debt</span>.
  </div>

  <div class="grid grid-cols-3 gap-4 pt-5 border-t border-red-500/20 text-sm">
    <div class="p-3.5 rounded-xl bg-gray-950/70 border border-gray-800">
      <div class="text-red-300 font-bold mb-1">15 Minutes to &ldquo;Working&rdquo;</div>
      <div class="text-gray-300 text-xs leading-relaxed">2,000+ lines of generated code that compiles and runs on the first try.</div>
    </div>
    <div class="p-3.5 rounded-xl bg-gray-950/70 border border-gray-800">
      <div class="text-red-300 font-bold mb-1">Zero Intent Artifacts</div>
      <div class="text-gray-300 text-xs leading-relaxed">Every architectural trade-off evaporates the moment you run <code>/clear</code>.</div>
    </div>
    <div class="p-3.5 rounded-xl bg-gray-950/70 border border-gray-800">
      <div class="text-red-300 font-bold mb-1">Zero Mental Model</div>
      <div class="text-gray-300 text-xs leading-relaxed">You own the bugs in production, but not the domain seams to fix them.</div>
    </div>
  </div>
</div>

<!--
Here is the first half of our core thesis. Out of the box, modern coding agents are almost too eager to please. Give them a one-line prompt in a language or framework you don't know, and they will hand you a working app in fifteen minutes—along with a massive pile of Comprehension Debt. You have two thousand lines of code that runs on the simulator, but zero Intent Artifacts in the repo and zero mental model when you need to maintain it.
-->

---
layout: default
---

<!-- S02b -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Core Thesis &mdash; Part 2: The Antidote</h2>
</div>

<div class="text-2xl font-semibold text-gray-200 leading-snug mb-6">
  Shaping the agent with rules and Agent Skills (<code class="text-cyan-300">SKILL.md</code>) turns an eager code generator into:
</div>

<div class="grid grid-cols-2 gap-6 h-68">
  <div class="p-6 rounded-2xl bg-amber-950/15 border border-amber-500/30 flex flex-col justify-between">
    <div>
      <div class="flex items-center justify-between mb-3">
        <span class="text-xs font-mono text-amber-400 uppercase tracking-widest">1. Before You Write Code</span>
        <code class="text-sm text-amber-300">/wayfinder</code>
      </div>
      <h3 class="text-3xl font-extrabold text-white tracking-tight mb-3">
        A <span class="text-amber-300">Design Partner</span>
      </h3>
      <p class="text-base text-gray-200 leading-relaxed m-0">
        Interviews you first, stress-tests domain boundaries, and commits durable <strong>Intent Artifacts</strong> (<code>SPEC.md</code>, tickets) to the repository before generating a single widget.
      </p>
    </div>
    <div class="text-xs font-mono text-amber-300/90 pt-3 border-t border-amber-500/20">
      Outcome: Shared architectural intent in git
    </div>
  </div>

  <div class="p-6 rounded-2xl bg-emerald-950/15 border border-emerald-500/30 flex flex-col justify-between">
    <div>
      <div class="flex items-center justify-between mb-3">
        <span class="text-xs font-mono text-emerald-400 uppercase tracking-widest">2. After the Code Exists</span>
        <code class="text-sm text-emerald-300">/teach-code</code>
      </div>
      <h3 class="text-3xl font-extrabold text-white tracking-tight mb-3">
        A <span class="text-emerald-300">Personal Tutor</span>
      </h3>
      <p class="text-base text-gray-200 leading-relaxed m-0">
        Builds an interactive, stateful curriculum directly from your new codebase&mdash;bridging your existing mental model (React) to the new stack (Flutter &amp; Dart).
      </p>
    </div>
    <div class="text-xs font-mono text-emerald-300/90 pt-3 border-t border-emerald-500/20">
      Outcome: Earned engineering comprehension
    </div>
  </div>
</div>

<!--
And here is the antidote. By shaping the agent with rules and composable Agent Skills—simple SKILL.md files—we transform its role at both ends of the workflow. Before we write code, skills like /wayfinder turn the agent into a design partner that interviews us and commits durable Intent Artifacts into git. And after the code exists, /teach-code turns the agent into a personal tutor that teaches us the exact architecture it just built.
-->

---
layout: default
---

<!-- S02c -->
<div class="flex items-center gap-3 mb-5">
  <h2 class="text-2xl font-bold m-0">The Mission: Taming a Study Full of Electronics Parts</h2>
</div>

<div class="grid grid-cols-12 gap-6 items-center h-88">
  <div class="col-span-5 h-full flex items-center justify-center rounded-2xl bg-gray-950/60 border border-gray-800/80 p-4 relative overflow-hidden">
    <svg viewBox="0 0 260 380" class="w-full h-full max-h-[340px]" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="38" y="10" width="184" height="360" rx="28" fill="#0b0c10" stroke="#374151" stroke-width="3" />
      <rect x="43" y="15" width="174" height="350" rx="24" fill="#121317" stroke="#1f2937" stroke-width="1.5" />
      <rect x="102" y="23" width="56" height="11" rx="5.5" fill="#050507" />
      <circle cx="148" cy="28.5" r="2.5" fill="#1e293b" />
      <rect x="56" y="46" width="148" height="22" rx="7" fill="#181b22" stroke="#374151" stroke-width="1.2" />
      <circle cx="68" cy="56.5" r="4" stroke="#22d3ee" stroke-width="1.5" />
      <line x1="71" y1="59.5" x2="74.5" y2="63" stroke="#22d3ee" stroke-width="1.5" stroke-linecap="round" />
      <rect x="82" y="54" width="64" height="5" rx="2.5" fill="#374151" />
      <rect x="56" y="80" width="148" height="78" rx="10" fill="#161920" stroke="#0891b2" stroke-width="1.2" />
      <g stroke="#22d3ee" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <rect x="78" y="96" width="44" height="46" rx="4" fill="#083344" />
        <path d="M93 96 A7 7 0 0 0 107 96" fill="#161920" />
        <line x1="68" y1="104" x2="78" y2="104" />
        <line x1="68" y1="114" x2="78" y2="114" />
        <line x1="68" y1="124" x2="78" y2="124" />
        <line x1="68" y1="134" x2="78" y2="134" />
        <line x1="122" y1="104" x2="132" y2="104" />
        <line x1="122" y1="114" x2="132" y2="114" />
        <line x1="122" y1="124" x2="132" y2="124" />
        <line x1="122" y1="134" x2="132" y2="134" />
      </g>
      <rect x="144" y="98" width="46" height="7" rx="3.5" fill="#cbd5e1" opacity="0.8" />
      <rect x="144" y="112" width="34" height="6" rx="3" fill="#22d3ee" opacity="0.5" />
      <rect x="144" y="130" width="24" height="10" rx="4" fill="#083344" stroke="#06b6d4" stroke-width="1" />
      <rect x="56" y="168" width="148" height="78" rx="10" fill="#161920" stroke="#b45309" stroke-width="1.2" />
      <g stroke="#fbbf24" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M68 207 H78 L83 195 L91 219 L99 195 L107 219 L115 195 L120 207 H132" />
      </g>
      <rect x="144" y="186" width="46" height="7" rx="3.5" fill="#cbd5e1" opacity="0.8" />
      <rect x="144" y="200" width="38" height="6" rx="3" fill="#fbbf24" opacity="0.5" />
      <rect x="144" y="218" width="24" height="10" rx="4" fill="#451a03" stroke="#d97706" stroke-width="1" />
      <rect x="56" y="256" width="148" height="78" rx="10" fill="#161920" stroke="#047857" stroke-width="1.2" />
      <g stroke="#34d399" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="68" y1="295" x2="94" y2="295" />
        <line x1="94" y1="277" x2="94" y2="313" />
        <path d="M108 277 C101 285 101 305 108 313" />
        <line x1="104" y1="295" x2="132" y2="295" />
        <line x1="82" y1="281" x2="88" y2="281" stroke-width="1.8" />
        <line x1="85" y1="278" x2="85" y2="284" stroke-width="1.8" />
      </g>
      <rect x="144" y="274" width="46" height="7" rx="3.5" fill="#cbd5e1" opacity="0.8" />
      <rect x="144" y="288" width="32" height="6" rx="3" fill="#34d399" opacity="0.5" />
      <rect x="144" y="306" width="24" height="10" rx="4" fill="#064e3b" stroke="#10b981" stroke-width="1" />
      <rect x="98" y="352" width="64" height="4" rx="2" fill="#4b5563" />
    </svg>
  </div>
  <div class="col-span-7 flex flex-col justify-center">
    <ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 leading-relaxed m-0">
      <li>
        <strong class="text-white">A Study Full of Parts, Zero Index</strong>
        <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
          <li>Binders of SMD cut-tape strips, multi-drawer cabinets, and anti-static bags scattered across the study.</li>
          <li>Hundreds of distinct resistors, ICs, sensors, and microcontrollers&mdash;and no idea which part lives in which drawer.</li>
        </ul>
      </li>
      <li>
        <strong class="text-white">The &ldquo;Buy It Again&rdquo; Workbench Tax</strong>
        <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
          <li>Re-ordering components from LCSC or Mouser that I definitely already own, simply because hunting through 40 unindexed drawers takes longer than buying a fresh reel.</li>
        </ul>
      </li>
      <li>
        <strong class="text-white">The Goal: A Pocket Workbench Catalog on iOS</strong>
        <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
          <li>Instant search by value, package footprint (<code>0603</code>, <code>DIP-8</code>), or part code.</li>
          <li>Pinpoints the exact physical <strong class="text-cyan-300">Container</strong> and <strong class="text-cyan-300">Slot</strong>, with one-tap stock adjustments right at the soldering bench.</li>
        </ul>
      </li>
    </ol>
  </div>
</div>

<!--
So what are we actually going to build to test this thesis? Let me set the scene. My study at home is full of electronic components—SMD binders full of cut-tape resistors and capacitors, multi-drawer cabinets of ICs, and boxes of ESP32 breakout boards. The problem is, I have no idea which part is where. Half the time, it's faster to re-order a ten-cent part than hunt through forty drawers. So my goal is to build an iOS app I can keep right next to my soldering iron: type in "10k 0603" or "NE555", see the exact binder page or cabinet drawer it lives in, and tap minus-one when I pull a part.
-->

---
layout: default
---

<!-- S03 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">Why Flutter Looks Deceptively Familiar to React Developers</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-5 leading-relaxed">
  <li>
    <strong class="text-white">Shared Declarative DNA (<code>UI = f(state)</code>)</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>You already think in declarative component trees, immutable props, and reactive state updates.</li>
      <li>Flutter&rsquo;s <code>Widget</code> tree maps closely enough to React&rsquo;s JSX component tree that AI-generated Dart code looks <em>almost</em> readable at a glance.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Where the Analogy Quietly Breaks</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><strong>Type Discipline:</strong> TypeScript uses erased structural typing; Dart 3 enforces sound nominal null-safety at compile time and in the VM.</li>
      <li><strong>Tree Lifecycle:</strong> React re-runs function closures and hooks by call index; Flutter separates immutable <code>Widget</code> configs from long-lived <code>Element</code> (<code>BuildContext</code>) and <code>RenderObject</code> trees.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">The Comprehension Debt Trap</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>When an AI generates 2,000 lines of Dart, <code>@freezed</code> codegen, and Riverpod providers, it runs on the iOS Simulator—right up until you need to debug a state race or change a storage invariant.</li>
    </ul>
  </li>
</ol>

<!--
Now, most of you have been building mobile apps with React and TypeScript. Why use Flutter for this experiment? Because Flutter sits right in that uncanny valley for a React developer. It's declarative—UI is a function of state—so when an AI generates a Flutter widget tree, you squint at it and think, "Yeah, that looks like JSX with extra parentheses." But underneath, Dart's nominal type system, compile-time const canonicalisation, and three-tree architecture behave very differently from React fibers and hooks. That gap between "it compiles and runs" and "I can confidently modify it" is where Comprehension Debt lives.
-->

---
layout: default
---

<!-- S04 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Controlled Three-Run Experiment in Google Antigravity (<code>agy</code>)</h2>
</div>

<div class="p-3.5 rounded-xl bg-gray-900/90 border border-cyan-500/30 text-xs font-mono text-cyan-200 mb-4">
  <span class="text-gray-400">Initial Prompt:</span> "I'd like to build a Flutter app for iOS that enables me to track my electronics parts"
</div>

<ol class="space-y-3.5 text-sm text-gray-200 list-decimal pl-6 leading-relaxed">
  <li>
    <strong class="text-white">Act 0 &mdash; The Hidden Variable (<code>~/.gemini/config/AGENTS.md</code>)</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Expose the user-level <strong>Global Rule</strong> that is active before a single project skill is installed.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Act 1 &mdash; The Baseline Run (<code>parts_tracker_baseline</code>)</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Run <code>agy</code> with only the <strong>Global Rule</strong> active. Inspect the working iOS app, the post-<code>/clear</code> code review, and the missing <strong>Intent Artifacts</strong>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Act 2 &mdash; The Skilled Run (<code>parts_tracker_skilled</code>)</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Install <code>mattpocock/skills</code> and walk <code>/wayfinder</code> &rarr; <code>/to-spec</code> &rarr; <code>/to-tickets</code> &rarr; <code>/implement</code> to produce both the app and repo-committed <strong>Intent Artifacts</strong>.</li>
    </ul>
  </li>
  <li>
    <strong class="text-white">Act 3 &mdash; The Comprehension Run (<code>parts_tracker_comprehension</code>)</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Install <code>domesticmouse/skills</code> and run <code>/teach-code</code> against the Skilled Run codebase to generate an interactive React-to-Flutter curriculum in <code>./tutorial/</code>.</li>
    </ul>
  </li>
</ol>

<!--
To keep this honest, we ran a controlled three-part experiment in the Google Antigravity CLI—agy—starting from the exact same terse prompt: "I'd like to build a Flutter app for iOS that enables me to track my electronics parts." Every run was recorded live with asciinema and its internal reasoning traces were exported from the Antigravity brain directory. Before we watch Run 1, though, I have a confession to make about my laptop's configuration.
-->

---
layout: center
class: text-center
---

<!-- S05 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 0: The Hidden Variable
  </h1>
  <p class="text-xl font-mono text-cyan-300">
    $HOME/.gemini/config/AGENTS.md &middot; Global Rule
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Why my &ldquo;unassisted&rdquo; Baseline Run behaves differently from yours before any project skills are installed
  </p>
</div>

<!--
This brings us to Act 0: The Hidden Variable. When I first recorded the Baseline Run, I thought I was testing stock, out-of-the-box Antigravity. Turns out, I wasn't.
-->

---
layout: skill-breakdown
way: 1
title: The User-Level Global Rule
---

<!-- S06 -->
<div class="space-y-4">
  <div class="p-4 rounded-lg bg-gray-950/90 border border-gray-800 space-y-2 text-sm text-gray-200 leading-relaxed">
    <div class="text-xs font-mono text-gray-400 border-b border-gray-800 pb-1.5 mb-2">$HOME/.gemini/config/AGENTS.md</div>
    <p class="m-0">You are a helpful assistant.</p>
    <p class="m-0">When something is unclear, please ask clarifying questions, one at a time.</p>
  </div>

  <div class="grid grid-cols-2 gap-4 text-xs pt-2">
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1.5">
      <div class="text-cyan-300 font-semibold">Always-On User Rule</div>
      <p class="text-gray-300 leading-relaxed m-0">
        Antigravity loads <code>$HOME/.gemini/config/AGENTS.md</code> into every conversation across every directory on the machine—even in a brand-new <code>flutter create</code> folder with zero project skills.
      </p>
    </div>
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 space-y-1.5">
      <div class="text-cyan-300 font-semibold">Ten Words That Change the Baseline</div>
      <p class="text-gray-300 leading-relaxed m-0">
        Instead of immediately guessing requirements from our 18-word prompt, <code>agy</code> halts code generation and invokes <code>ask_question</code> one turn at a time.
      </p>
    </div>
  </div>
</div>

<!--
Sitting in my home directory at ~/.gemini/config/AGENTS.md is this two-line file: "You are a helpful assistant. When something is unclear, please ask clarifying questions, one at a time." Antigravity injects this Global Rule into every session on my machine. If you clone a fresh Flutter project on your laptop without this file and paste our electronics parts prompt, the agent will immediately start blasting out Dart files based on whatever assumptions it hallucinates. With those ten words in place, the agent stops and interviews me first.
-->

---
layout: default
---

<!-- S07 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">Unconfigured Agent vs. Global Rule vs. Project Skills</h2>
</div>

<div class="grid grid-cols-2 gap-6 mt-6">
  <div class="p-5 rounded-xl bg-red-950/15 border border-red-500/30 space-y-3">
    <div class="text-xs font-mono text-red-400 uppercase">Without Global Rule (True Zero-Config)</div>
    <h3 class="text-lg font-bold text-white">Immediate Assumption Dump</h3>
    <ul class="text-xs text-gray-300 space-y-2 list-disc pl-4">
      <li>Zero clarifying questions asked before writing code.</li>
      <li>Invents its own part schema, persistence layer, and navigation tabs in a single turn.</li>
      <li><strong>Result:</strong> Fast initial code output, but high rework when its guesses miss your actual workbench workflow.</li>
    </ul>
  </div>

  <div class="p-5 rounded-xl bg-emerald-950/15 border border-emerald-500/30 space-y-3">
    <div class="text-xs font-mono text-emerald-400 uppercase">With Global Rule (Our Baseline Run)</div>
    <h3 class="text-lg font-bold text-white">Polite Interview, Ephemeral Memory</h3>
    <ul class="text-xs text-gray-300 space-y-2 list-disc pl-4">
      <li>Asks 3 structured <code>ask_question</code> prompts one at a time (features, storage, UI theme).</li>
      <li>Also auto-discovers global Flutter plugin skills (<code>flutter-apply-architecture-best-practices</code>).</li>
      <li><strong>Result:</strong> Builds a solid first-pass app—but every answer stays trapped in the chat log.</li>
    </ul>
  </div>
</div>

<!--
So keep this contrast in mind as we enter Act 1. Even a single sentence in your global AGENTS.md upgrades an agent from an assumption generator into a polite interviewer. But as we are about to see in the Baseline Run, asking good questions in chat is not the same thing as engineering a maintainable system.
-->
