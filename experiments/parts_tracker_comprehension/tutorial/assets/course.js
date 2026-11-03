/* Shared Course Runtime: Prism.js (with keep-markup), Mermaid.js (dark), Interactive Exercises, Quizzes, Verification Checklists, and Simulators */
(function () {
  "use strict";

  function loadStylesheet(href) {
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = href;
    document.head.appendChild(link);
  }

  function loadScript(src, onLoad) {
    var script = document.createElement("script");
    script.src = src;
    script.defer = true;
    if (onLoad) {
      script.addEventListener("load", onLoad);
    }
    document.head.appendChild(script);
  }

  function initCodeBlockKeyboardScrolling() {
    var preBlocks = document.querySelectorAll("pre");
    preBlocks.forEach(function (pre) {
      if (pre.classList.contains("mermaid")) return;
      if (!pre.hasAttribute("tabindex")) {
        pre.setAttribute("tabindex", "0");
      }
      if (!pre.hasAttribute("role")) {
        pre.setAttribute("role", "region");
      }
      if (!pre.hasAttribute("aria-label")) {
        pre.setAttribute("aria-label", "Code snippet");
      }
    });
  }

  function initPrismAndMermaid() {
    loadStylesheet("https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css");
    window.Prism = window.Prism || {};
    window.Prism.manual = true;

    loadScript("https://cdn.jsdelivr.net/npm/prismjs@1.29.0/prism.min.js", function () {
      loadScript("https://cdn.jsdelivr.net/npm/prismjs@1.29.0/plugins/keep-markup/prism-keep-markup.min.js", function () {
        var langs = ["clike", "javascript", "typescript", "jsx", "tsx", "dart", "bash", "yaml", "json"];
        var loaded = 0;
        langs.forEach(function (lang) {
          loadScript(
            "https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-" + lang + ".min.js",
            function () {
              loaded += 1;
              if (loaded === langs.length && window.Prism && window.Prism.highlightAll) {
                window.Prism.highlightAll();
              }
            }
          );
        });
      });
    });

    if (document.querySelector(".mermaid")) {
      loadScript("https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js", function () {
        if (window.mermaid) {
          window.mermaid.initialize({
            startOnLoad: true,
            theme: "dark",
            securityLevel: "loose"
          });
        }
      });
    }
  }

  function normalizeToken(val) {
    return (val || "").trim().replace(/\s+/g, " ");
  }

  function initExercises() {
    var cards = document.querySelectorAll(".exercise-card");
    cards.forEach(function (card) {
      var checkBtn = card.querySelector("[data-action='check-exercise']");
      var hintBtn = card.querySelector("[data-action='hint-exercise']");
      var feedbackEl = card.querySelector(".widget-feedback");
      var inputs = card.querySelectorAll("input.code-blank");
      var generalHint = card.getAttribute("data-hint") || "";
      var successMsg = card.getAttribute("data-success") || "All blanks matched!";

      function showFeedback(kind, text) {
        if (!feedbackEl) return;
        feedbackEl.className = "widget-feedback is-visible is-" + kind;
        feedbackEl.textContent = text;
      }

      if (checkBtn) {
        checkBtn.addEventListener("click", function () {
          var allCorrect = true;
          var firstErrorHint = "";
          inputs.forEach(function (input) {
            var rawAnswers = (input.getAttribute("data-answer") || "").split("||");
            var candidates = rawAnswers.map(normalizeToken);
            var userVal = normalizeToken(input.value);
            if (candidates.indexOf(userVal) !== -1) {
              input.classList.remove("is-wrong");
              input.classList.add("is-correct");
            } else {
              allCorrect = false;
              input.classList.remove("is-correct");
              input.classList.add("is-wrong");
              if (!firstErrorHint) {
                firstErrorHint = input.getAttribute("data-error-hint") || generalHint;
              }
            }
          });

          if (allCorrect) {
            showFeedback("success", successMsg);
          } else {
            showFeedback("error", firstErrorHint || "Check the highlighted blank(s) and try again.");
          }
        });
      }

      if (hintBtn) {
        hintBtn.addEventListener("click", function () {
          showFeedback("hint", generalHint || "Inspect the code listing above for the exact identifier or type.");
        });
      }
    });
  }

  function initQuizzes() {
    var quizCards = document.querySelectorAll(".quiz-card");
    quizCards.forEach(function (card) {
      var qBlocks = card.querySelectorAll(".quiz-question-block");
      qBlocks.forEach(function (block) {
        var buttons = block.querySelectorAll(".quiz-option-btn");
        var feedback = block.querySelector(".widget-feedback");
        var wrongHint = block.getAttribute("data-wrong-hint") || "";

        buttons.forEach(function (btn) {
          btn.addEventListener("click", function () {
            var isCorrect = btn.getAttribute("data-correct") === "true";
            var explain = btn.getAttribute("data-explain") || "";

            buttons.forEach(function (b) {
              b.classList.remove("is-correct", "is-wrong");
            });

            if (isCorrect) {
              btn.classList.add("is-correct");
              if (feedback) {
                feedback.className = "widget-feedback is-visible is-success";
                feedback.textContent = explain;
              }
            } else {
              btn.classList.add("is-wrong");
              if (feedback) {
                feedback.className = "widget-feedback is-visible is-error";
                feedback.textContent = explain + (wrongHint ? " Hint: " + wrongHint : "");
              }
            }
          });
        });
      });
    });
  }

  function initVerifyChecklists() {
    var boxes = document.querySelectorAll(".verify-card input[type='checkbox'][data-storage-key]");
    boxes.forEach(function (box) {
      var key = box.getAttribute("data-storage-key");
      try {
        if (window.localStorage.getItem(key) === "1") {
          box.checked = true;
        }
      } catch (_) {}

      box.addEventListener("change", function () {
        try {
          window.localStorage.setItem(key, box.checked ? "1" : "0");
        } catch (_) {}
      });
    });
  }

  function initSimulators() {
    var mounts = document.querySelectorAll("[data-simulator='react-flutter-tree-mapper']");
    var nodes = [
      {
        id: "runApp",
        label: "1. main() → runApp(...)",
        reactEq: "createRoot(document.getElementById('root')!).render(...)",
        flutterRole: "Initializes the Flutter engine bindings (WidgetsFlutterBinding.ensureInitialized()) and attaches the root Widget to the screen.",
        contextLookup: "Root of the Element tree — no parent BuildContext above this point.",
        rebuildRule: "Executed once at process startup (or once per pumpWidget call in testWidgets)."
      },
      {
        id: "ProviderScope",
        label: "2. ProviderScope(child: ...)",
        reactEq: "<QueryClientProvider> + <ReduxProvider store={store}>",
        flutterRole: "Creates the Riverpod ProviderContainer that owns all reactive state and supports overrides: [...] in tests.",
        contextLookup: "Exposes an InheritedWidget so any descendant ConsumerWidget or BuildContext can read/watch providers in O(1).",
        rebuildRule: "Marked const — never rebuilds unless replaced at the root."
      },
      {
        id: "PartsTrackerApp",
        label: "3. PartsTrackerApp (StatelessWidget)",
        reactEq: "export function PartsTrackerApp() { return <ThemeProvider>... }",
        flutterRole: "Configures the application shell and returns MaterialApp with darkTheme (seedColor: 0xFF00E5FF, scaffoldBackgroundColor: 0xFF0E1318).",
        contextLookup: "Receives its own BuildContext (Element) beneath ProviderScope.",
        rebuildRule: "Constructed with const PartsTrackerApp({super.key}) — canonicalized at compile time like React.memo."
      },
      {
        id: "MaterialApp",
        label: "4. MaterialApp(themeMode: ThemeMode.dark, ...)",
        reactEq: "<ThemeProvider theme={darkTheme}><RouterProvider /></ThemeProvider>",
        flutterRole: "Provides Material 3 Theme, Navigator (for bottom sheets & dialogs), MediaQuery, and Directionality to all screens.",
        contextLookup: "Injects Theme, Navigator, and MediaQuery InheritedWidgets into the BuildContext tree.",
        rebuildRule: "Rebuilds only if theme or top-level navigation configuration changes."
      },
      {
        id: "WorkbenchScreen",
        label: "5. WorkbenchScreen (home: const WorkbenchScreen())",
        reactEq: "export function WorkbenchScreen() { return <main>...</main>; }",
        flutterRole: "Renders the Scaffold with the dark AppBar ('Electronics Parts Tracker') and workbench body.",
        contextLookup: "Calls Theme.of(context) and (in later lessons) ref.watch(catalogProvider) using its Element position.",
        rebuildRule: "Only this subtree rebuilds when watched workbench providers emit new state."
      }
    ];

    mounts.forEach(function (mount) {
      var listEl = mount.querySelector(".sim-tree-list");
      var inspectorEl = mount.querySelector(".sim-inspector");
      if (!listEl || !inspectorEl) return;

      function selectNode(node) {
        var allBtns = listEl.querySelectorAll(".sim-node-btn");
        allBtns.forEach(function (b) {
          b.setAttribute("aria-pressed", b.getAttribute("data-node-id") === node.id ? "true" : "false");
        });

        inspectorEl.innerHTML =
          "<h4>" + node.label + "</h4>" +
          "<dl class='sim-kv'>" +
          "<dt>React + TS</dt><dd><code>" + node.reactEq + "</code></dd>" +
          "<dt>Flutter Role</dt><dd>" + node.flutterRole + "</dd>" +
          "<dt>BuildContext</dt><dd>" + node.contextLookup + "</dd>" +
          "<dt>Rebuild Cost</dt><dd>" + node.rebuildRule + "</dd>" +
          "</dl>";
      }

      nodes.forEach(function (node, idx) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.className = "sim-node-btn";
        btn.setAttribute("data-node-id", node.id);
        btn.setAttribute("aria-pressed", idx === 0 ? "true" : "false");
        btn.textContent = node.label;
        btn.addEventListener("click", function () {
          selectNode(node);
        });
        listEl.appendChild(btn);
      });

      selectNode(nodes[0]);
    });

    var unitMounts = document.querySelectorAll("[data-simulator='unit-search-simulator']");
    var sampleQueries = [
      {
        query: "0.1uF 50V",
        parsed: "Token 1: EngineeringValue(capacitance, 1.0e-7 F) • Token 2: EngineeringValue(voltage, 50.0 V)",
        matched: "100nF 50V X7R 0603 Capacitor (C14663)",
        tier: "Tier 2 (Name & Spec Engineering Equivalence)",
        why: "0.1uF normalizes to 1.0e-7 F, which matches 100nF (100 × 10⁻⁹ = 1.0e-7 F) within 1e-6 relative tolerance."
      },
      {
        query: "4k7",
        parsed: "Token 1: EE-Infix '4k7' → EngineeringValue(resistance, 4700.0 Ω)",
        matched: "4.7kΩ ±1% 0603 Resistor (C23162)",
        tier: "Tier 2 (Name & Spec Engineering Equivalence)",
        why: "Infix marker 'k' between digits 4 and 7 resolves to mantissa 4.7 × 10³ Ω = 4700 Ω, matching '4.7kΩ'."
      },
      {
        query: "4700R",
        parsed: "Token 1: '4700R' → EngineeringValue(resistance, 4700.0 Ω) + folded text '4700r'",
        matched: "1st: 4.7Ω Sense Resistor (MPN: 4700R-TEST-MPN) • 2nd: 4.7kΩ Resistor • 3rd: AMS1117-3.3 (notes)",
        tier: "Tier 1 (MPN prefix) → Tier 2 (4.7kΩ value) → Tier 3 (Notes substring)",
        why: "Demonstrates 3-tier ranking: exact MPN prefix ranks first (Tier 1), unit equivalence ranks second (Tier 2), and notes text match ranks third (Tier 3)."
      },
      {
        query: "104",
        parsed: "Token 1: Bare integer '104' → parseEngineeringToken('104') == null (no SI prefix or unit!)",
        matched: "100nF 50V X7R 0603 Capacitor (MPN: CL10B104KB8NNNC)",
        tier: "Tier 3 (MPN substring match only)",
        why: "Bare 3-digit EIA codes like '104' or '472' are intentionally NOT expanded to 100nF or 4.7kΩ to prevent false positives against part numbers."
      },
      {
        query: "10uF",
        parsed: "Token 1: '10uF' → EngineeringValue(capacitance, 1.0e-5 F) + folded text '10uf'",
        matched: "10µF 25V X5R 0805 Capacitor (C15850)",
        tier: "Tier 2 (Unicode µ / μ folded to ASCII 'u')",
        why: "foldText() normalizes both U+00B5 (µ micro sign) and U+03BC (μ Greek mu) to ASCII 'u' before matching."
      }
    ];

    unitMounts.forEach(function (mount) {
      var listEl = mount.querySelector(".sim-tree-list");
      var inspectorEl = mount.querySelector(".sim-inspector");
      if (!listEl || !inspectorEl) return;

      function selectQuery(item) {
        var allBtns = listEl.querySelectorAll(".sim-node-btn");
        allBtns.forEach(function (b) {
          b.setAttribute("aria-pressed", b.getAttribute("data-query") === item.query ? "true" : "false");
        });

        inspectorEl.innerHTML =
          "<h4>Query: <code>\"" + item.query + "\"</code></h4>" +
          "<dl class='sim-kv'>" +
          "<dt>Parsed Token</dt><dd><code>" + item.parsed + "</code></dd>" +
          "<dt>Matched Part</dt><dd>" + item.matched + "</dd>" +
          "<dt>Ranking Tier</dt><dd><strong>" + item.tier + "</strong></dd>" +
          "<dt>Why It Matched</dt><dd>" + item.why + "</dd>" +
          "</dl>";
      }

      sampleQueries.forEach(function (item, idx) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.className = "sim-node-btn";
        btn.setAttribute("data-query", item.query);
        btn.setAttribute("aria-pressed", idx === 0 ? "true" : "false");
        btn.textContent = "Query: \"" + item.query + "\"";
        btn.addEventListener("click", function () {
          selectQuery(item);
        });
        listEl.appendChild(btn);
      });

      selectQuery(sampleQueries[0]);
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initCodeBlockKeyboardScrolling();
    initPrismAndMermaid();
    initExercises();
    initQuizzes();
    initVerifyChecklists();
    initSimulators();
  });
})();
