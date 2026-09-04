import 'dart:math';

import 'package:cutting_log/src/application/capture_workflow.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final class ReminderResult {
  const ReminderResult(this.reminder, {required this.notificationsEnabled});
  final bool notificationsEnabled;
  final Reminder reminder;
}

final class ReminderWorkflow {
  ReminderWorkflow(
    this._repository,
    this._notifications, {
    DateTime Function()? clock,
    IdFactory? ids,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       _ids = ids ?? const IdFactory() {
    tz_data.initializeTimeZones();
  }

  final DateTime Function() _clock;
  final IdFactory _ids;
  final LocalNotificationGateway _notifications;
  final JournalDataRepository _repository;

  static DateTime resolveWallClock({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required String timeZoneId,
  }) {
    tz_data.initializeTimeZones();
    return tz.TZDateTime(
      tz.getLocation(timeZoneId),
      year,
      month,
      day,
      hour,
      minute,
    ).toUtc();
  }

  static DateTime wallClockFor(DateTime instantUtc, String timeZoneId) {
    tz_data.initializeTimeZones();
    final value = tz.TZDateTime.from(instantUtc, tz.getLocation(timeZoneId));
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
  }

  Future<ReminderResult> create({
    required EntityId cuttingId,
    required DateTime scheduledForUtc,
    required String timeZoneId,
  }) async {
    final now = _clock();
    if (!scheduledForUtc.isAfter(now)) {
      throw ArgumentError.value(
        scheduledForUtc,
        'scheduledForUtc',
        'must be in the future',
      );
    }
    // This is the only place permission is requested, and only in direct
    // response to creating the first check-in.
    var permission = await _notifications.permissionState();
    if (permission != NotificationPermissionState.granted &&
        !await _hasAnyReminder()) {
      permission = await _notifications.requestPermission();
    }
    final reminder = Reminder(
      id: _ids.next('reminder'),
      cuttingId: cuttingId,
      scheduledForUtc: scheduledForUtc,
      timeZoneId: timeZoneId,
      status: ReminderStatus.pending,
      platformNotificationId: permission == NotificationPermissionState.granted
          ? _platformId()
          : null,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await _repository.createReminder(reminder);
    if (reminder.platformNotificationId != null) {
      final cutting = await _requiredCutting(cuttingId);
      await _notifications.schedule(reminder, cutting.name);
    }
    return ReminderResult(
      reminder,
      notificationsEnabled: permission == NotificationPermissionState.granted,
    );
  }

  Future<void> edit(
    Reminder reminder,
    DateTime scheduledForUtc,
    String timeZoneId,
  ) async {
    if (!scheduledForUtc.isAfter(_clock())) {
      throw ArgumentError.value(
        scheduledForUtc,
        'scheduledForUtc',
        'must be in the future',
      );
    }
    final updated = _copy(
      reminder,
      scheduledForUtc: scheduledForUtc,
      timeZoneId: timeZoneId,
      updatedAtUtc: _clock(),
    );
    await _replaceSchedule(reminder, updated);
  }

  Future<void> complete(Reminder reminder) async {
    await _cancelPlatform(reminder);
    final now = _clock();
    await _repository.updateReminder(
      _copy(
        reminder,
        status: ReminderStatus.completed,
        completedAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<void> snooze(Reminder reminder, Duration duration) async {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration');
    }
    final updated = _copy(
      reminder,
      scheduledForUtc: _clock().add(duration),
      snoozedFromUtc: reminder.scheduledForUtc,
      updatedAtUtc: _clock(),
    );
    await _replaceSchedule(reminder, updated);
  }

  Future<void> remove(Reminder reminder) async {
    await _cancelPlatform(reminder);
    await _repository.updateReminder(
      _copy(reminder, status: ReminderStatus.cancelled, updatedAtUtc: _clock()),
    );
  }

  /// Repairs schedules without requesting permission. Safe on every startup,
  /// timezone change, and after platform notification data is cleared.
  Future<void> reconcile() async {
    if (await _notifications.permissionState() !=
        NotificationPermissionState.granted) {
      return;
    }
    final platformIds = await _notifications.pendingIds();
    final expected = <String>{};
    for (final cutting in await _repository.getCuttings()) {
      for (final reminder in await _repository.getReminders(cutting.id)) {
        final id = reminder.platformNotificationId;
        if (reminder.status != ReminderStatus.pending || id == null) continue;
        if (cutting.archivedAtUtc != null) {
          await _notifications.cancel(id);
          await _repository.updateReminder(
            _copy(
              reminder,
              status: ReminderStatus.cancelled,
              updatedAtUtc: _clock(),
            ),
          );
          continue;
        }
        if (!reminder.scheduledForUtc.isAfter(_clock())) {
          if (platformIds.contains(id)) {
            await _notifications.cancel(id);
          }
          continue;
        }
        expected.add(id);
        if (!platformIds.contains(id)) {
          await _notifications.schedule(reminder, cutting.name);
        }
      }
    }
    for (final stale in platformIds.difference(expected)) {
      await _notifications.cancel(stale);
    }
  }

  Future<void> _replaceSchedule(Reminder old, Reminder updated) async {
    await _repository.updateReminder(updated);
    await _cancelPlatform(old);
    if (updated.platformNotificationId != null) {
      final cutting = await _requiredCutting(updated.cuttingId);
      await _notifications.schedule(updated, cutting.name);
    }
  }

  Future<Cutting> _requiredCutting(EntityId id) async {
    final cutting = await _repository.getCutting(id);
    if (cutting == null) {
      throw const JournalNotFoundException('cutting does not exist');
    }
    return cutting;
  }

  Future<bool> _hasAnyReminder() async {
    for (final cutting in await _repository.getCuttings()) {
      if ((await _repository.getReminders(cutting.id)).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> _cancelPlatform(Reminder reminder) async {
    final id = reminder.platformNotificationId;
    if (id != null) {
      await _notifications.cancel(id);
    }
  }

  String _platformId() => '${Random.secure().nextInt(0x7fffffff)}';
}

Reminder _copy(
  Reminder source, {
  DateTime? scheduledForUtc,
  String? timeZoneId,
  ReminderStatus? status,
  DateTime? completedAtUtc,
  DateTime? snoozedFromUtc,
  required DateTime updatedAtUtc,
}) => Reminder(
  id: source.id,
  cuttingId: source.cuttingId,
  scheduledForUtc: scheduledForUtc ?? source.scheduledForUtc,
  timeZoneId: timeZoneId ?? source.timeZoneId,
  status: status ?? source.status,
  platformNotificationId: source.platformNotificationId,
  createdAtUtc: source.createdAtUtc,
  updatedAtUtc: updatedAtUtc,
  completedAtUtc: completedAtUtc,
  snoozedFromUtc: snoozedFromUtc ?? source.snoozedFromUtc,
);
