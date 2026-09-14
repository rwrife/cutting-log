import 'package:cutting_log/src/domain/plant_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('palette offers a dozen or so distinct icons', () {
    expect(PlantIcons.options.length, greaterThanOrEqualTo(12));
    expect(PlantIcons.options.length, lessThanOrEqualTo(16));

    final keys = PlantIcons.options.map((option) => option.key).toSet();
    expect(keys, hasLength(PlantIcons.options.length));
    for (final option in PlantIcons.options) {
      expect(option.key, isNotEmpty);
      expect(option.label, isNotEmpty);
    }
  });

  test('selection normalization is total and unknown-safe', () {
    for (final option in PlantIcons.options) {
      expect(PlantIcons.normalizeSelection(option.key), option.key);
    }
    expect(PlantIcons.normalizeSelection(null), isNull);
    expect(PlantIcons.normalizeSelection(''), isNull);
    expect(PlantIcons.normalizeSelection('no_such_icon'), isNull);
  });
}
