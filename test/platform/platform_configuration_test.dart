import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release platform configuration declares no optional permissions', () {
    final androidManifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(androidManifest, isNot(contains('<uses-permission')));

    const forbiddenIosUsageKeys = <String>[
      'NSBluetoothAlwaysUsageDescription',
      'NSCameraUsageDescription',
      'NSContactsUsageDescription',
      'NSLocationAlwaysAndWhenInUseUsageDescription',
      'NSLocationWhenInUseUsageDescription',
      'NSMicrophoneUsageDescription',
      'NSPhotoLibraryAddUsageDescription',
      'NSPhotoLibraryUsageDescription',
    ];
    for (final key in forbiddenIosUsageKeys) {
      expect(iosInfo, isNot(contains(key)), reason: '$key must remain absent');
    }
  });
}
