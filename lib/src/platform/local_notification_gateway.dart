import 'package:cutting_log/src/domain/journal_entities.dart';

enum NotificationPermissionState { granted, denied }

/// Narrow, local-only boundary for notifications owned by this application.
abstract interface class LocalNotificationGateway {
  Future<void> initialize();

  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<Set<String>> pendingIds();

  Future<void> schedule(Reminder reminder, String cuttingName);

  Future<void> cancel(String platformId);
}

/// Keeps the journal and in-app due list useful on unsupported platforms.
final class DisabledLocalNotificationGateway
    implements LocalNotificationGateway {
  const DisabledLocalNotificationGateway();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.denied;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.denied;

  @override
  Future<Set<String>> pendingIds() async => const <String>{};

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) async {}

  @override
  Future<void> cancel(String platformId) async {}
}
