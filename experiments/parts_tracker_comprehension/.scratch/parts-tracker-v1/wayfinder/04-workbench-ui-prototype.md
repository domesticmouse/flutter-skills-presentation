# Issue 04: Workbench UI flow and visual prototype

Type: prototype
Status: resolved
Blocked by: 02, 03

## Question

How should the iOS app look and feel at the workbench for its core loops?

Key flows to prototype and validate interactively:
1. **Fast lookup & filtering**: Finding a part by value/name/package/LCSC code ("Do I have a 4.7k 0603 resistor, and which drawer/slot is it in?").
2. **Quick stock adjustment**: Incrementing/decrementing quantity (`-1`, `+10`, custom delta) right from the search result or part detail view without friction.
3. **Part entry**: Adding a new part (including typing an LCSC `Cxxxxxx` code and assigning a Storage Location).
4. **Storage browser**: Browsing by physical container/drawer to see what's inside.
5. **Visual style**: Material 3 layout and theming tailored for high-density workbench use on iOS.

## Answer

Validated via interactive 3-variant Flutter prototype ([`lib/prototype_workbench.dart`](../../../lib/prototype_workbench.dart), archived at [`../prototypes/04-workbench-ui-prototype.dart`](../prototypes/04-workbench-ui-prototype.dart)). **Variant B (Dark Command Bar & Inline Accordion)** is locked as the V1 UI design:

1. **Single-Screen Command Bar Layout (No Bottom Tab Bar)**:
   - **Top Command Header** (`#161D24` surface):
     - Terminal-style monospace search omnibox (`⌘ Find: "0603 4.7k", "C14663", "Drawer B3"…`) that filters across part name, LCSC code, MPN, package, category, container/slot, and electrical `Specs`.
     - Compact **Manage Containers** icon button (opens the Manage Physical Containers bottom sheet to view part counts per **Container** and create/rename/delete containers), backup/import action, and a primary **`+ New`** part button.
   - **Horizontal Chip Bar**:
     - Leading **`By Container`** toggle chip that switches the main list between a flat catalog list and a grouped-by-Container view (with per-container headers for `Unassigned (Loose / Inbox)` and each **Container**, plus an inline `+ Add Slot` button on each container header).
     - Quick-filter `ChoiceChip`s: `All`, `Low Stock`, `Unassigned`, followed by dynamic category chips drawn from categories present in the catalog.
2. **Inline Accordion Part Cards (`#141B22` collapsed / `#1C2631` expanded with cyan `#00E5FF` border)**:
   - **Collapsed row**: High-contrast monospace `quantity` badge (colored with `errorContainer` when `quantity <= lowStockThreshold`, otherwise `primaryContainer`), bold `name`, and a single-line monospace subtitle (`Container · Slot  •  Package  •  Cxxxxxx`).
   - **Expanded inline accordion**: Tapping a card expands it in place (without losing scroll position) to reveal:
     - All electrical/physical **Specs** as compact `Key: Value` bordered monospace chips.
     - Wrapping quick-adjustment buttons (`-10`, `-1`, `+1`, `+10`) for immediate workbench stock changes plus a **`Details & Edit`** button.
3. **Full Part Detail & LCSC-First Add/Edit Modal Bottom Sheets**:
   - **Part Detail Sheet**: Displays badges (`lcscCode`, `package`, `category`), `name`, `MPN • Manufacturer`, location & low-stock status card with quantity controls (`-10`, `-1`, `+1`, `+10`, `Set…` exact quantity dialog), workbench `notes`, full key-value `Specs` table, and an **Open LCSC PDF Datasheet** button.
   - **Add / Edit Part Sheet**:
     - Leads with `LCSC Part Code` input + **`Fetch LCSC`** button that queries `wmsc.lcsc.com` and pre-fills editable fields (`name`, `mpn`, `manufacturer`, `category`, `package`, `datasheetUrl`, and removable `Specs` chips).
     - Shows an inline warning banner with a **`Jump to Part`** button when entering an `lcscCode` that already exists in the catalog.
     - Provides a `Container` dropdown (`Unassigned (Loose / Inbox)` or any existing **Container**) paired with a `Slot` text input that validates 1-to-1 `(Container, Slot)` uniqueness inline before saving.
4. **Visual Theme**:
   - Dark industrial Material 3 OLED theme (`ColorScheme.fromSeed(seedColor: Color(0xFF00E5FF), brightness: Brightness.dark)`, `#0E1318` scaffold background, `#161D24` header, monospace `Courier` typography for quantities, locations, packages, and `Cxxxxxx` codes).
