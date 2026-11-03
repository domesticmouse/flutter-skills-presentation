# Issue 06: Catalog search, filtering, and engineering unit normalization

Type: grilling
Status: resolved
Blocked by: 02

## Question

With a **Part** storing `name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, `notes`, and an ordered `specs` map (`Map<String, String>`), how should workbench search and filtering behave?

Key decisions to resolve:
1. **Search matching & engineering unit equivalence**: Should searching for values like `4k7` / `4.7k` / `4700R` or `100nF` / `0.1uF` / `104` normalize engineering units and SI prefixes so equivalent values match across `name` and `specs`, or rely on case-insensitive token/substring matching?
2. **Searchable fields & ranking**: Which fields are indexed/searched by the main search bar (e.g., `name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, `specs` values, `slot`, `notes`), and how should multi-token queries (e.g., `"100nF 0603 X7R"`) work?
3. **Filter facets**: Which quick filters should be available alongside text search (e.g., Category, Container, Package, Low Stock, Unassigned)?

## Answer

1. **Engineering Unit & Shorthand Equivalence**:
   - **Text folding**: Case-insensitive matching with Unicode symbol folding (`µ`/`μ` → `u`, `Ω`/`ohm`/`ohms` → `r`, stripping `±`).
   - **Canonical engineering value matching**: Parse explicitly unit/prefix-marked tokens in both indexed part text (`name`, `specs` values) and query tokens—supporting standard SI (`4.7k`, `4.7kΩ`, `4700R`, `100mΩ`, `0.1uF`, `100nF`, `100000pF`, `4.7uH`, `3.3V`) and EE infix shorthand (`4k7`, `100r`, `4r7`, `3v3`, `2n2`)—into canonical `(Dimension, baseValue)` pairs (Resistance in $\Omega$, Capacitance in $\text{F}$, Inductance in $\text{H}$, Voltage in $\text{V}$, Current in $\text{A}$, Power in $\text{W}$, Frequency in $\text{Hz}$) compared within $10^{-6}$ relative tolerance.
   - **No bare 3-digit EIA code expansion**: Bare 3-digit numbers like `104` are not expanded into capacitance/resistance values (avoiding false positives against `Cxxxxxx` codes and quantities; `104` still matches MPNs like `CL10B104KB8NNNC` via substring).
2. **Searchable Fields, Multi-Token AND Queries, and Ordering**:
   - **Searchable fields (10 fields)**: `name`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, resolved `Container.name`, `slot`, `notes`, and `specs` (both keys and values).
   - **Multi-token AND matching**: Split the search query on whitespace into tokens; a **Part** matches if **every** token matches at least one searchable field (via folded substring **or** canonical engineering value equivalence on `name`/`specs`).
   - **Ordering**:
     - **Empty query**: Sort alphabetically by `name` (case-insensitive) in flat view; in **`By Container`** view, pin `Unassigned (Loose / Inbox)` first, sort **Containers** alphabetically by `name`, and sort **Parts** within each container by natural alphanumeric `slot` order (`"Page 2"` before `"Page 10"`, `"Drawer A2"` before `"Drawer A10"`, with bulk slotless parts last).
     - **Active query**: Rank by match tier—(1) exact/prefix `lcscCode` or `mpn` match, (2) `name` or canonical engineering value match in `name`/`specs`, (3) match in remaining fields (`slot`, `Container.name`, `package`, `category`, `manufacturer`, `notes`)—breaking ties alphabetically by `name`.
3. **Filter Facets & Combination Rules**:
   - Keep the locked single-row horizontal chip bar (`By Container` layout toggle + single-select `ChoiceChip`s: `All`, `Low Stock`, `Unassigned`, and dynamic `category` chips from categories present in the catalog).
   - Intersect the active filter chip via **AND** with the active search query.
   - In **`By Container`** mode, hide containers with zero matching parts whenever a search query or non-`All` filter chip is active (while showing all containers when `All` is selected and the search query is empty so empty containers can still receive parts via `+ Add Slot`).
