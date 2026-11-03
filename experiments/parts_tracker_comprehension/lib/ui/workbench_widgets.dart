import 'package:flutter/material.dart';

import '../catalog/catalog_models.dart' as models;
import '../catalog/catalog_models.dart' show Part;

String formatPartLocation(
  Part part,
  Map<String, models.Container> containerMap,
) {
  if (part.containerId == null) return 'Unassigned';
  final container = containerMap[part.containerId!];
  final containerName = container?.name ?? 'Unknown Container';
  if (part.slot == null || part.slot!.trim().isEmpty) {
    return '$containerName (Bulk)';
  }
  return '$containerName · ${part.slot}';
}

String pluralizeCount(int count, String noun) =>
    count == 1 ? '1 $noun' : '$count ${noun}s';

class QuantityQuickStepperButtons extends StatelessWidget {
  const QuantityQuickStepperButtons({
    super.key,
    required this.onAdjust,
    this.compact = false,
  });

  final ValueChanged<int> onAdjust;
  final bool compact;

  static const List<int> deltas = [-10, -1, 1, 10];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 6 : 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final delta in deltas)
          FilledButton.tonal(
            style: compact
                ? FilledButton.styleFrom(
                    minimumSize: const Size(42, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : null,
            onPressed: () => onAdjust(delta),
            child: Text(
              delta > 0 ? '+$delta' : '$delta',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : null,
              ),
            ),
          ),
      ],
    );
  }
}

class BadgePill extends StatelessWidget {
  const BadgePill({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    this.monospace = false,
  });

  final String text;
  final Color color;
  final Color textColor;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: monospace ? 'Courier' : null,
          color: textColor,
        ),
      ),
    );
  }
}
