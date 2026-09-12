import 'dart:io';

import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/journey_configuration.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Fresh targeted verification for the automated device journey scaffold.
/// The journey itself runs on CI emulators/simulators; these tests pin the
/// local contract of the swap-in gateways so a broken scaffold fails fast
/// in the unit suite instead of after an expensive device run.
void main() {
  test('journey flag is opt-in and defaults to false', () {
    expect(JourneyConfiguration.isIntegrationTest, isFalse);
  });

  test('notification wrapper defers requests to the current state', () async {
    final inner = _StateGateway(state: NotificationPermissionState.denied);
    final gateway = JourneyDeferredNotificationGateway(inner);

    // Requesting never prompts (never mutates the inner state) and reports
    // the current state, matching the in-app-only product contract.
    expect(
      await gateway.requestPermission(),
      NotificationPermissionState.denied,
    );
    expect(inner.requestCalls, 0);

    final reminder = _reminder();
    await gateway.schedule(reminder, 'Cutting');
    expect(inner.scheduled, contains(reminder.platformNotificationId));
    await gateway.cancel(reminder.platformNotificationId!);
    expect(inner.scheduled, isEmpty);
  });

  test(
    'permission wrapper reports grants for every optional capability',
    () async {
      const gateway = JourneyAutoGrantPermissionGateway();
      for (final permission in OptionalPermission.values) {
        expect(await gateway.request(permission), isTrue);
      }
    },
  );

  test('synthetic photo gateway yields a decodable PNG file', () async {
    const gateway = JourneySyntheticPhotoGateway();
    final picked = await gateway.pick(PhotoImportSource.photoLibrary);
    expect(picked, isNotNull);
    final file = File(picked!.path);
    expect(file.existsSync(), isTrue);
    final decoded = img.decodePng(file.readAsBytesSync());
    expect(decoded, isNotNull, reason: 'Bytes must decode as PNG.');
    expect(decoded!.width, 64);
    expect(decoded.height, 64);
    expect(picked.source, PhotoImportSource.photoLibrary);
    file.deleteSync();
  });
}

Reminder _reminder() => Reminder(
  id: EntityId('journey-reminder'),
  cuttingId: EntityId('journey-cutting'),
  scheduledForUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
  timeZoneId: 'UTC',
  status: ReminderStatus.pending,
  platformNotificationId: '4242',
  createdAtUtc: DateTime.now().toUtc(),
  updatedAtUtc: DateTime.now().toUtc(),
);

final class _StateGateway implements LocalNotificationGateway {
  _StateGateway({required this.state});

  NotificationPermissionState state;
  int requestCalls = 0;
  final Set<String> scheduled = <String>{};

  @override
  Future<void> cancel(String platformId) async => scheduled.remove(platformId);

  @override
  Future<void> initialize() async {}

  @override
  Future<Set<String>> pendingIds() async => Set<String>.from(scheduled);

  @override
  Future<NotificationPermissionState> permissionState() async => state;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    requestCalls++;
    return state;
  }

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) async {
    scheduled.add(reminder.platformNotificationId!);
  }
}
