# 03: LCSC (Cxxxxxx) live metadata auto-fill and duplicate part warning

**What to build:** End-to-end LCSC `Cxxxxxx` component lookup and duplicate detection in the Add / Edit **Part** workflow. When a user enters an LCSC code (e.g., `"C14663"`, `"c14663"`, or `"14663"`) and taps **Fetch LCSC**, the app queries LCSC's unauthenticated product detail endpoint (`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx`) and pre-fills the form's editable fields (`name`, `mpn`, `manufacturer`, `category`, `package`, `datasheetUrl`, and structured `Key: Value` **Specs** from `paramVOList`), degrading gracefully to manual entry if offline or if the part code is not found. If the user types an `lcscCode` that already exists on another **Part** in the catalog, the sheet displays an inline warning banner with a **Jump to Part** button so they can jump straight to the existing **Part** to increment its stock, without hard-blocking if they still choose to save a separate entry.

**Blocked by:** 01: Core Part catalog tracer bullet (JSON persistence, Workbench accordion list, stock adjustments, and manual Add/Edit Part)

**Status:** completed

- [x] Input LCSC codes are normalized to uppercase `C\d+` format (e.g., `"14663"` and `"c14663"` become `"C14663"`); invalid formats show an inline validation message before making a network request.
- [x] Tapping **Fetch LCSC** sends `GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx` with a browser `User-Agent` header and `Accept: application/json`, displaying a loading indicator while in flight.
- [x] A successful response maps `productDescEn ?? productIntroEn ?? productNameEn ?? productModel` → `name`, `productModel` → `mpn`, `brandNameEn` → `manufacturer`, `catalogName ?? parentCatalogName` → `category`, `encapStandard` → `package` (ignoring `"-"` placeholders), `pdfUrl` → `datasheetUrl`, and `paramVOList[]` (`paramNameEn`: `paramValueEn`) → ordered `Specs` (stripping HTML tags/entities and skipping empty or `"-"` values).
- [x] All fetched values populate standard editable form fields and **Spec** rows so the user can modify any field before saving the **Part** to the on-device JSON catalog.
- [x] If the network request fails, times out, or returns `result: null`, the form displays a non-destructive error banner and leaves all manual form inputs usable.
- [x] Typing an `lcscCode` that matches an existing **Part** in the catalog (case-insensitive) displays an inline warning banner naming the existing **Part** with a **Jump to Part** action that closes the form and opens/focuses the existing **Part**, while still allowing the user to save if desired.
- [x] Automated tests verify `Cxxxxxx` normalization, LCSC payload parsing and HTML/placeholder sanitization using a mock HTTP client, error handling on unknown codes/network failures, and the duplicate `lcscCode` warning + **Jump to Part** UI flow.
