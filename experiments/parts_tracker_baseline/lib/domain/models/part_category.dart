/// Categories of electronic components tracked in the inventory.
enum PartCategory {
  resistors(
    id: 'resistors',
    label: 'Resistors',
  ),
  capacitors(
    id: 'capacitors',
    label: 'Capacitors',
  ),
  inductors(
    id: 'inductors',
    label: 'Inductors',
  ),
  icsAndMcus(
    id: 'ics_mcus',
    label: 'ICs & MCUs',
  ),
  semiconductors(
    id: 'semiconductors',
    label: 'Semiconductors',
  ),
  ledsAndDisplays(
    id: 'leds_displays',
    label: 'LEDs & Displays',
  ),
  sensors(
    id: 'sensors',
    label: 'Sensors',
  ),
  connectors(
    id: 'connectors',
    label: 'Connectors',
  ),
  powerAndModules(
    id: 'power_modules',
    label: 'Power & Modules',
  ),
  electromechanical(
    id: 'electromechanical',
    label: 'Switches & Relays',
  ),
  other(
    id: 'other',
    label: 'Other',
  );

  const PartCategory({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  /// Resolves a [PartCategory] from its serialized [id] or label,
  /// defaulting to [PartCategory.other] if unrecognized.
  static PartCategory fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final category in PartCategory.values) {
      if (category.id.toLowerCase() == normalized ||
          category.label.toLowerCase() == normalized ||
          category.name.toLowerCase() == normalized) {
        return category;
      }
    }
    return PartCategory.other;
  }
}
