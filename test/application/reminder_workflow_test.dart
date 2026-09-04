import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime.utc(2026, 1, 1, 12);

  test(
    'permission denial is requested once and keeps in-app check-ins',
    () async {
      final repository = InMemoryJournalDataRepository();
      final cutting = await _seed(repository, base);
      final gateway = _FakeNotifications(
        permission: NotificationPermissionState.denied,
      );
      final workflow = ReminderWorkflow(repository, gateway, clock: () => base);

      final first = await workflow.create(
        cuttingId: cutting.id,
        scheduledForUtc: base.add(const Duration(days: 1)),
        timeZoneId: 'UTC',
      );
      final second = await workflow.create(
        cuttingId: cutting.id,
        scheduledForUtc: base.add(const Duration(days: 2)),
        timeZoneId: 'UTC',
      );

      expect(first.notificationsEnabled, isFalse);
      expect(second.notificationsEnabled, isFalse);
      expect(gateway.requests, 1);
      expect(await repository.getReminders(cutting.id), hasLength(2));
      expect(gateway.scheduled, isEmpty);
    },
  );

  test(
    'create, edit, snooze, complete, and remove reconcile schedules',
    () async {
      final repository = InMemoryJournalDataRepository();
      final cutting = await _seed(repository, base);
      final gateway = _FakeNotifications(
        permission: NotificationPermissionState.granted,
      );
      final workflow = ReminderWorkflow(repository, gateway, clock: () => base);
      final first = (await workflow.create(
        cuttingId: cutting.id,
        scheduledForUtc: base.add(const Duration(days: 1)),
        timeZoneId: 'UTC',
      )).reminder;

      await workflow.edit(
        first,
        base.add(const Duration(days: 2)),
        'Europe/London',
      );
      var stored = (await repository.getReminders(cutting.id)).single;
      expect(stored.timeZoneId, 'Europe/London');
      await workflow.snooze(stored, const Duration(days: 3));
      stored = (await repository.getReminders(cutting.id)).single;
      expect(stored.snoozedFromUtc, base.add(const Duration(days: 2)));
      await workflow.complete(stored);
      expect(
        (await repository.getReminders(cutting.id)).single.status,
        ReminderStatus.completed,
      );

      final second = (await workflow.create(
        cuttingId: cutting.id,
        scheduledForUtc: base.add(const Duration(days: 4)),
        timeZoneId: 'UTC',
      )).reminder;
      await workflow.remove(second);
      expect(
        (await repository.getReminders(cutting.id)).last.status,
        ReminderStatus.cancelled,
      );
      expect(gateway.cancelled, isNotEmpty);
    },
  );

  test(
    'wall-clock resolution handles DST gaps and overlaps deterministically',
    () {
      expect(
        ReminderWorkflow.resolveWallClock(
          year: 2026,
          month: 3,
          day: 8,
          hour: 2,
          minute: 30,
          timeZoneId: 'America/New_York',
        ),
        DateTime.utc(2026, 3, 8, 7, 30),
      );
      expect(
        ReminderWorkflow.resolveWallClock(
          year: 2026,
          month: 11,
          day: 1,
          hour: 1,
          minute: 30,
          timeZoneId: 'America/New_York',
        ),
        DateTime.utc(2026, 11, 1, 5, 30),
      );
    },
  );
}

Future<Cutting> _seed(
  InMemoryJournalDataRepository repository,
  DateTime base,
) async {
  final parent = ParentPlant(
    id: EntityId('parent'),
    nickname: 'Parent',
    createdAtUtc: base,
    updatedAtUtc: base,
  );
  final cutting = Cutting(
    id: EntityId('cutting'),
    parentId: parent.id,
    name: 'Cutting',
    method: 'stem',
    startedAtUtc: base,
    createdAtUtc: base,
    updatedAtUtc: base,
  );
  await repository.createParentPlant(parent);
  await repository.createCutting(cutting);
  return cutting;
}

final class _FakeNotifications implements LocalNotificationGateway {
  _FakeNotifications({required this.permission});

  final List<String> cancelled = <String>[];
  NotificationPermissionState permission;
  int requests = 0;
  final Set<String> scheduled = <String>{};

  @override
  Future<void> cancel(String platformId) async {
    cancelled.add(platformId);
    scheduled.remove(platformId);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<Set<String>> pendingIds() async => Set<String>.from(scheduled);

  @override
  Future<NotificationPermissionState> permissionState() async => permission;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    requests++;
    return permission;
  }

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) async {
    scheduled.add(reminder.platformNotificationId!);
  }
}
