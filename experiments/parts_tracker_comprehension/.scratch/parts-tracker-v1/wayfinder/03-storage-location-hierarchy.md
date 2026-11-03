# Issue 03: Physical storage location hierarchy and addressing

Type: grilling
Status: resolved

## Question

How should **Storage Locations** be structured and addressed so they match your actual physical workbench setup (e.g., Akro-Mils drawer cabinets, SMD sample books/binders, assortment boxes with grid cells, anti-static bags in totes)?

Key decisions to resolve:
1. **Hierarchy model**: Flat labels (e.g., `"Cabinet A - R3C4"`), fixed 2-level (`Container → Slot`), or arbitrary nesting (`Room/Shelf → Cabinet → Drawer → Compartment`)?
2. **Grid / coordinate addressing**: Do you want first-class support for grid coordinates (e.g., rows `A–F` × columns `1–8`, or numbered binder pages/strips) for visual bin-finding, or simple named locations?
3. **Location lifecycle**: Moving parts between locations, viewing everything inside a container/drawer, and handling unlocated ("loose / to-be-sorted") parts.

## Answer

1. **Fixed two-level hierarchy (`Container` → `Slot`)**:
   - **Container** is a first-class managed entity (`id`, `name`, optional `description`) so containers can be created, listed, browsed, and renamed cleanly in one place.
   - **Slot** is a simple string label (e.g., `"A1"`, `"Drawer 12"`) stored on the **Part** and created on the fly—no pre-configured grid dimensions or 2D grid generator required.
2. **Strict 1-Part-per-Slot uniqueness**:
   - When a **Part** has both a `containerId` and a non-empty `slot` label, the `(containerId, slot)` pair is strictly unique (at most 1 Part per Slot).
   - Assigning a Part to an already-occupied `(Container, Slot)` is prevented by default (or warns/offers to displace the occupying part).
3. **Unassigned and slotless parts**:
   - Both `containerId` and `slot` on a Part are optional.
   - Newly arrived or loose parts can have `containerId: null, slot: null` ("Unassigned"), and parts stored in a bulk container without compartments can have a `containerId` with `slot: null`. Multiple parts can be unassigned or slotless inside the same Container without conflict.
