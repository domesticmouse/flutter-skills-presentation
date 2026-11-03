# Issue 05: On-device JSON persistence, schema versioning, and iOS Files export/import

Type: grilling
Status: resolved
Blocked by: 02, 03

## Question

How should the on-device JSON storage and iOS Files / Share Sheet backup & import work in detail?

Key decisions to resolve:
1. **On-device JSON storage**: Exact file location (e.g., iOS Application Documents directory, whether `UIFileSharingEnabled` / `LSSupportsOpeningDocumentsInPlace` should expose the live file directly in the iOS Files app), atomic write strategy (write-to-temp + rename), and auto-save debouncing.
2. **Schema & versioning**: Top-level JSON envelope (`schemaVersion`, `exportedAt`, `parts`, `locations`) so future app updates or desktop scripts don't break existing data.
3. **Import & conflict resolution**: When importing a JSON file from the iOS Files app or Share Sheet, should it **replace** the entire database, **merge** by ID/LCSC code, or prompt the user?

## Answer

1. **Live File Location, iOS Files Visibility, and Atomic Writes**:
   - Store the live catalog at `getApplicationDocumentsDirectory()/parts_catalog.json` with `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` enabled in `ios/Runner/Info.plist`, exposing the folder under **On My iPhone › Parts Tracker** in the iOS Files app and Finder.
   - Provide explicit in-app **Export Backup** (Share Sheet exporting a timestamped `parts-catalog-YYYY-MM-DD.json` file) and **Import Backup** (File Picker) actions.
   - Persist every mutation immediately through a serialized async write queue using atomic write-to-temp + rename (`parts_catalog.json.tmp` → `parts_catalog.json`) with 2-space pretty-printed JSON.
2. **Schema Envelope & Versioning (`schemaVersion: 1`)**:
   - Use the exact same top-level JSON envelope for both the live `parts_catalog.json` file and exported backups, aligned with `GLOSSARY.md` (`containers` and `parts`):
     - `schemaVersion`: integer (`1`)
     - `updatedAt`: ISO-8601 UTC timestamp string
     - `containers`: array of `Container` objects (`id`, `name`, `description`)
     - `parts`: array of `Part` objects (`id`, `name`, `quantity`, `lcscCode`, `mpn`, `manufacturer`, `category`, `package`, `datasheetUrl`, `containerId`, `slot`, `lowStockThreshold`, `notes`, `specs`)
   - On first launch with no existing `parts_catalog.json`, initialize an empty v1 catalog (`containers: []`, `parts: []`). Reject unsupported `schemaVersion` values (`!= 1`) on load/import with an explicit error message.
3. **Import Semantics, Safety Backup, and Referential Integrity**:
   - **Full-snapshot replace with confirmation**: Importing a JSON file validates the incoming snapshot and prompts for confirmation showing current vs. incoming part/container counts and `updatedAt` timestamp before replacing the catalog.
   - **Automatic pre-import backup**: Before overwriting `parts_catalog.json` on import, copy the existing file to `parts_catalog.backup.json` in the Application Documents directory.
   - **Strict all-or-nothing validation**: Reject imports that have malformed JSON, `schemaVersion != 1`, missing required fields (`id`, `name`, `quantity >= 0`), duplicate `Container` or `Part` IDs, duplicate non-empty `(containerId, slot)` pairs, or a `Part.containerId` that does not exist in `containers`.
   - **Container deletion integrity**: Deleting a `Container` in the app atomically unassigns its parts (`containerId: null, slot: null`) in the same write.
