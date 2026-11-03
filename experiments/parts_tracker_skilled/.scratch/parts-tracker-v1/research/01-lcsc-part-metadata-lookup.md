# Research: LCSC (`Cxxxxxx`) Part Metadata Lookup from an iOS Flutter App

## Context & Question

When a user enters an LCSC part code (`Cxxxxxx`, e.g., `C14663`, `C25804`, `C2040`) in the iOS Flutter app, how can the app fetch part metadata—name/description, manufacturer, manufacturer part number (MPN), category, package/footprint, electrical parameters, datasheet URL, and product page URL—directly from the client without a custom backend proxy?

---

## Executive Summary

1. **LCSC's Official OpenAPI (`ips.lcsc.com`) is not viable for a client-side personal app.** It is gated behind a B2B partner application requiring a business license, enforces **static IP whitelisting** (which immediately blocks mobile devices with dynamic IPs via error `403` / `5002`), and requires a shared `secret` to SHA-1 sign every request within a 60-second timestamp window.
2. **LCSC's Web Catalog Product Detail endpoint (`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=Cxxxxxx`) is the clear primary solution.** It is unauthenticated, requires no cookies or encryption for direct `Cxxxxxx` lookups, and returns a single comprehensive JSON payload containing all required metadata, structured electrical parameters (`paramVOList`), 900x900 product image URLs, and a direct S3/Akamai PDF datasheet URL (`pdfUrl`). This is the exact endpoint used by **Part-DB** and **inventree-part-import**.
3. **JLCPCB (`cart.jlcpcb.com` / `jlcpcb.com/api/...`) and EasyEDA (`easyeda.com/api/products/Cxxxxxx/components`) provide unauthenticated secondary/fallback endpoints**, used by **KiCad-JLCPCB-tools** and **easyeda2kicad**, though with slightly less complete parametric or datasheet URL ergonomics than `wmsc.lcsc.com`.

---

## 1. LCSC's Official API Story (`ips.lcsc.com`)

### Primary Sources
- [LCSC API Instruction — Overview, Auth, Error Codes & Terms of Use](https://www.lcsc.com/docs/index.html)
- [LCSC OpenAPI Specification (Redocly)](https://www.lcsc.com/docs/openapi/index.html)

### How It Works
- **Endpoint for Part Details**:
  `GET https://ips.lcsc.com/rest/wmsc2agent/product/info/{product_number}`
- **Onboarding & Approval Requirements**:
  Per LCSC's official documentation, the API is *"mainly for LCSC partners who wish to use our API service to integrate our system with yours."* Obtaining an API key requires emailing `support@lcsc.com` and submitting:
  - Company website
  - Business license (or equivalent corporate certificate)
  - Contact information, estimated order quantity, and cooperation mode
- **Authentication & Request Signing**:
  Every request must include `key`, `nonce` (16-character random string), `timestamp` (Unix epoch seconds; rejected with error `4003` if older than 60 seconds), and an SHA-1 `signature`:
  ```text
  signature = sha1("key={key}&nonce={nonce}&secret={secret}&timestamp={timestamp}")
  ```
- **Static IP Whitelisting**:
  LCSC enforces strict IP whitelisting on `ips.lcsc.com`. Requests from any non-whitelisted IP fail with authorization/system errors:
  - `403` (`IP address`): `"IP not whitelisted, Contact LCSC representative"`
  - `5002`: `"The request IP is not authorized."`
- **Rate Limits**:
  - `429`: `"The client sent too many requests in one minute."`
  - `430`: `"The client exceeded the daily request quota."`

### Verdict on Official API
**Unsuitable for a serverless iOS app.** Even if a developer obtained B2B approval, an iOS app operating over cellular and Wi-Fi networks cannot satisfy static IP whitelisting without routing through a fixed-IP backend proxy, and embedding the signing `secret` in a client binary violates LCSC's API Terms of Use.

---

## 2. Unauthenticated JSON Endpoints Used by Open-Source Tools

Live HTTP verification was performed on **2026-11-03** against `C14663` (YAGEO 100nF 0603 MLCC), `C25804` (UNI-ROYAL 10kΩ 0603 Resistor), `C2040` (Raspberry Pi RP2040 MCU), and `C999999999` (non-existent code).

### Comparison Matrix

| Endpoint | Used By | Auth / Headers Required | MPN, Brand, Category, Package | Structured Electrical Specs | Direct PDF Datasheet URL | Schematic / Footprint SVGs |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **A. LCSC Product Detail**<br>`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode={C_CODE}` | [Part-DB](https://github.com/Part-DB/Part-DB-server/blob/master/src/Services/InfoProviderSystem/Providers/LCSCProvider.php),<br>[inventree-part-import](https://github.com/30350n/inventree-part-import/blob/master/inventree_part_import/suppliers/supplier_lcsc.py) | None (Browser `User-Agent` recommended) | Yes (`productModel`, `brandNameEn`, `parentCatalogName`, `catalogName`, `encapStandard`) | **Yes** (`paramVOList` with `isMain`, `sort`, and numeric search values) | **Yes** (`pdfUrl` serves `application/pdf` directly) | Yes (URLs in `edaSvgInfo`) |
| **B1. JLCPCB Component Detail**<br>`GET https://cart.jlcpcb.com/shoppingCart/smtGood/getComponentDetail?componentCode={C_CODE}` | [KiCad-JLCPCB-tools](https://github.com/Bouni/kicad-jlcpcb-tools/blob/main/lcsc_api.py) | Browser `User-Agent` required | Yes (`componentModelEn`, `componentBrandEn`, `componentSpecificationEn`) | Yes (`attributes` array) | Partial (`dataManualUrl` points to an HTML viewer wrapper) | No |
| **B2. JLCPCB SMT Search**<br>`POST https://jlcpcb.com/api/overseas-pcb-order/v1/shoppingCart/smtGood/selectSmtComponentList` | [easyeda2kicad.py](https://github.com/uPesy/easyeda2kicad.py/blob/master/easyeda2kicad/easyeda/easyeda_api.py) | Browser `User-Agent` + `Content-Type: application/json` | Yes (`componentModelEn`, `componentBrandEn`, `firstSortName`, `secondSortName`, `componentSpecificationEn`) | Yes (`attributes` array) | Partial | No |
| **C. EasyEDA Component API**<br>`GET https://easyeda.com/api/products/{C_CODE}/components` & `/svgs` | [easyeda2kicad.py](https://github.com/uPesy/easyeda2kicad.py/blob/master/easyeda2kicad/easyeda/easyeda_api.py) | None (Browser `User-Agent` recommended) | Yes (`dataStr.head.c_para` & `tags`) | Minimal (only `Value` and `description`) | No | **Yes** (Full CAD JSON & pre-rendered SVGs) |

---

### Endpoint A (Recommended Primary): `wmsc.lcsc.com/ftps/wm/product/detail`

- **Request**:
  ```http
  GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=C14663 HTTP/2
  Host: wmsc.lcsc.com
  User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1
  Accept: application/json
  Accept-Language: en-US,en;q=0.9
  ```
- **Note on Lookup vs. Keyword Search**:
  In `inventree-part-import` ([`supplier_lcsc.py`](https://github.com/30350n/inventree-part-import/blob/master/inventree_part_import/suppliers/supplier_lcsc.py)), the global keyword search endpoint (`POST https://wmsc.lcsc.com/ftps/wm/search/v3/global`) requires scraping an SM2 public key (`encryptPublicHexKey`) from `www.lcsc.com` to encrypt the search keyword. However, as verified via `curl` and in `Part-DB` ([`LCSCProvider.php`](https://github.com/Part-DB/Part-DB-server/blob/master/src/Services/InfoProviderSystem/Providers/LCSCProvider.php)), **direct `Cxxxxxx` lookup via `GET /ftps/wm/product/detail?productCode=Cxxxxxx` does not use SM2 encryption or require any session/cookie initialization.**

#### Field Mapping for the App's Domain Model

| App Field | JSON Path in `result` | Example (`C14663`) | Example (`C2040` — RP2040) | Fallback / Parsing Notes |
| :--- | :--- | :--- | :--- | :--- |
| **LCSC Part Code** | `result.productCode` | `"C14663"` | `"C2040"` | Canonical `Cxxxxxx` identifier. |
| **MPN** | `result.productModel` | `"CC0603KRX7R9BB104"` | `"RP2040"` | Manufacturer Part Number. |
| **Manufacturer** | `result.brandNameEn` | `"YAGEO"` | `"Raspberry Pi"` | Strip HTML tags if any. |
| **Short Title / Name** | `result.productNameEn` (or `result.title`) | `"CAP CER 100nF 50V X7R 0603"` | `"A microcontroller"` (`title`: `"Raspberry Pi RP2040"`) | On ICs, `productNameEn` can be generic (`"A microcontroller"`); combine with `productIntroEn` or `title`. |
| **Description** | `result.productDescEn ?? result.productIntroEn` | `"100nF ±10% 50V Ceramic Capacitor X7R 0603"` | `null` / `"ARM Cortex-M0+ 32 Bit 133MHz LQFN-56(7x7) Microcontrollers "` | `productDescEn` is `null` on `C2040`, while `productIntroEn` is populated. Always fallback: `productDescEn ?? productIntroEn ?? productNameEn`. |
| **Category Hierarchy** | `result.parentCatalogName` → `result.catalogName` (plus `result.parentCatalogList`) | `"Capacitors"` → `"Ceramic Capacitors"` | `"Embedded Processors & Controllers"` → `"Microcontrollers"` | `parentCatalogList` also includes top-level group (e.g., `"Passives"`, `"Integrated Circuits (ICs)"`). |
| **Package / Footprint** | `result.encapStandard` | `"0603"` | `"LQFN-56(7x7)"` | Treat `"-"` or empty string as `null` (per `Part-DB`). |
| **Electrical Parameters** | `result.paramVOList[]` | `Capacitance: 100nF`, `Voltage Rating: 50V`, `Tolerance: ±10%`, `Temperature Coefficient: X7R` | `CPU Core: ARM Cortex-M0+`, `Core Size: 32 Bit`, `CPU Maximum Speed: 133MHz`, `Voltage - Supply: 1.8V~3.3V`, etc. | Each item has `paramNameEn`, `paramValueEn`, `paramValueEnForSearch` (normalized float!), `isMain` (bool), and `sort` (int). Ignore items where `paramValueEn` is `"-"` or `""`. |
| **Datasheet PDF URL** | `result.pdfUrl` | `"https://datasheet.lcsc.com/datasheet/pdf/23ccee80ee542e7cf156a772bb589942.pdf?productCode=C14663"` | `"https://datasheet.lcsc.com/datasheet/pdf/3dad1d8f987a4e00bfc677055df1f959.pdf?productCode=C2040"` | **Use `pdfUrl` directly.** Verified via `curl -I` to return `HTTP/2 200` with `content-type: application/pdf` from S3/Akamai. *(Do not apply the legacy `inventree-part-import` rewrite to `wmsc.lcsc.com/wmsc/upload/file/pdf/v2/`, which now returns a 117-byte HTML stub.)* |
| **Product Page URL** | Constructed from `result.productCode` | `"https://www.lcsc.com/product-detail/C14663.html"` | `"https://www.lcsc.com/product-detail/C2040.html"` | `Part-DB` uses `https://www.lcsc.com/product-detail/{productCode}.html`, which LCSC resolves directly to the canonical product page. |
| **Product Images** | `result.productImages[]` | `["https://assets.lcsc.com/images/lcsc/900x900/20250715_YAGEO-CC0603KRX7R9BB104_C14663_front.jpg", ...]` | `["https://assets.lcsc.com/images/lcsc/900x900/20230217_Raspberry-Pi-RP2040_C2040_front.jpg", ...]` | High-res 900x900 JPEGs (`_front.jpg`, `_back.jpg`, `_blank.jpg`). |
| **JLCPCB SMT Tier** | `result.smtLabel` | `"BASE"` | `"EXPAND"` (or `null`) | Indicates JLCPCB `"BASE"` (Basic Part) vs `"EXPAND"` (Extended Part). |

#### Sample Trimmed Response (`GET https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=C14663`)

```json
{
  "code": 200,
  "msg": null,
  "result": {
    "parentCatalogList": [
      { "catalogId": 30, "catalogNameEn": "Passives" },
      { "catalogId": 495, "catalogNameEn": "Capacitors" }
    ],
    "productId": 15331,
    "productCode": "C14663",
    "productModel": "CC0603KRX7R9BB104",
    "productNameEn": "CAP CER 100nF 50V X7R 0603",
    "productKeyAttributes": "CAP CER 100nF 50V X7R 0603",
    "parentCatalogId": 312,
    "parentCatalogName": "Capacitors",
    "catalogId": 1142,
    "catalogName": "Ceramic Capacitors",
    "brandId": 396,
    "brandNameEn": "YAGEO",
    "encapStandard": "0603",
    "productUnit": "Piece",
    "minPacketUnit": "Reel",
    "minBuyNumber": 50,
    "minPacketNumber": 4000,
    "stockNumber": 79400,
    "productPriceList": [
      {
        "ladder": 50,
        "productPrice": "0.0082",
        "usdPrice": 0.0082,
        "currencyPrice": 0.0082,
        "currencySymbol": "$"
      }
    ],
    "productImages": [
      "https://assets.lcsc.com/images/lcsc/900x900/20250715_YAGEO-CC0603KRX7R9BB104_C14663_front.jpg",
      "https://assets.lcsc.com/images/lcsc/900x900/20250715_YAGEO-CC0603KRX7R9BB104_C14663_back.jpg",
      "https://assets.lcsc.com/images/lcsc/900x900/20250715_YAGEO-CC0603KRX7R9BB104_C14663_blank.jpg"
    ],
    "edaSvgInfo": {
      "schSvg": "//image.easyeda.com/component_svgs/prod/154b66255b01a09bf1c88bb1ea89be78.svg?t=1785199256",
      "pcbSvg": "//image.easyeda.com/component_svgs/prod/f8151fdc728a41ebbc304e11d39e5437.svg?t=1785199256"
    },
    "pdfUrl": "https://datasheet.lcsc.com/datasheet/pdf/23ccee80ee542e7cf156a772bb589942.pdf?productCode=C14663",
    "productDescEn": "100nF ±10% 50V Ceramic Capacitor X7R 0603",
    "productIntroEn": "100nF ±10% 50V Ceramic Capacitor X7R 0603",
    "paramVOList": [
      {
        "paramCode": "param_10951_n",
        "paramName": "容值",
        "paramNameEn": "Capacitance",
        "paramValue": "100nF",
        "paramValueEn": "100nF",
        "paramValueEnForSearch": 100000.0,
        "isMain": true,
        "sortNumber": 1,
        "sort": 1
      },
      {
        "paramCode": "param_10923_s",
        "paramName": "精度",
        "paramNameEn": "Tolerance",
        "paramValue": "±10%",
        "paramValueEn": "±10%",
        "paramValueEnForSearch": null,
        "isMain": true,
        "sortNumber": 1,
        "sort": 2
      },
      {
        "paramCode": "param_10924_n",
        "paramName": "额定电压",
        "paramNameEn": "Voltage Rating",
        "paramValue": "50V",
        "paramValueEn": "50V",
        "paramValueEnForSearch": 50.0,
        "isMain": true,
        "sortNumber": 1,
        "sort": 3
      },
      {
        "paramCode": "param_10927",
        "paramName": "温度系数",
        "paramNameEn": "Temperature Coefficient",
        "paramValue": "X7R",
        "paramValueEn": "X7R",
        "paramValueEnForSearch": -1.0,
        "isMain": true,
        "sortNumber": 1,
        "sort": 4
      }
    ],
    "title": "YAGEO CC0603KRX7R9BB104",
    "smtLabel": "BASE"
  },
  "ok": true
}
```

#### Not-Found Response (`productCode=C999999999`)
When a `Cxxxxxx` code does not exist, the endpoint returns HTTP `200` with `result: null`:
```json
{
  "code": 200,
  "msg": null,
  "result": null,
  "ok": true
}
```

---

### Endpoint B (Secondary Fallback): JLCPCB Component APIs

1. **`GET https://cart.jlcpcb.com/shoppingCart/smtGood/getComponentDetail?componentCode=C14663`**
   - Source: [`Bouni/kicad-jlcpcb-tools` (`lcsc_api.py`)](https://github.com/Bouni/kicad-jlcpcb-tools/blob/main/lcsc_api.py)
   - Returns `data.componentCode`, `data.componentBrandEn`, `data.componentModelEn`, `data.componentSpecificationEn` (`"0603"`), `data.describe`, and `data.attributes` (`[{"attribute_name_en": "Voltage Rating", "attribute_value_name": "50V"}, ...]`).
2. **`POST https://jlcpcb.com/api/overseas-pcb-order/v1/shoppingCart/smtGood/selectSmtComponentList`**
   - Source: [`uPesy/easyeda2kicad.py` (`easyeda_api.py`)](https://github.com/uPesy/easyeda2kicad.py/blob/master/easyeda2kicad/easyeda/easyeda_api.py)
   - Note: Requires `/api/` prefix (`https://jlcpcb.com/api/overseas-pcb-order/...`); calling `https://jlcpcb.com/overseas-pcb-order/...` without `/api/` returns an SSR HTML page.
   - Request body: `{"currentPage": 1, "pageSize": 5, "keyword": "C14663"}`.
   - Returns `data.componentPageInfo.list[0]` with `componentCode`, `componentModelEn`, `componentBrandEn`, `componentSpecificationEn`, `firstSortName`, `secondSortName`, `lcscGoodsUrl`, `describe`, and `attributes`.

---

### Endpoint C (CAD/SVG Supplement): EasyEDA Component APIs

- **`GET https://easyeda.com/api/products/C14663/components?version=6.4.19.5`** and **`GET https://easyeda.com/api/products/C14663/svgs`**
  - Source: [`uPesy/easyeda2kicad.py` (`easyeda_api.py`)](https://github.com/uPesy/easyeda2kicad.py/blob/master/easyeda2kicad/easyeda/easyeda_api.py)
  - Returns `result.dataStr.head.c_para` (`{"pre": "C?", "name": "CC0603KRX7R9BB104", "package": "C0603", "Manufacturer": "YAGEO(国巨)", "Manufacturer Part": "CC0603KRX7R9BB104", "Value": "100nF", "Supplier Part": "C14663", "JLCPCB Part Class": "Basic Part"}`) and pre-rendered symbol/footprint SVGs.
  - **Caveat**: Does not return a datasheet URL or full electrical parameter array, and embeds a license notice inside `result.dataStr.head.license` requiring prominent attribution to `"JLCEDA/EasyEDA Official Library"`.

---

## 3. Reliability, Rate-Limit, and ToS Caveats for V1 Design

1. **No CORS Restrictions on Native iOS**:
   Flutter on iOS uses native HTTP sockets (`dart:io` / `package:http`), so browser CORS headers do not restrict calling `wmsc.lcsc.com` or `cart.jlcpcb.com` directly from the device.
2. **Send a Browser `User-Agent`**:
   Both `Bouni/kicad-jlcpcb-tools` and `30350n/inventree-part-import` explicitly set a browser `User-Agent` header (e.g., iOS Safari `Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)...`) and `Accept-Language: en-US,en` because default HTTP client User-Agents (such as `Dart/3.x`) can be blocked by Akamai/Cloudflare WAF rules.
3. **Cache Fetched Metadata On-Device (Fetch-On-Add, Persist Locally)**:
   Because the app is offline-first and stores inventory as on-device JSON, `wmsc.lcsc.com` should only be queried when adding a part by `Cxxxxxx` code (or when the user explicitly taps "Refresh from LCSC"). Once fetched, the metadata (MPN, manufacturer, category, package, parameters, datasheet URL, product page URL) should be saved directly into the part record in local JSON storage.
4. **Defensive Parsing & Graceful Fallback to Manual Entry**:
   Because `wmsc.lcsc.com/ftps/wm/product/detail` is an undocumented first-party web endpoint:
   - Strip HTML tags from text fields (`brandNameEn`, `productIntroEn`, `productDescEn`, `encapStandard`), as LCSC occasionally includes inline HTML markup.
   - Normalize `"-" ` values in `encapStandard` and `paramVOList[].paramValueEn` to `null`/omitted.
   - Strip trailing `alternatePartList` when persisting, as `alternatePartList` accounts for ~85% of the ~63 KB JSON response payload.
   - Always treat lookup as a **form pre-fill assistant**: if the device is offline, the `Cxxxxxx` code is not found (`result: null`), or the schema changes, the user can still enter or edit all fields manually.
5. **Terms of Service (ToS)**:
   LCSC's API Terms of Use prohibit bulk data scraping, reselling data, or re-hosting datasheets/images for third parties. On-demand single-part lookup triggered by a human user entering a `Cxxxxxx` code in a personal inventory app generates negligible traffic (a few requests per session) and stores metadata only on the user's personal device.
