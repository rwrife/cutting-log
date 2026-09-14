/// The built-in plant icon palette users can attach to a parent plant.
///
/// Keys are stable identifiers persisted in the database and in backup
/// archives; display labels live here so screens readers and the picker UI
/// always agree on what an icon means. Unknown or removed keys degrade to
/// "no icon" rather than failing — restoring an archive written by a future
/// palette must never break the journal.
final class PlantIconOption {
  const PlantIconOption({required this.key, required this.label});

  final String key;
  final String label;
}

final class PlantIcons {
  const PlantIcons._();

  static const List<PlantIconOption> options = <PlantIconOption>[
    PlantIconOption(key: 'eco', label: 'Leaf'),
    PlantIconOption(key: 'forest', label: 'Forest'),
    PlantIconOption(key: 'park', label: 'Park tree'),
    PlantIconOption(key: 'grass', label: 'Grass'),
    PlantIconOption(key: 'grain', label: 'Grain'),
    PlantIconOption(key: 'local_florist', label: 'Flower'),
    PlantIconOption(key: 'spa', label: 'Plant leaves'),
    PlantIconOption(key: 'yard', label: 'Yard'),
    PlantIconOption(key: 'water_drop', label: 'Water'),
    PlantIconOption(key: 'wb_sunny', label: 'Sun'),
    PlantIconOption(key: 'terrain', label: 'Soil mound'),
    PlantIconOption(key: 'emoji_nature', label: 'Bug-friendly plant'),
  ];

  static PlantIconOption? findByKey(String? key) {
    if (key == null) return null;
    for (final option in options) {
      if (option.key == key) return option;
    }
    return null;
  }

  /// Returns [key] when it names a known palette entry and null otherwise,
  /// so an unknown or absent selection is stored as "no icon" instead of
  /// throwing.
  static String? normalizeSelection(String? key) => findByKey(key)?.key;
}
