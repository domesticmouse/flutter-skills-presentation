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

  <div class="mt-8 text-gray-400 text-base">
    <span class="font-semibold text-gray-200">Brett Morgan</span> &middot; Developer Relations, Google
  </div>

  <div class="mt-6 flex items-center gap-4 text-xs font-mono">
    <a href="https://github.com/domesticmouse/flutter-skills-presentation" target="_blank" class="px-3 py-1.5 rounded-lg bg-gray-900 border border-gray-700 text-cyan-300 hover:underline">
      github.com/domesticmouse/flutter-skills-presentation
    </a>
    <a href="./tutorial/index.html" target="_blank" class="px-3 py-1.5 rounded-lg bg-emerald-950/40 border border-emerald-500/40 text-emerald-300 hover:underline">
      Interactive React &rarr; Flutter Tutorial &nearr;
    </a>
  </div>

  <div class="mt-8 text-xs text-gray-500">
    Press <kbd>Space</kbd> or <kbd>&rarr;</kbd> to advance
  </div>
</div>

<!--
G'day everyone! Today we are going to look at what actually happens when you hand an AI coding agent a terse prompt for an app in a framework you haven't mastered yet. More importantly, we're going to explore how small, composable markdown files—Rules and Agent Skills—completely reshape how that agent collaborates with you.
-->

---
layout: default
---

<!-- S02 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Core Thesis</h2>
</div>

<div class="h-80 flex flex-col items-center justify-center text-center px-8">
  <blockquote class="text-2xl font-semibold text-white tracking-tight leading-relaxed max-w-4xl">
    &ldquo;Out of the box, an AI coding agent will happily generate a working app in a framework you don&rsquo;t know&mdash;and hand you a pile of <span class="text-red-400">Comprehension Debt</span>.<br/><br/>
    By shaping the agent with rules and Agent Skills (<code class="text-cyan-300">SKILL.md</code>), you turn it from an eager code generator into a <span class="text-amber-300">design partner</span> that interviews you first (<code class="text-amber-300">/wayfinder</code>), and a <span class="text-emerald-300">personal tutor</span> that teaches you the codebase afterwards (<code class="text-emerald-300">/teach-code</code>).&rdquo;
  </blockquote>
</div>

<!--
Here is the core thesis for the next forty-five minutes. Out of the box, modern coding agents are almost too eager to please. Give them a one-line prompt in a language or framework you don't know, and they will hand you a working app in fifteen minutes—along with a massive pile of Comprehension Debt. You have code that runs, but you don't own the domain model, the architectural seams, or the mental model to maintain it. Turns out, by shaping the agent with rules and Agent Skills, we can turn that eager code generator into a design partner before we write code, and a personal tutor afterwards.
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
