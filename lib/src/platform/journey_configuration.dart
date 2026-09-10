import 'dart:io';
import 'dart:typed_data';

import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:image/image.dart' as img;

/// Test-only switch used by the automated device journey
/// (`integration_test/offline_journal_e2e_test.dart`).
///
/// Production code never sets this flag, so shipped builds keep the full
/// in-context permission behavior. The automated journey enables it before
/// `app.main()` so the run exercises deterministic, non-blocking capability
/// paths instead of native permission dialogs or the system photo picker,
/// which an instrumented test cannot answer without freezing the app under
/// test. Everything else in the journey (real Drift file database, real
/// app-private media store writes, thumbnail generation, ZIP export/restore,
/// erase) stays real.
final class JourneyConfiguration {
  JourneyConfiguration._();

  /// True only inside an integration-test process that explicitly enabled it.
  static bool isIntegrationTest = false;

  /// Called by the integration journey before starting the app.
  static void enableForIntegrationTest() => isIntegrationTest = true;
}

/// Notification gateway for the automated journey: state checks, scheduling,
/// and cancellation stay on the real platform implementation. Only
/// `requestPermission` is deferred to the current state so the run can never
/// block on the OS notification prompt that automation cannot answer. This
/// matches the documented product contract "check-ins remain in-app when
/// notifications are denied."
final class JourneyDeferredNotificationGateway
    implements LocalNotificationGateway {
  JourneyDeferredNotificationGateway(this.inner);

  final LocalNotificationGateway inner;

  @override
  Future<void> initialize() => inner.initialize();

  @override
  Future<NotificationPermissionState> permissionState() =>
      inner.permissionState();

  @override
  Future<NotificationPermissionState> requestPermission() =>
      inner.permissionState();

  @override
  Future<Set<String>> pendingIds() => inner.pendingIds();

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) =>
      inner.schedule(reminder, cuttingName);

  @override
  Future<void> cancel(String platformId) => inner.cancel(platformId);
}

/// Optional-permission gateway for the automated journey: reports the grant
/// outcome without opening the system settings dialog. On Android the
/// journey additionally pre-grants the permissions via `adb shell pm grant`,
/// so this wrapper keeps parity with what the runner prepared; on iOS it
/// avoids the native prompt that automation cannot answer.
final class JourneyAutoGrantPermissionGateway
    implements OptionalPermissionGateway {
  const JourneyAutoGrantPermissionGateway();

  @override
  Future<bool> request(OptionalPermission permission) async => true;
}

/// Photo import gateway for the automated journey: returns a real small PNG
/// file on the device filesystem instead of opening the native picker (which
/// automation cannot complete). The returned file then flows through the
/// production pipeline: app-private store copy, thumbnail generation, media
/// record, and timeline rendering are all exercised for real.
final class JourneySyntheticPhotoGateway implements PhotoImportGateway {
  const JourneySyntheticPhotoGateway();

  static final Uint8List _pngBytes = _buildPng();

  static Uint8List _buildPng() {
    final image = img.Image(width: 64, height: 64);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, 50, 120 + (x % 40), 180 + (y % 40), 255);
      }
    }
    return Uint8List.fromList(img.encodePng(image));
  }

  @override
  Future<PickedPhoto?> pick(PhotoImportSource source) async {
    final file = File(
      '${Directory.systemTemp.path}/'
      'cutting-log-e2e-photo-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(_pngBytes, flush: true);
    return PickedPhoto(
      path: file.path,
      source: source,
      pickedAtUtc: DateTime.now().toUtc(),
    );
  }
}
