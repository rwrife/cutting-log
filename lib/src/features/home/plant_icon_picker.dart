import 'package:cutting_log/src/domain/plant_icons.dart';
import 'package:flutter/material.dart';

/// Maps persisted icon keys onto Material glyphs. Kept separate from the
/// domain palette (which is framework-light and test-pure) so the stored
/// keys never depend on Flutter symbol names.
IconData? plantIconDataFor(String? key) => switch (key) {
  'eco' => Icons.eco,
  'forest' => Icons.forest,
  'park' => Icons.park,
  'grass' => Icons.grass,
  'grain' => Icons.grain,
  'local_florist' => Icons.local_florist,
  'spa' => Icons.spa,
  'yard' => Icons.yard,
  'water_drop' => Icons.water_drop_outlined,
  'wb_sunny' => Icons.wb_sunny_outlined,
  'terrain' => Icons.terrain,
  'emoji_nature' => Icons.emoji_nature_outlined,
  _ => null,
};

/// Icon leading for a parent plant list row: the chosen glyph, or the plain
/// default leaf so rows never look broken when no icon was picked.
Widget parentIconLeading(String? iconKey) => Icon(
  plantIconDataFor(iconKey) ?? Icons.eco_outlined,
  semanticLabel: PlantIcons.findByKey(iconKey) == null
      ? 'Default plant icon'
      : 'Plant icon: ${PlantIcons.findByKey(iconKey)!.label}',
);

/// Bottom sheet grid where the user picks (or clears) a parent plant's icon.
/// Returns the chosen key, or null when dismissed without a change.
Future<String?> showPlantIconPicker(
  BuildContext context, {
  required String? selectedKey,
}) => showModalBottomSheet<String>(
  context: context,
  showDragHandle: true,
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Choose a plant icon',
            style: Theme.of(sheetContext).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text('Optional. The icon only marks the plant in your lists.'),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  for (final option in PlantIcons.options)
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: _IconChoice(
                        option: option,
                        selected: option.key == selectedKey,
                        onTap: () => Navigator.pop(sheetContext, option.key),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const ValueKey<String>('clear-plant-icon'),
            onPressed: () =>
                Navigator.pop(sheetContext, kClearPlantIconSentinel),
            icon: const Icon(Icons.clear),
            label: const Text('No icon'),
          ),
        ],
      ),
    ),
  ),
);

/// Sentinel distinct from "dismissed without choosing" (which pops null).
const String kClearPlantIconSentinel = '';

/// Resolves the picker result into the key to persist: `changed: false` when
/// the sheet was dismissed without choosing, otherwise the new [key] — or
/// null for the explicit "No icon" choice.
({bool changed, String? key}) plantIconSelectionFrom(String? pickerResult) =>
    switch (pickerResult) {
      null => (changed: false, key: null),
      kClearPlantIconSentinel => (changed: true, key: null),
      _ => (changed: true, key: pickerResult),
    };

final class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PlantIconOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${option.label} icon${selected ? ', selected' : ''}',
    child: InkWell(
      key: ValueKey<String>('plant-icon-${option.key}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(plantIconDataFor(option.key) ?? Icons.eco_outlined, size: 32),
            const SizedBox(height: 4),
            Text(
              option.label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
