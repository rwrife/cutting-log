import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release configuration declares only user-initiated notifications', () {
    final androidManifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      RegExp(r'<uses-permission').allMatches(androidManifest),
      hasLength(2),
    );
    expect(androidManifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(
      androidManifest,
      contains('android.permission.RECEIVE_BOOT_COMPLETED'),
    );
    expect(androidManifest, isNot(contains('android.permission.INTERNET')));

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
