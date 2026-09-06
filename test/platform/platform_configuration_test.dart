import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release configuration declares only user-initiated capabilities', () {
    final androidManifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      RegExp(r'<uses-permission').allMatches(androidManifest),
      hasLength(3),
    );
    expect(androidManifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(
      androidManifest,
      contains('android.permission.RECEIVE_BOOT_COMPLETED'),
    );
    expect(androidManifest, contains('android.permission.CAMERA'));
    expect(androidManifest, isNot(contains('android.permission.INTERNET')));

    expect(iosInfo, contains('NSCameraUsageDescription'));
    expect(iosInfo, contains('NSPhotoLibraryUsageDescription'));

    const forbiddenIosUsageKeys = <String>[
      'NSBluetoothAlwaysUsageDescription',
      'NSContactsUsageDescription',
      'NSLocationAlwaysAndWhenInUseUsageDescription',
      'NSLocationWhenInUseUsageDescription',
      'NSMicrophoneUsageDescription',
      'NSPhotoLibraryAddUsageDescription',
    ];
    for (final key in forbiddenIosUsageKeys) {
      expect(iosInfo, isNot(contains(key)), reason: '$key must remain absent');
    }
  });
}
