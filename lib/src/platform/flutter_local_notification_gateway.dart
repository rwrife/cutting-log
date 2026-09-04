import 'dart:io';

import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final class FlutterLocalNotificationGateway
    implements LocalNotificationGateway {
  FlutterLocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    if (Platform.isIOS) {
      final settings = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return settings?.isEnabled == true
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }
    return NotificationPermissionState.denied;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    bool? granted;
    if (Platform.isAndroid) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    return granted == true
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }

  @override
  Future<Set<String>> pendingIds() async =>
      (await _plugin.pendingNotificationRequests())
          .map((request) => '${request.id}')
          .toSet();

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) async {
    final platformId = int.parse(reminder.platformNotificationId!);
    final location = tz.getLocation(reminder.timeZoneId);
    final instant = tz.TZDateTime.from(reminder.scheduledForUtc, location);
    await _plugin.zonedSchedule(
      platformId,
      'Check in with $cuttingName',
      'A check-in you scheduled is due.',
      instant,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'check_ins',
          'Check-ins',
          channelDescription: 'Private check-ins scheduled by you',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: reminder.cuttingId.value,
    );
  }

  @override
  Future<void> cancel(String platformId) =>
      _plugin.cancel(int.parse(platformId));
}
