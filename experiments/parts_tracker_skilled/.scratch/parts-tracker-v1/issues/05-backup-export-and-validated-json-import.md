# 05: iOS Share Sheet backup export and validated full-snapshot JSON import

**What to build:** End-to-end catalog backup export and validated full-snapshot JSON import from the Workbench command bar. Users can trigger **Export Backup** to share a timestamped `parts-catalog-YYYY-MM-DD.json` snapshot via the iOS Share Sheet, or trigger **Import Backup** to pick a `.json` file from the iOS Files picker, validate its schema and referential integrity (`schemaVersion == 1`, valid required fields, `quantity >= 0`, no duplicate **Container** or **Part** IDs, valid `Part.containerId` references, and strict 1-to-1 `(containerId, slot)` uniqueness), review a confirmation dialog comparing current vs. incoming **Part** and **Container** counts and `updatedAt` timestamps, automatically write a pre-import safety copy (`parts_catalog.backup.json`), and replace the live catalog.

**Blocked by:** 02: Physical storage hierarchy (Container management, 1-to-1 Slot uniqueness, and By Container grouped view)

**Status:** completed

- [x] Triggering **Export Backup** from the command bar writes the current `CatalogSnapshot` (`schemaVersion: 1`, `updatedAt`, `containers`, `parts`) as 2-space pretty-printed JSON to a timestamped `parts-catalog-YYYY-MM-DD.json` file and opens the iOS Share Sheet.
- [x] Triggering **Import Backup** opens the system file picker for `.json` files and runs strict all-or-nothing validation on the selected file before modifying any state.
- [x] Import validation rejects files with malformed JSON, unsupported `schemaVersion` (`!= 1`), missing required fields (`id`, `name`, `quantity >= 0`), duplicate `Container.id` or `Part.id` values, any `Part.containerId` that does not exist in `containers`, or duplicate non-empty `(containerId, slot)` pairs (case-insensitive after trimming).
- [x] When an imported file fails validation, the app displays a clear, non-destructive error dialog explaining the validation failure and leaves the existing catalog and `parts_catalog.json` untouched.
- [x] When an imported file passes validation, the app presents a confirmation dialog showing current vs. incoming **Part** counts, **Container** counts, and `updatedAt` timestamps before replacing the catalog.
- [x] Confirming the import first copies the existing catalog to `parts_catalog.backup.json` in the Application Documents directory, then atomically writes the imported snapshot to `parts_catalog.json` and updates the live Workbench state.
- [x] Automated tests verify export file generation, all-or-nothing rejection for each invalid import case, pre-import `parts_catalog.backup.json` creation, and full-snapshot replacement through the UI and persistence seams.
