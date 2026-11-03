# Issue 01: LCSC part metadata lookup from C-code

Type: research
Status: resolved

## Question

When a user enters an LCSC part code (`Cxxxxxx`, e.g., `C14663`), what are the viable ways for an iOS Flutter app to fetch part metadata (name, manufacturer part number, category, package/footprint, key electrical parameters, datasheet URL, product page URL) without requiring a custom backend proxy?

Specifically:
1. What is LCSC's official API story (authentication, approval requirements, rate limits, suitability for a client-side personal app)?
2. Does LCSC (or EasyEDA / JLCPCB component library, which shares `Cxxxxxx` codes) expose an unauthenticated JSON endpoint that is commonly used by open-source electronics tools (e.g., KiCad plugins, Part-DB, Inventree, easyeda2kicad) to look up `Cxxxxxx` part metadata and datasheets?
3. What exact payload/fields are returned by any viable endpoint, and what are the reliability/rate-limit/ToS caveats?

## Answer

Full findings, primary-source citations, and live sample JSON payloads are documented in [../research/01-lcsc-part-metadata-lookup.md](../research/01-lcsc-part-metadata-lookup.md).

1. **Official LCSC OpenAPI (`https://ips.lcsc.com/rest/wmsc2agent/...`) is not viable for a client-side personal app**:
   - Requires B2B partner approval via `support@lcsc.com` (submitting a business license, company website, and estimated order volume).
   - Enforces **static IP whitelisting** (`403: IP not whitelisted` / `5002: The request IP is not authorized`), which blocks mobile clients on dynamic cellular/Wi-Fi IPs unless routed through a fixed-IP backend proxy.
   - Requires SHA-1 request signing (`key`, `nonce`, `timestamp` within 60s, and `secret`).

2. **Primary Unauthenticated Endpoint (`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx`)**:
   - Used by **Part-DB** (`LCSCProvider.php`) and **inventree-part-import** (`supplier_lcsc.py`).
   - Works directly from a native iOS HTTP client without authentication, cookies, or SM2 encryption (which is only used by LCSC's keyword search endpoint).
   - Returns all needed part metadata under `result` (`null` if not found):
     - **MPN & Brand**: `productModel` (`"CC0603KRX7R9BB104"`), `brandNameEn` (`"YAGEO"`)
     - **Name & Description**: `productDescEn ?? productIntroEn ?? productNameEn` (`"100nF ±10% 50V Ceramic Capacitor X7R 0603"`)
     - **Category**: `parentCatalogName` (`"Capacitors"`) & `catalogName` (`"Ceramic Capacitors"`), plus `parentCatalogList`
     - **Package / Footprint**: `encapStandard` (`"0603"`, `"LQFN-56(7x7)"`)
     - **Electrical Parameters**: `paramVOList[]` containing `{ paramCode, paramNameEn, paramValueEn, paramValueEnForSearch, isMain, sort }`
     - **Datasheet PDF URL**: `pdfUrl` (`https://datasheet.lcsc.com/datasheet/pdf/...pdf?productCode=C14663`), which serves `application/pdf` directly from S3/Akamai
     - **Product Page URL**: `https://www.lcsc.com/product-detail/{productCode}.html`
     - **Images & SVGs**: `productImages[]` (900x900 JPEGs) and `edaSvgInfo` (`schSvg`, `pcbSvg`)

3. **Secondary Fallbacks & Implementation Caveats**:
   - **Fallbacks**: JLCPCB (`GET https://cart.jlcpcb.com/shoppingCart/smtGood/getComponentDetail?componentCode=Cxxxxxx` and `POST https://jlcpcb.com/api/overseas-pcb-order/v1/shoppingCart/smtGood/selectSmtComponentList`) and EasyEDA (`GET https://easyeda.com/api/products/Cxxxxxx/components`) also resolve `Cxxxxxx` metadata without authentication.
   - **Caveats**: Send a standard browser `User-Agent` header to avoid WAF blocks, strip HTML tags and `"-"` placeholder values when parsing, persist fetched metadata locally into the on-device JSON store on part creation (avoiding repeated network calls), and treat `Cxxxxxx` lookup as a pre-fill helper that degrades gracefully to manual entry/editing when offline or if the upstream schema changes.
