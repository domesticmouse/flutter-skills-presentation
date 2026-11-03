# Electronics Parts Tracker

A personal iOS application for cataloging electronics components, their quantities on hand, their physical workbench storage locations, and their supplier/LCSC metadata.

## Language

**Part**:
A distinct electronic component entry in the catalog (e.g., `10kΩ 0603 1% Resistor`, `NE555P`, `ESP32-WROOM-32E`), tracking a single quantity on hand, an optional `(Container, Slot)` location, package/footprint, optional LCSC code (`Cxxxxxx`), and electrical **Specs**.
_Avoid_: Item, product, SKU, device

**Spec**:
A named electrical or physical attribute of a **Part** (e.g., `Capacitance: 100nF`, `Voltage Rated: 50V`, `Tolerance: ±10%`), represented as an ordered key-value pair on the Part.
_Avoid_: Parameter, property, custom field, tag

**Container**:
A top-level physical storage unit at the workbench (e.g., `"SMD Binder #1"`, `"IC Drawer Cabinet"`, `"Passives Grid Box A"`), tracked as a first-class entity with a name and optional description.
_Avoid_: Warehouse, building, parent location

**Slot**:
A named compartment, drawer, cell, or strip inside a **Container** (e.g., `"A1"`, `"Drawer 12"`, `"Page 4"`), represented as a string label created on the fly. A **Slot** holds at most one **Part** (`(Container, Slot)` is strictly 1-to-1 when a Slot is specified).
_Avoid_: Sub-location, child location, bin (when referring to the top-level container)
